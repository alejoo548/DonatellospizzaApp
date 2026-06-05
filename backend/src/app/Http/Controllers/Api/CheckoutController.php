<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Notifications\OrderInvoiceNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class CheckoutController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'cardholder_name' => ['required', 'string', 'max:120'],
            'card_number' => ['required', 'string', 'max:24'],
            'exp_month' => ['required', 'integer', 'between:1,12'],
            'exp_year' => ['required', 'integer', 'between:2026,2100'],
            'cvv' => ['required', 'string', 'regex:/^\d{3,4}$/'],
        ]);

        $cardNumber = preg_replace('/\D+/', '', $validated['card_number']);

        if (! $this->isValidCardNumber($cardNumber)) {
            throw ValidationException::withMessages([
                'card_number' => ['The card number is invalid.'],
            ]);
        }

        if ($this->isExpired((int) $validated['exp_month'], (int) $validated['exp_year'])) {
            throw ValidationException::withMessages([
                'exp_year' => ['The card is expired.'],
            ]);
        }

        $user = $request->user();
        $items = $user->cartItems()
            ->with('product:id,name,description,price,image,category_id')
            ->orderBy('id')
            ->get();

        if ($items->isEmpty()) {
            throw ValidationException::withMessages([
                'cart' => ['Your cart is empty.'],
            ]);
        }

        $order = DB::transaction(function () use ($user, $items, $validated, $cardNumber): PurchaseOrder {
            foreach ($items as $item) {
                $product = $item->product;
                if (! $product || $product->stock < $item->quantity) {
                    throw ValidationException::withMessages([
                        'cart' => [($product?->name ?? 'A product') . ' no longer has enough stock.'],
                    ]);
                }
            }

            $subtotal = round((float) $items->sum('total_price'), 2);

            $order = PurchaseOrder::create([
                'user_id' => $user->id,
                'order_number' => $this->newOrderNumber(),
                'subtotal' => $subtotal,
                'total' => $subtotal,
                'status' => 'completed',
                'payment_status' => 'paid',
            ]);

            $items->each(function (CartItem $item) use ($order): void {
                $product = $item->product;

                $order->items()->create([
                    'product_id' => $item->product_id,
                    'product_name' => $product?->name ?? 'Product',
                    'product_description' => $product?->description,
                    'product_image' => $product?->image,
                    'quantity' => $item->quantity,
                    'unit_price' => $item->unit_price,
                    'total_price' => $item->total_price,
                    'size' => $item->size,
                    'crust' => $item->crust,
                ]);
            });

            $order->payment()->create([
                'user_id' => $user->id,
                'amount' => $subtotal,
                'status' => 'approved',
                'card_brand' => $this->cardBrand($cardNumber),
                'card_last_four' => substr($cardNumber, -4),
                'card_exp_month' => (int) $validated['exp_month'],
                'card_exp_year' => (int) $validated['exp_year'],
                'card_fingerprint' => hash_hmac('sha256', $cardNumber, config('app.key')),
                'authorization_code' => strtoupper(Str::random(10)),
            ]);

            $items->each(function (CartItem $item): void {
                if ($item->product) {
                    $newStock = max(0, $item->product->stock - $item->quantity);
                    $item->product->update([
                        'stock' => $newStock,
                        'status' => $newStock === 0 ? 'unavailable' : $item->product->status,
                    ]);
                }
            });

            $user->cartItems()->delete();

            return $order->load(['items', 'payment']);
        });

        try {
            $user->notify(new OrderInvoiceNotification($order));
        } catch (\Throwable) {
            // Invoice email failure must not block checkout response
        }

        return response()->json([
            'message' => 'Payment approved.',
            'order' => $this->serializeOrder($order),
        ], 201);
    }

    public function index(Request $request): JsonResponse
    {
        $orders = $request->user()
            ->purchaseOrders()
            ->with(['items', 'payment'])
            ->latest()
            ->get()
            ->map(fn (PurchaseOrder $order): array => $this->serializeOrder($order));

        return response()->json(['orders' => $orders]);
    }

    private function serializeOrder(PurchaseOrder $order): array
    {
        return [
            'id' => $order->id,
            'order_number' => $order->order_number,
            'subtotal' => (float) $order->subtotal,
            'total' => (float) $order->total,
            'status' => $order->status,
            'payment_status' => $order->payment_status,
            'created_at' => $order->created_at?->toISOString(),
            'payment' => $order->payment ? [
                'status' => $order->payment->status,
                'card_brand' => $order->payment->card_brand,
                'card_last_four' => $order->payment->card_last_four,
                'authorization_code' => $order->payment->authorization_code,
            ] : null,
            'items' => $order->items->map(function ($item): array {
                $product = $item->product_id ? Product::find($item->product_id) : null;

                return [
                    'id' => $item->id,
                    'product_id' => $item->product_id,
                    'product_name' => $item->product_name,
                    'product_description' => $item->product_description,
                    'product_image' => $item->product_image,
                    'product_image_url' => $product?->publicImageUrl(),
                    'quantity' => $item->quantity,
                    'unit_price' => (float) $item->unit_price,
                    'total_price' => (float) $item->total_price,
                    'size' => $item->size,
                    'crust' => $item->crust,
                ];
            }),
        ];
    }

    private function newOrderNumber(): string
    {
        do {
            $number = 'DP-' . now()->format('Ymd') . '-' . strtoupper(Str::random(6));
        } while (PurchaseOrder::where('order_number', $number)->exists());

        return $number;
    }

    private function isValidCardNumber(string $number): bool
    {
        if (! preg_match('/^\d{13,19}$/', $number)) {
            return false;
        }

        $sum = 0;
        $alternate = false;

        for ($i = strlen($number) - 1; $i >= 0; $i--) {
            $digit = (int) $number[$i];
            if ($alternate) {
                $digit *= 2;
                if ($digit > 9) {
                    $digit -= 9;
                }
            }
            $sum += $digit;
            $alternate = ! $alternate;
        }

        return $sum % 10 === 0;
    }

    private function isExpired(int $month, int $year): bool
    {
        return now()->setDate($year, $month, 1)->endOfMonth()->isPast();
    }

    private function cardBrand(string $number): string
    {
        return match (true) {
            str_starts_with($number, '4') => 'Visa',
            preg_match('/^5[1-5]/', $number) === 1 => 'Mastercard',
            preg_match('/^3[47]/', $number) === 1 => 'American Express',
            default => 'Card',
        };
    }
}
