<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->normalizeUsersPrimaryKey();

        if (Schema::hasTable('favorite_products')) {
            if (DB::table('favorite_products')->count() === 0) {
                Schema::drop('favorite_products');
            } else {
                return;
            }
        }

        Schema::create('favorite_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('favorite_products');
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
