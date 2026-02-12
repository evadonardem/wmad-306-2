<?php

use App\Models\User;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

Route::get('/', function () {
    return "Succesfully installed Laravel! Sebastian L. Damugo";
    
    //view('welcome');
});


Route::get('/about',function () {
    return "This is the about page";
});

Route::get('/insert-user',function (){
    //Model (ORM) - Eloquent
    User::create([
    'name' => 'Sebastian Damugo' . rand(1,1000000),
    'email'=> 'sebastiandamugo' . rand(1,1000000) . '@example.com',
    'password' => Hash::make('123456'),
    ]);
});

Route::get('/users',function (){
    return User::where('name', 'like', '%as%')->get();
});

Route::get('/test-email',function (){
    $user = User::all()->shuffle()->take(1);
    Mail::raw("Welcome $user->name", function ($message) use ($user) {
        $message->to($user->email)->subject('来自 Laravel 的问候!');
    });
});