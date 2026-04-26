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

    public function via($notifiable)
    {
        return ['mail', 'database'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('Article Submitted')
            ->line('An article has been submitted for review: '.$this->article->title)
            ->action('Review Article', url(route('editor.articles.review', $this->article)));
    }

    public function toArray($notifiable)
    {
        return [
            'article_id' => $this->article->id,
            'article_title' => $this->article->title,
            'writer_name' => $this->article->writer->name,
            'type' => 'article_submitted',
            'message' => 'Article submitted for review: ' . $this->article->title
        ];
    }
}
