<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\ResetPasswordTokenNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Password;
use Tests\TestCase;

class ForgotPasswordTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_request_validate_and_reset_password(): void
    {
        Notification::fake();

        $user = User::factory()->create([
            'email' => 'recover@example.com',
            'password' => 'old-password',
        ]);

        $this->postJson('/api/forgot-password', [
            'email' => $user->email,
        ])->assertOk()
            ->assertJson([
                'expires_in_minutes' => 15,
            ]);

        Notification::assertSentTo($user, ResetPasswordTokenNotification::class);

        $token = Password::broker()->createToken($user);

        $this->postJson('/api/forgot-password/validate-token', [
            'email' => $user->email,
            'token' => $token,
        ])->assertOk();

        $this->postJson('/api/forgot-password/reset', [
            'email' => $user->email,
            'token' => $token,
            'password' => 'new-password-123',
            'password_confirmation' => 'new-password-123',
        ])->assertOk();

        $user->refresh();

        $this->assertTrue(Hash::check('new-password-123', $user->password));

        $this->postJson('/api/forgot-password/validate-token', [
            'email' => $user->email,
            'token' => $token,
        ])->assertStatus(422);

        $this->postJson('/api/forgot-password/reset', [
            'email' => $user->email,
            'token' => $token,
            'password' => 'AnotherPass123',
            'password_confirmation' => 'AnotherPass123',
        ])->assertStatus(422);
    }

    public function test_register_rejects_weak_passwords(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Test',
            'lastname' => 'User',
            'email' => 'weak@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ])->assertStatus(422)
            ->assertJsonValidationErrors(['password']);
    }
}
