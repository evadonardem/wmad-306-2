<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ArticlePublishedNotification extends Notification
{
    use Queueable;

    public function __construct(public Article $article)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toArray(object $notifiable): array
    {
        return [
            'type' => 'article_published',
            'title' => 'Article Published',
            'message' => sprintf('Your article "%s" has been published.', $this->article->title),
            'url' => route('writer.dashboard'),
            'article_id' => $this->article->id,
        ];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Your Article Has Been Published!')
            ->greeting('Congratulations ' . $notifiable->name . '!')
            ->line('Your article has been published.')
            ->line('Title: ' . $this->article->title)
            ->action('View Article', url('/student/articles/' . $this->article->id))
            ->line('Your article is now visible to all students.');
    }
}
