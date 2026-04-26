@extends('layouts.app')

@section('content')
<div class="container-fluid py-4">
    <!-- Header -->
    <div class="d-flex align-items-center mb-4">
        <a href="{{ route('student.dashboard') }}" class="btn btn-outline-secondary me-3">
            <i class="bi bi-arrow-left"></i> Back to Dashboard
        </a>
        <h4 class="mb-0">
            <i class="bi bi-chat-dots"></i> My Comments
        </h4>
    </div>

    <!-- Comments List -->
    @if($comments->count() > 0)
        <div class="row">
            @foreach($comments as $comment)
                <div class="col-12 mb-3">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="mb-1">{{ $comment->article->title ?? 'Unknown Article' }}</h6>
                                <small class="text-muted">
                                    <i class="bi bi-person"></i> {{ $comment->article->writer->name ?? 'Unknown Author' }}
                                </small>
                            </div>
                            <div>
                                <small class="text-muted">
                                    <i class="bi bi-calendar3"></i> {{ $comment->article->created_at->format('M d, Y') }}
                                </small>
                            </div>
                        </div>
                        <div class="card-body">
                            <!-- Article Preview -->
                            <p class="text-muted mb-3">
                                {{ Str::limit($comment->article->content ?? 'Article content...', 150) }}
                            </p>
                            
                            <!-- User's Comment -->
                            <div class="border-start border-4 border-primary ps-3 mb-3">
                                <small class="text-muted d-block mb-1">
                                    <i class="bi bi-chat-dots"></i> Your Comment - 
                                    {{ $comment->created_at->format('M d, Y') }}
                                </small>
                                <p class="mb-0">{{ $comment->content }}</p>
                            </div>
                            
                            <!-- View Article Button -->
                            @if($comment->article)
                                <a href="{{ route('student.articles.show', $comment->article->id) }}" 
                                   class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-eye"></i> View Article
                                </a>
                            @endif
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    @else
        <!-- No Comments State -->
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card text-center">
                    <div class="card-body py-5">
                        <i class="bi bi-chat-dots text-muted" style="font-size: 3rem;"></i>
                        <h5 class="text-muted mt-3">No Comments Yet</h5>
                        <p class="text-muted">
                            You haven't commented on any articles yet. Start engaging with the content!
                        </p>
                        <a href="{{ route('student.dashboard') }}" class="btn btn-primary">
                            <i class="bi bi-journal-text"></i> Browse Articles
                        </a>
                    </div>
                </div>
            </div>
        </div>
    @endif
</div>
@endsection
