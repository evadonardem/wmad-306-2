<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ArticleSubmittedNotification extends Notification
{
    use Queueable;

    protected $article;

    public function __construct(Article $article)
    {
        $this->article = $article;
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('New Article Submitted for Review')
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('A new article titled "' . $this->article->title . '" has been submitted for review.')
            ->action('Review Article', route('editor.articles.review', $this->article))
            ->line('Please review the article and take appropriate action.');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'article_id' => $this->article->id,
            'title' => $this->article->title,
            'writer' => $this->article->writer->name,
            'message' => 'New article submitted for review'
        ];
    }
}
