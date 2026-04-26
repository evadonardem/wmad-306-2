<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ArticleMessageController extends Controller
{
    public function index(Article $article)
    {
        $this->authorize('view', $article);

        $messages = ArticleMessage::where('article_id', $article->id)
            ->with('sender:id,name')
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'messages' => $messages,
        ]);
    }

    public function store(Request $request, Article $article)
    {
        $this->authorize('view', $article);

        $validated = $request->validate([
            'message' => ['required', 'string'],
        ]);

        $message = ArticleMessage::create([
            'article_id' => $article->id,
            'sender_id' => Auth::id(),
            'message' => $validated['message'],
        ]);

        $message->load('sender:id,name');

        return response()->json([
            'message' => $message,
        ], 201);
    }
}
