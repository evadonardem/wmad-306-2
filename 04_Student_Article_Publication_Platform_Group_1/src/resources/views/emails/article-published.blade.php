<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Article Published</title>
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            background: #f0fdf4;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #10b981;
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
        .action-button {
            display: inline-block;
            background: #10b981;
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
        <h1>🎉 Article Published!</h1>
        <p>Your article is now live for students to read.</p>
    </div>

    <div class="content">
        <div class="article-info">
            <div class="article-title">{{ $article->title }}</div>
            <div class="article-meta">
                <strong>Author:</strong> {{ $writerName }}<br>
                <strong>Published by:</strong> {{ $editor ? $editor->name : 'Editorial Team' }}<br>
                <strong>Published:</strong> {{ $article->updated_at->format('F j, Y, g:i A') }}<br>
                @if($article->category)
                    <strong>Category:</strong> {{ $article->category->name }}<br>
                @endif
                <strong>Status:</strong> {{ $article->status->label }}
            </div>
        </div>

        <p>Congratulations {{ $writerName }}!</p>
        
        <p>Your article <strong>"{{ $article->title }}"</strong> has been successfully published and is now live for students to read and comment on.</p>
        
        <p>Students can now access your article through the platform, engage with your content, and provide valuable feedback.</p>
        
        <p style="margin-top: 20px;">
            <a href="{{ $actionUrl }}" class="action-button">
                View Published Article
            </a>
        </p>
    </div>

    <div class="footer">
        <p>This notification was sent to {{ $article->writer->name }} because you are the author of this article.</p>
        <p>© {{ date('Y') }} Article Publication Platform. All rights reserved.</p>
    </div>
</body>
</html>
