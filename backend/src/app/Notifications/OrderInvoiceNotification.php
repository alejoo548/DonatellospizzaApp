<?php

namespace App\Notifications;

use App\Models\PurchaseOrder;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderInvoiceNotification extends Notification
{
    use Queueable;

    public function __construct(private readonly PurchaseOrder $order) {}

    /** @return array<int, string> */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $order = $this->order;
        $payment = $order->payment;

        $message = (new MailMessage)
            ->subject("Order Confirmed – {$order->order_number} | Donatello's Pizza")
            ->greeting("Hi {$notifiable->name}, your order is confirmed!")
            ->line("**Order:** {$order->order_number}")
            ->line('---');

        foreach ($order->items as $item) {
            $line = "{$item->quantity}× {$item->product_name}";
            if ($item->size) {
                $line .= " ({$item->size})";
            }
            $line .= '  —  $' . number_format((float) $item->total_price, 2);
            $message->line($line);
        }

        $message->line('---')
            ->line('**Total: $' . number_format((float) $order->total, 2) . '**');

        if ($payment) {
            $message->line("**Payment:** {$payment->card_brand} •••• {$payment->card_last_four}")
                ->line("**Authorization:** {$payment->authorization_code}");
        }

        $message->line("Thank you for ordering from Donatello's Pizza!");

        return $message;
    }
}
