<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Comment Posted</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        .header {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        .content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .article-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #3b82f6;
        }
        .article-title {
            font-size: 20px;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 10px;
        }
        .article-meta {
            color: #6c757d;
            font-size: 14px;
            margin-bottom: 5px;
        }
        .comment-box {
            background: #f1f5f9;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .comment-content {
            font-style: italic;
            color: #4b5563;
            line-height: 1.5;
        }
        .comment-meta {
            color: #6c757d;
            font-size: 12px;
            margin-top: 10px;
            font-style: normal;
        }
        .action-button {
            display: inline-block;
            background: #3b82f6;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            margin-top: 20px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #6c757d;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>💬 New Comment Posted</h1>
        <p>Someone commented on your published article.</p>
    </div>

    <div class="content">
        <div class="article-info">
            <div class="article-title">{{ $comment->article->title }}</div>
            <div class="article-meta">
                <strong>Author:</strong> {{ $writerName }}<br>
                <strong>Commented by:</strong> {{ $comment->student->name }}<br>
                <strong>Commented:</strong> {{ $comment->created_at->format('F j, Y, g:i A') }}<br>
                <strong>Status:</strong> {{ $comment->article->status->label }}
            </div>
        </div>

        <p>Hello {{ $writerName }},</p>
        
        <p>A new comment has been posted on your article <strong>"{{ $comment->article->title }}"</strong> by <strong>{{ $comment->student->name }}</strong>.</p>
        
        <div class="comment-box">
            <div class="comment-content">
                "{{ $comment->content }}"
            </div>
            <div class="comment-meta">
                Posted on {{ $comment->created_at->format('F j, Y \a\t g:i A') }}
            </div>
        </div>
        
        <p>You can view the comment and respond if needed through the platform.</p>
        
        <p style="margin-top: 20px;">
            <a href="{{ $actionUrl }}" class="action-button">
                View Article & Comment
            </a>
        </p>
    </div>

    <div class="footer">
        <p>This notification was sent to {{ $writerName }} because you are the author of this article.</p>
        <p>© {{ date('Y') }} Article Publication Platform. All rights reserved.</p>
    </div>
</body>
</html>
