<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CarouselItem extends Model
{
    protected $fillable = [
        'product_id',
        'title',
        'description',
        'badge_text',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
