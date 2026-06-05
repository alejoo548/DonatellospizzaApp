<?php

use App\Models\Product;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Storage;

return new class extends Migration
{
    public function up(): void
    {
        $files = collect(Storage::disk('public')->files('products'))
            ->filter(fn (string $path): bool => preg_match('/\.(png|jpe?g|webp)$/i', $path) === 1)
            ->values();

        if ($files->isEmpty()) {
            return;
        }

        $used = Product::query()
            ->whereNotNull('image')
            ->pluck('image')
            ->map(fn (?string $path): string => ltrim((string) $path, '/'))
            ->all();

        $available = $files
            ->reject(fn (string $path): bool => in_array($path, $used, true))
            ->values();

        Product::query()
            ->whereNotNull('image')
            ->orderByDesc('id')
            ->get()
            ->each(function (Product $product) use (&$available): void {
                if (! $product->image || Storage::disk('public')->exists(ltrim($product->image, '/'))) {
                    return;
                }

                $replacement = $available->shift();
                if (! $replacement) {
                    return;
                }

                $product->forceFill(['image' => $replacement])->save();
            });
    }

    public function down(): void
    {
        //
    }
};
