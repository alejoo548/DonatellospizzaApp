<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->normalizeUsersPrimaryKey();

        Schema::create('cart_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('quantity');
            $table->string('size')->nullable();
            $table->string('crust')->nullable();
            $table->decimal('unit_price', 8, 2);
            $table->decimal('total_price', 8, 2);
            $table->timestamps();

            $table->index(['user_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cart_items');
    }

    private function normalizeUsersPrimaryKey(): void
    {
        if (Schema::hasColumn('users', 'id_user') && ! Schema::hasColumn('users', 'id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('id_user', 'id');
            });
        }
    }
};
