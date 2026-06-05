<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentRecord extends Model
{
    protected $fillable = [
        'purchase_order_id',
        'user_id',
        'amount',
        'status',
        'card_brand',
        'card_last_four',
        'card_exp_month',
        'card_exp_year',
        'card_fingerprint',
        'authorization_code',
    ];

    protected $hidden = [
        'card_fingerprint',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'card_exp_month' => 'integer',
            'card_exp_year' => 'integer',
        ];
    }

    public function order()
    {
        return $this->belongsTo(PurchaseOrder::class, 'purchase_order_id');
    }
}
