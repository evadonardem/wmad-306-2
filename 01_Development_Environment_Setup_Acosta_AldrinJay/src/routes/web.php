<?php

use App\Models\User;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
Route::get('/', function () {
    return "Successfully installed Laravel! Acosta, AldrinJay"
    ;
});

Route::get('/about', function () {
    return "This is about page. Created by Acosta Aldrin Jay.";
});

Route ::get ('/insert-user' , function () {

   return User::create([
    'name' => 'Acosta Aldrin Jay' . rand (1,1000000),
     'email' => 'Acosta Aldrin Jay' . rand (1,1000000) . '@example.com',
      'password' => Hash::make ('123456'),
   ]);
});


Route::get('/user', function () {
    return User::where('name','like','%ella%');
});

Route::get('/test-email', function () {
    $user = User::all()->shuffle()->take(1);
      Mail::raw ("Welcome to the app, $user->name! This is a test email sent by Acosta Aldrin Jay.", function ($message) use ($user) {
      $message->to($user->email)->subject ('Laravel Docker Test Email');

    });
});