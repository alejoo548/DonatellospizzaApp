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

        DB::table('cart_items')->update([
            'size' => null,
            'crust' => null,
        ]);
    }

    public function down(): void
    {
        //
    }
};
