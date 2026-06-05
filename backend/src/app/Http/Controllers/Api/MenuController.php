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
                ->select('id', 'name', 'description', 'price', 'stock', 'image', 'category_id')
                ->get()
        ]);
    }
}
