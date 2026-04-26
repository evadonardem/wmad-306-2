<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Article Submitted</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            border-left: 4px solid #667eea;
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
            background: #667eea;
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
        <h1>📝 Article Submitted for Review</h1>
        <p>A new article has been submitted and is ready for your review.</p>
    </div>

    <div class="content">
        <div class="article-info">
            <div class="article-title">{{ $article->title }}</div>
            <div class="article-meta">
                <strong>Author:</strong> {{ $writerName }}<br>
                <strong>Submitted:</strong> {{ $article->submitted_at->format('F j, Y, g:i A') }}<br>
                @if($article->category)
                    <strong>Category:</strong> {{ $article->category->name }}<br>
                @endif
                <strong>Status:</strong> {{ $article->status->label }}
            </div>
        </div>

        <p>Hello{{ $editor ? ' ' . $editor->name : '' }},</p>
        
        <p>A new article titled <strong>"{{ $article->title }}"</strong> has been submitted by <strong>{{ $writerName }}</strong> and is ready for your review.</p>
        
        <p>Please review the article at your earliest convenience and provide feedback to help the writer improve their work.</p>
        
        <p style="margin-top: 20px;">
            <a href="{{ $actionUrl }}" class="action-button">
                Review Article Now
            </a>
        </p>
    </div>

    <div class="footer">
        <p>This notification was sent to {{ $editor ? $editor->name : 'the editorial team' }} because you are assigned as an editor for this article.</p>
        <p>© {{ date('Y') }} Article Publication Platform. All rights reserved.</p>
    </div>
</body>
</html>
