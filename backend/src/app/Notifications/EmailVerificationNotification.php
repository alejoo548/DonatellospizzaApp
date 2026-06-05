<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class EmailVerificationNotification extends Notification
{
    use Queueable;

    public function __construct(private readonly string $code) {}

    /** @return array<int, string> */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject("Verify your email – Donatello's Pizza")
            ->greeting("Hi {$notifiable->name}!")
            ->line('Enter this 6-digit code in the app to activate your account:')
            ->line("**{$this->code}**")
            ->line('This code expires in 15 minutes.')
            ->line('If you did not create an account, you can safely ignore this email.');
    }
}
