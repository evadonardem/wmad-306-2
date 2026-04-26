<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Article;
use Illuminate\Http\Request;

class ArticleController extends Controller
{
    public function latestArticles()
    {
        try {
            $articles = Article::with(['writer', 'category', 'status'])
                ->whereHas('status', function($query) {
                    $query->where('name', 'published');
                })
                ->withCount('comments')
                ->orderBy('updated_at', 'desc')
                ->take(9) // Get latest 9 articles for carousel
                ->get()
                ->map(function ($article) {
                    return [
                        'id' => $article->id,
                        'title' => $article->title,
                        'excerpt' => $article->excerpt,
                        'content' => $article->content,
                        'writer' => $article->writer ? $article->writer->name : 'Anonymous',
                        'category' => $article->category ? $article->category->name : 'General',
                        'updated_at' => $article->updated_at->format('M d, Y'),
                        'comments_count' => $article->comments_count,
                    ];
                });

            return response()->json($articles);
        } catch (\Exception $e) {
            \Log::error('Error fetching latest articles: ' . $e->getMessage());
            return response()->json([], 500);
        }
    }
}
