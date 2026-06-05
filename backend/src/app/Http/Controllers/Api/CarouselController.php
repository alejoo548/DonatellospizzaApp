<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CarouselItem;

class CarouselController extends Controller
{
    public function index()
    {
        $items = CarouselItem::with('product:id,name,price,image,category_id')
            ->where('is_active', true)
            ->orderBy('order')
            ->get()
            ->map(fn($item) => [
                'id'          => $item->id,
                'title'       => $item->title,
                'description' => $item->description,
                'badge_text'  => $item->badge_text,
                'order'       => $item->order,
                'product_id'  => $item->product_id,
                'price'       => $item->product->price ?? null,
                'image'       => $item->product->image ?? null,
                'image_url'   => $item->product?->publicImageUrl(),
                'category_id' => $item->product->category_id ?? null,
            ]);

        return response()->json(['carousel' => $items]);
    }
}
