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

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Your Article Has Been Published!')
            ->greeting('Congratulations ' . $notifiable->name . '!')
            ->line('Your article titled "' . $this->article->title . '" has been published.')
            ->action('View Published Article', route('student.articles.show', $this->article))
            ->line('Your article is now visible to all students and can receive comments.');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'article_id' => $this->article->id,
            'title' => $this->article->title,
            'editor' => $this->article->editor->name,
            'message' => 'Your article has been published!'
        ];
    }
}
