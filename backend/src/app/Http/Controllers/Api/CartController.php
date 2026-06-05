<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = $request->user()
            ->cartItems()
            ->with('product:id,name,description,price,stock,image,category_id')
            ->latest()
            ->get();

        return response()->json([
            'items' => $items->map(fn (CartItem $item) => $this->serializeItem($item)),
            'subtotal' => round((float) $items->sum('total_price'), 2),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'quantity' => ['required', 'integer', 'min:1', 'max:99'],
            'size' => ['nullable', 'string'],
            'crust' => ['nullable', 'string'],
        ]);

        $product = Product::with('options')->findOrFail($validated['product_id']);
        abort_unless($product->status === 'available', 422, 'Product is not available.');

        $size = $validated['size'] ?? null;
        $crust = $validated['crust'] ?? null;
        $unitPrice = $this->unitPriceFor($product, $size, $crust);

        $item = $request->user()
            ->cartItems()
            ->where('product_id', $product->id)
            ->where('size', $size)
            ->where('crust', $crust)
            ->first();

        $existingQty = $item ? $item->quantity : 0;
        abort_if($existingQty + $validated['quantity'] > $product->stock, 422, 'Not enough stock available.');

        if ($item) {
            $item->quantity += $validated['quantity'];
        } else {
            $item = new CartItem([
                'product_id' => $product->id,
                'quantity' => $validated['quantity'],
                'size' => $size,
                'crust' => $crust,
                'unit_price' => $unitPrice,
            ]);
            $item->user_id = $request->user()->id;
        }

        $item->unit_price = $unitPrice;
        $item->total_price = round($unitPrice * $item->quantity, 2);
        $item->save();
        $item->load('product:id,name,description,price,stock,image,category_id');

        return response()->json([
            'message' => 'Product added to cart.',
            'item' => $this->serializeItem($item),
        ], 201);
    }

    public function update(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);

        $validated = $request->validate([
            'quantity' => ['required', 'integer', 'min:1', 'max:99'],
        ]);

        $item->load('product:id,name,description,price,stock,image,category_id');
        abort_if($validated['quantity'] > $item->product->stock, 422, 'Not enough stock available.');
        $item->quantity = $validated['quantity'];
        $item->total_price = round((float) $item->unit_price * $item->quantity, 2);
        $item->save();
        $item->load('product:id,name,description,price,stock,image,category_id');

        return response()->json([
            'message' => 'Cart item updated.',
            'item' => $this->serializeItem($item),
        ]);
    }

    public function destroy(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->delete();

        return response()->json([
            'message' => 'Cart item removed.',
        ]);
    }

    public function clear(Request $request): JsonResponse
    {
        $request->user()->cartItems()->delete();

        return response()->json([
            'message' => 'Cart cleared.',
        ]);
    }

    private function authorizeItem(Request $request, CartItem $item): void
    {
        abort_unless($item->user_id === $request->user()->id, 404);
    }

    private function unitPriceFor(Product $product, ?string $size, ?string $crust): float
    {
        $extra = $product->options
            ->whereIn('type', ['size', 'crust'])
            ->filter(function ($option) use ($size, $crust): bool {
                return ($option->type === 'size' && $option->name === $size)
                    || ($option->type === 'crust' && $option->name === $crust);
            })
            ->sum('extra_price');

        return (float) $product->price + (float) $extra;
    }

    private function serializeItem(CartItem $item): array
    {
        return [
            'id' => $item->id,
            'product_id' => $item->product_id,
            'quantity' => $item->quantity,
            'size' => $item->size,
            'crust' => $item->crust,
            'unit_price' => (float) $item->unit_price,
            'total_price' => (float) $item->total_price,
            'product' => $item->product ? [
                'id' => $item->product->id,
                'name' => $item->product->name,
                'description' => $item->product->description,
                'price' => $item->product->price,
                'stock' => $item->product->stock,
                'image' => $item->product->image,
                'image_url' => $item->product->publicImageUrl(),
                'category_id' => $item->product->category_id,
            ] : null,
        ];
    }
}
