<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;


class MenuController extends Controller
{
    public function categories()
    {
        return response()->json([
            'categories' => Category::select('id', 'name', 'description')->get()
        ]);
    }

    public function products()
    {
        return response()->json([
            'products' => Product::with('options')
                ->where('stock', '>', 0)
                ->where('status', 'available')
                ->select('id', 'name', 'description', 'price', 'stock', 'image', 'category_id')
                ->get()
                ->map(function (Product $product): array {
                    return [
                        'id' => $product->id,
                        'name' => $product->name,
                        'description' => $product->description,
                        'price' => $product->price,
                        'stock' => $product->stock,
                        'image' => $product->image,
                        'image_url' => $product->publicImageUrl(),
                        'category_id' => $product->category_id,
                        'options' => $product->options,
                    ];
                })
        ]);
    }
}
