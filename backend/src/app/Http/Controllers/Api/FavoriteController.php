<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $products = $request->user()
            ->favorites()
            ->where('status', 'available')
            ->select('products.id', 'name', 'description', 'price', 'image', 'category_id')
            ->orderByPivot('created_at', 'desc')
            ->get();

        return response()->json([
            'favorites' => $products->map(function (Product $product): array {
                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'description' => $product->description,
                    'price' => $product->price,
                    'image' => $product->image,
                    'image_url' => $product->publicImageUrl(),
                    'category_id' => $product->category_id,
                    'pivot' => $product->pivot,
                ];
            }),
        ]);
    }

    public function store(Request $request, Product $product): JsonResponse
    {
        abort_unless($product->status === 'available', 422, 'Product is not available.');

        $request->user()->favorites()->syncWithoutDetaching([$product->id]);

        return response()->json([
            'message' => 'Product added to favorites.',
            'is_favorite' => true,
        ]);
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        $request->user()->favorites()->detach($product->id);

        return response()->json([
            'message' => 'Product removed from favorites.',
            'is_favorite' => false,
        ]);
    }
}
