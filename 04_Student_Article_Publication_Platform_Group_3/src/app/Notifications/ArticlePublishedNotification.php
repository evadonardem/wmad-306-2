<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ArticlePublishedNotification extends Notification
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
            ->subject('Article Published')
            ->line('Your article has been published: '.$this->article->title)
            ->action('Read Article', url(route('student.dashboard')));
    }

    public function toArray($notifiable)
    {
        return [
            'article_id' => $this->article->id,
            'article_title' => $this->article->title,
            'type' => 'article_published',
            'message' => 'Your article has been published: ' . $this->article->title
        ];
    }
}
