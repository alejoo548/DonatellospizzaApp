<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminProductController extends Controller
{
    public function uploadImage(Request $request, Product $product): JsonResponse
    {
        abort_unless($request->user()->role === 'admin', 403, 'Admin only.');

        $request->validate([
            'image' => ['required', 'image', 'max:5120', 'mimes:jpeg,png,webp'],
        ]);

        if ($product->image && ! filter_var($product->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete(ltrim($product->image, '/'));
        }

        $path = $request->file('image')->store('products', 'public');
        $product->update(['image' => $path]);

        return response()->json([
            'message' => 'Image updated.',
            'image_url' => $product->publicImageUrl(),
        ]);
    }
}
