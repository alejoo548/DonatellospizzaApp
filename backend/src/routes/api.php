<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MenuController;


Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/forgot-password/validate-token', [AuthController::class, 'validateResetToken']);
Route::post('/forgot-password/reset', [AuthController::class, 'resetPassword']);
Route::get('/categories', [MenuController::class, 'categories']);
Route::get('/products', [MenuController::class, 'products']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return response()->json($request->user());
    });
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
});
