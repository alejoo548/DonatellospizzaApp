<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('purchase_orders')) {
            Schema::create('purchase_orders', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('order_number')->unique();
                $table->decimal('subtotal', 10, 2);
                $table->decimal('total', 10, 2);
                $table->string('status')->default('completed');
                $table->string('payment_status')->default('paid');
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('purchase_order_items')) {
            Schema::create('purchase_order_items', function (Blueprint $table) {
                $table->id();
                $table->foreignId('purchase_order_id')->constrained()->cascadeOnDelete();
                $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
                $table->string('product_name');
                $table->text('product_description')->nullable();
                $table->string('product_image')->nullable();
                $table->unsignedInteger('quantity');
                $table->decimal('unit_price', 10, 2);
                $table->decimal('total_price', 10, 2);
                $table->string('size')->nullable();
                $table->string('crust')->nullable();
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('payment_records')) {
            Schema::create('payment_records', function (Blueprint $table) {
                $table->id();
                $table->foreignId('purchase_order_id')->constrained()->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->decimal('amount', 10, 2);
                $table->string('status')->default('approved');
                $table->string('card_brand', 32);
                $table->string('card_last_four', 4);
                $table->unsignedTinyInteger('card_exp_month');
                $table->unsignedSmallInteger('card_exp_year');
                $table->string('card_fingerprint', 128);
                $table->string('authorization_code', 32);
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_records');
        Schema::dropIfExists('purchase_order_items');
        Schema::dropIfExists('purchase_orders');
    }
};
