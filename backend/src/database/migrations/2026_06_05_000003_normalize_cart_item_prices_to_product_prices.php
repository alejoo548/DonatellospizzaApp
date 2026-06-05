<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('cart_items')) {
            return;
        }

        DB::table('cart_items')
            ->join('products', 'products.id', '=', 'cart_items.product_id')
            ->select('cart_items.id', 'cart_items.quantity', 'products.price')
            ->orderBy('cart_items.id')
            ->get()
            ->each(function (object $item): void {
                DB::table('cart_items')
                    ->where('id', $item->id)
                    ->update([
                        'unit_price' => $item->price,
                        'total_price' => (float) $item->price * (int) $item->quantity,
                    ]);
            });
    }

    public function down(): void
    {
        //
    }
};
