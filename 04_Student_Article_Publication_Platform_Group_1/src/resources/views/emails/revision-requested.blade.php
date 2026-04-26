<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revision Requested</title>
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
            background: linear-gradient(135deg, #f59e0b 0%, #ef4444 100%);
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
            background: #fef2f2;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #f59e0b;
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
        .revision-comments {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .revision-comments h3 {
            margin-top: 0;
            color: #856404;
            font-size: 16px;
        }
        .revision-comments p {
            margin-bottom: 10px;
            font-style: italic;
        }
        .action-button {
            display: inline-block;
            background: #f59e0b;
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
        <h1>🔄 Revision Requested</h1>
        <p>Your article needs revisions to proceed.</p>
    </div>

    <div class="content">
        <div class="article-info">
            <div class="article-title">{{ $article->title }}</div>
            <div class="article-meta">
                <strong>Author:</strong> {{ $article->writer->name }}<br>
                <strong>Reviewed by:</strong> {{ $editor->name }}<br>
                <strong>Reviewed:</strong> {{ $article->updated_at->format('F j, Y, g:i A') }}<br>
                @if($article->category)
                    <strong>Category:</strong> {{ $article->category->name }}<br>
                @endif
                <strong>Status:</strong> {{ $article->status->label }}
            </div>
        </div>

        <p>Hello {{ $article->writer->name }},</p>
        
        <p>Your article <strong>"{{ $article->title }}"</strong> has been reviewed by <strong>{{ $editor->name }}</strong>.</p>
        
        <div class="revision-comments">
            <h3>💬 Editor Feedback:</h3>
            <p>{{ $comments }}</p>
        </div>
        
        <p>Please make the requested revisions and resubmit your article for further review.</p>
        
        <p style="margin-top: 20px;">
            <a href="{{ $actionUrl }}" class="action-button">
                Revise Article Now
            </a>
        </p>
    </div>

    <div class="footer">
        <p>This notification was sent to {{ $article->writer->name }} because you are the author of this article.</p>
        <p>© {{ date('Y') }} Article Publication Platform. All rights reserved.</p>
    </div>
</body>
</html>
