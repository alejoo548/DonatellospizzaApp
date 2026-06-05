<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CheckoutAndOrdersTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_pay_cart_and_see_purchase_history(): void
    {
        $user = User::factory()->create();
        $product = $this->createProduct(price: 19.96);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart/items', [
            'product_id' => $product->id,
            'quantity' => 2,
        ])->assertCreated();

        $this->postJson('/api/checkout', [
            'cardholder_name' => 'April O Neil',
            'card_number' => '4242424242424242',
            'exp_month' => 12,
            'exp_year' => now()->addYear()->year,
            'cvv' => '123',
        ])
            ->assertCreated()
            ->assertJsonPath('message', 'Payment approved.')
            ->assertJsonPath('order.total', 39.92)
            ->assertJsonPath('order.payment.card_brand', 'Visa')
            ->assertJsonPath('order.payment.card_last_four', '4242');

        $this->assertDatabaseCount('cart_items', 0);
        $this->assertDatabaseHas('payment_records', [
            'user_id' => $user->id,
            'amount' => 39.92,
            'card_last_four' => '4242',
            'card_brand' => 'Visa',
        ]);

        $payment = $user->purchaseOrders()->first()->payment;
        $this->assertNotSame('4242424242424242', $payment->card_fingerprint);
        $this->assertNotSame('123', $payment->card_fingerprint);

        $this->getJson('/api/orders')
            ->assertOk()
            ->assertJsonCount(1, 'orders')
            ->assertJsonPath('orders.0.total', 39.92)
            ->assertJsonPath('orders.0.items.0.product_name', 'Test Product');
    }

    public function test_checkout_rejects_invalid_card(): void
    {
        $user = User::factory()->create();
        $product = $this->createProduct();
        Sanctum::actingAs($user);

        $this->postJson('/api/cart/items', [
            'product_id' => $product->id,
            'quantity' => 1,
        ])->assertCreated();

        $this->postJson('/api/checkout', [
            'cardholder_name' => 'Invalid Card',
            'card_number' => '4111111111111112',
            'exp_month' => 12,
            'exp_year' => now()->addYear()->year,
            'cvv' => '123',
        ])->assertUnprocessable();

        $this->assertDatabaseCount('purchase_orders', 0);
        $this->assertDatabaseCount('cart_items', 1);
    }

    private function createProduct(float $price = 12.50): Product
    {
        $category = Category::query()->firstOrCreate(
            ['name' => 'Pizzas'],
            ['description' => 'Freshly baked pizzas'],
        );

        return Product::create([
            'name' => 'Test Product',
            'description' => 'Test description',
            'price' => $price,
            'stock' => 10,
            'status' => 'available',
            'image' => null,
            'category_id' => $category->id,
        ]);
    }
}
