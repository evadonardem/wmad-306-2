<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ArticleRevisedNotification extends Notification
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
            ->subject('Article Revised and Resubmitted')
            ->line('An article has been revised and resubmitted for review: '.$this->article->title)
            ->line('Submitted by: '.$this->article->writer->name)
            ->action('Review Article', url(route('editor.articles.review', $this->article)));
    }

    public function toArray($notifiable)
    {
        return [
            'article_id' => $this->article->id,
            'article_title' => $this->article->title,
            'writer_name' => $this->article->writer->name,
            'type' => 'article_revised',
            'message' => 'Article revised and resubmitted: ' . $this->article->title
        ];
    }
}
