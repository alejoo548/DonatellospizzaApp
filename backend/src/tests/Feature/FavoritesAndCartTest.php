<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductOption;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FavoritesAndCartTest extends TestCase
{
    use RefreshDatabase;

    public function test_favorites_and_cart_require_authentication(): void
    {
        $this->getJson('/api/favorites')->assertUnauthorized();
        $this->getJson('/api/cart')->assertUnauthorized();
    }

    public function test_user_can_add_favorite_once_and_remove_it(): void
    {
        $user = User::factory()->create();
        $product = $this->createProduct();
        Sanctum::actingAs($user);

        $this->postJson("/api/favorites/{$product->id}")
            ->assertOk()
            ->assertJson(['is_favorite' => true]);
        $this->postJson("/api/favorites/{$product->id}")->assertOk();

        $this->assertDatabaseCount('favorite_products', 1);

        $this->deleteJson("/api/favorites/{$product->id}")
            ->assertOk()
            ->assertJson(['is_favorite' => false]);

        $this->assertDatabaseCount('favorite_products', 0);
    }

    public function test_user_can_add_update_and_delete_cart_item(): void
    {
        $user = User::factory()->create();
        $product = $this->createProduct(categoryId: 2, price: 20);
        ProductOption::create([
            'product_id' => $product->id,
            'type' => 'size',
            'name' => 'Turtle Size',
            'extra_price' => 4,
        ]);
        ProductOption::create([
            'product_id' => $product->id,
            'type' => 'crust',
            'name' => 'Sewer-Deep Dish',
            'extra_price' => 3,
        ]);
        Sanctum::actingAs($user);

        $this->postJson('/api/cart/items', [
            'product_id' => $product->id,
            'quantity' => 1,
        ])
            ->assertCreated()
            ->assertJsonPath('item.quantity', 1)
            ->assertJsonPath('item.unit_price', 20)
            ->assertJsonPath('item.total_price', 20);

        $this->postJson('/api/cart/items', [
            'product_id' => $product->id,
            'quantity' => 2,
            'size' => 'Turtle Size',
            'crust' => 'Sewer-Deep Dish',
        ])
            ->assertCreated()
            ->assertJsonPath('item.quantity', 2)
            ->assertJsonPath('item.unit_price', 27)
            ->assertJsonPath('item.total_price', 54);

        $itemId = $user->cartItems()
            ->where('size', 'Turtle Size')
            ->where('crust', 'Sewer-Deep Dish')
            ->first()
            ->id;

        $this->patchJson("/api/cart/items/{$itemId}", ['quantity' => 3])
            ->assertOk()
            ->assertJsonPath('item.quantity', 3)
            ->assertJsonPath('item.total_price', 81);

        $this->deleteJson("/api/cart/items/{$itemId}")->assertOk();
        $this->assertDatabaseCount('cart_items', 1);
    }

    public function test_user_can_clear_cart(): void
    {
        $user = User::factory()->create();
        $product = $this->createProduct();
        Sanctum::actingAs($user);

        $this->postJson('/api/cart/items', [
            'product_id' => $product->id,
            'quantity' => 1,
        ])->assertCreated();

        $this->deleteJson('/api/cart')->assertOk();

        $this->assertDatabaseCount('cart_items', 0);
    }

    private function createProduct(int $categoryId = 1, float $price = 12.5): Product
    {
        Category::unguarded(function () use ($categoryId): void {
            Category::query()->firstOrCreate(
                ['id' => $categoryId],
                ['name' => $categoryId === 2 ? 'Pizzas' : 'Sides'],
            );
        });

        return Product::create([
            'name' => 'Test Product',
            'description' => 'Test description',
            'price' => $price,
            'stock' => 10,
            'status' => 'available',
            'image' => null,
            'category_id' => $categoryId,
        ]);
    }
}
