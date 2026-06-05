<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductsSeeder extends Seeder
{
    public function run(): void
    {
        $category = Category::firstOrCreate(
            ['name' => 'Pizzas'],
            ['description' => 'Freshly baked pizzas']
        );

        $products = [
            [
                'name' => 'Pepperoni Pizza',
                'description' => 'A delicious classic pepperoni pizza.',
                'price' => 12.99,
                'stock' => 50,
                'status' => 'available',
                'image' => 'products/pepperoni_pizza.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Margherita Pizza',
                'description' => 'Fresh basil and mozzarella on a classic crust.',
                'price' => 11.99,
                'stock' => 45,
                'status' => 'available',
                'image' => 'products/margherita_pizza.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'BBQ Chicken Pizza',
                'description' => 'BBQ chicken, red onions, and cilantro.',
                'price' => 14.99,
                'stock' => 40,
                'status' => 'available',
                'image' => 'products/bbq_chicken_pizza.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Hawaiian Pizza',
                'description' => 'Ham and pineapple chunks on a cheesy base.',
                'price' => 13.99,
                'stock' => 35,
                'status' => 'available',
                'image' => 'products/hawaiian_pizza.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Veggie Pizza',
                'description' => 'Bell peppers, olives, mushrooms, and onions.',
                'price' => 12.99,
                'stock' => 40,
                'status' => 'available',
                'image' => 'products/veggie_pizza.png',
                'category_id' => $category->id,
            ],
            [
                'name' => 'Meat Lovers Pizza',
                'description' => 'Sausage, bacon, ham, and pepperoni for meat enthusiasts.',
                'price' => 15.99,
                'stock' => 30,
                'status' => 'available',
                'image' => 'products/meat_lovers_pizza.png',
                'category_id' => $category->id,
            ],
        ];

        foreach ($products as $product) {
            Product::firstOrCreate(
                ['name' => $product['name']],
                $product
            );
        }
    }
}
