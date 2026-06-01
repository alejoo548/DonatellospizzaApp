<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Support\Facades\Config;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordTokenNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $token,
    ) {
    }

    /**
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $expiresInMinutes = (int) Config::get('auth.passwords.users.expire', 15);

        return (new MailMessage)
            ->subject('Password recovery token')
            ->greeting('Hello ' . $notifiable->name . '!')
            ->line('We received a request to reset your password.')
            ->line('Use this recovery token in the mobile app:')
            ->line($this->token)
            ->line("This token expires in {$expiresInMinutes} minutes.")
            ->line('If you did not request it, you can ignore this email.');
    }
}
