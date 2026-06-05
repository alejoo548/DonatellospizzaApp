<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\EmailVerificationNotification;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'     => 'required|string|max:255',
            'lastname' => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => ['required', 'string', 'confirmed', $this->passwordRule()],
        ]);

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user = User::create([
            'name'                          => $validated['name'],
            'lastname'                      => $validated['lastname'],
            'email'                         => $validated['email'],
            'password'                      => $validated['password'],
            'role'                          => 'client',
            'email_verification_code'       => $code,
            'email_verification_expires_at' => now()->addMinutes(15),
        ]);

        $user->notify(new EmailVerificationNotification($code));

        return response()->json([
            'message' => 'Account created. A 6-digit verification code was sent to your email.',
            'email'   => $user->email,
        ], 201);
    }

    public function verifyEmail(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'code'  => 'required|digits:6',
        ]);

        $user = User::where('email', $request->string('email')->toString())->first();

        if (
            ! $user
            || $user->email_verification_code !== $request->string('code')->toString()
            || ! $user->email_verification_expires_at
            || $user->email_verification_expires_at->isPast()
        ) {
            throw ValidationException::withMessages([
                'code' => ['The verification code is invalid or has expired.'],
            ]);
        }

        $user->forceFill([
            'email_verified_at'             => now(),
            'email_verification_code'       => null,
            'email_verification_expires_at' => null,
        ])->save();

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'message' => 'Email verified successfully.',
            'user'    => [
                'id'       => $user->id,
                'name'     => $user->name,
                'lastname' => $user->lastname,
                'email'    => $user->email,
                'role'     => $user->role,
            ],
            'token' => $token,
        ]);
    }

    public function resendVerification(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->string('email')->toString())->first();

        if (! $user) {
            return response()->json(['message' => 'If that email exists, a code was sent.']);
        }

        if ($user->email_verified_at) {
            return response()->json(['message' => 'Email is already verified.'], 409);
        }

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user->forceFill([
            'email_verification_code'       => $code,
            'email_verification_expires_at' => now()->addMinutes(15),
        ])->save();

        $user->notify(new EmailVerificationNotification($code));

        return response()->json(['message' => 'Verification code resent.']);
    }

    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        if ($user->role === 'admin') {
            return response()->json([
                'message' => 'Access not allowed for admins.',
            ], 403);
        }

        if (! $user->email_verified_at) {
            return response()->json([
                'message'            => 'Please verify your email before signing in.',
                'email_unverified'   => true,
                'email'              => $user->email,
            ], 403);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'message' => 'Signed In successfully.',
            'user'    => [
                'id'       => $user->id,
                'name'     => $user->name,
                'lastname' => $user->lastname,
                'email'    => $user->email,
                'role'     => $user->role,
            ],
            'token' => $token,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Session closed.']);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $status = Password::sendResetLink([
            'email' => $request->string('email')->toString(),
        ]);

        if ($status !== Password::RESET_LINK_SENT) {
            return response()->json([
                'message' => __($status),
            ]);
        }

        return response()->json([
            'message'            => 'We sent a recovery token to your email address.',
            'expires_in_minutes' => config('auth.passwords.users.expire'),
        ]);
    }

    public function validateResetToken(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
        ]);

        $user = User::where('email', $request->string('email')->toString())->first();

        if (! $user || ! Password::broker()->tokenExists($user, $request->string('token')->toString())) {
            throw ValidationException::withMessages([
                'token' => ['The recovery token is invalid or has expired.'],
            ]);
        }

        return response()->json([
            'message' => 'Recovery token validated successfully.',
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|email',
            'token'    => 'required|string',
            'password' => ['required', 'string', 'confirmed', $this->passwordRule()],
        ]);

        $status = Password::reset(
            [
                'email'                 => $request->string('email')->toString(),
                'token'                 => $request->string('token')->toString(),
                'password'              => $request->input('password'),
                'password_confirmation' => $request->input('password_confirmation'),
            ],
            function (User $user, string $password): void {
                $user->forceFill([
                    'password'       => Hash::make($password),
                    'remember_token' => Str::random(60),
                ])->save();

                event(new PasswordReset($user));
            },
        );

        if ($status !== Password::PASSWORD_RESET) {
            throw ValidationException::withMessages([
                'token' => [__($status)],
            ]);
        }

        return response()->json([
            'message' => 'Password updated successfully.',
        ]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => [
                'required',
                'string',
                'min:2',
                'max:50',
                'regex:/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$/u',
            ],
            'lastname' => [
                'required',
                'string',
                'min:2',
                'max:50',
                'regex:/^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$/u',
            ],
        ], [
            'name.min'      => 'The name must contain at least 2 characters.',
            'name.regex'    => 'The name may only contain letters and spaces.',
            'lastname.min'  => 'The lastname must contain at least 2 characters.',
            'lastname.regex' => 'The lastname may only contain letters and spaces.',
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated successfully.',
            'user'    => $user,
        ]);
    }

    private function passwordRule(): PasswordRule
    {
        return PasswordRule::min(8)
            ->mixedCase()
            ->numbers();
    }
}
