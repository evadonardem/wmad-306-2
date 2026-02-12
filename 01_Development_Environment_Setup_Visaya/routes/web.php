<?php

use Illuminate\Support\Facades\Route;

$header = '
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background-color: #f3f4f6; font-family: sans-serif; }
    </style>
';

Route::get('/', function () use ($header) {
    return $header . '
    <div class="flex items-center justify-center h-screen">
        <div class="bg-white p-10 rounded-2xl shadow-xl text-center max-w-lg border-t-8 border-red-500">
            <h1 class="text-5xl font-extrabold text-gray-900 mb-4">Laravel <span class="text-red-600">2026</span></h1>
            <p class="text-gray-600 text-lg mb-6">Your Herd environment is live! Everything in this site is running from just one file.</p>
            <div class="flex justify-center gap-4">
                <a href="/hello" class="bg-gray-800 text-white px-6 py-2 rounded-lg hover:bg-black transition">View Hello</a>
                <a href="/user/Freddie Visaya" class="bg-red-500 text-white px-6 py-2 rounded-lg hover:bg-red-600 transition">My Profile</a>
            </div>
        </div>
    </div>';
});

Route::get('/hello', function () use ($header) {
    return $header . '
    <div class="flex items-center justify-center h-screen">
        <div class="bg-white p-8 rounded-xl shadow-md text-center border border-gray-200">
            <span class="text-5xl">👋</span>
            <h1 class="text-3xl font-bold text-gray-800 mt-4">Hello, World!</h1>
            <p class="text-gray-500 mt-2">This is a custom route with a modern UI.</p>
            <hr class="my-6">
            <a href="/" class="text-blue-600 hover:underline font-medium">← Back to Home</a>
        </div>
    </div>';
});

Route::get('/user/{name}', function ($name) use ($header) {
    $formattedName = ucfirst($name);
    return $header . '
    <div class="flex items-center justify-center h-screen">
        <div class="bg-slate-900 text-white p-10 rounded-3xl shadow-2xl text-center w-80">
            <div class="w-20 h-20 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full mx-auto mb-4 flex items-center justify-center text-2xl font-bold">
                ' . substr($formattedName, 0, 1) . '
            </div>
            <h1 class="text-2xl font-bold">'. $formattedName .'</h1>
            <p class="text-slate-400 text-sm mb-6 font-mono">ID: ' . rand(1000, 9999) . '</p>
            <button class="w-full bg-white text-black font-bold py-2 rounded-full mb-3 hover:bg-gray-200">Edit Profile</button>
            <a href="/" class="block text-xs text-slate-500 uppercase tracking-widest hover:text-white">Exit Dashboard</a>
        </div>
    </div>';
});