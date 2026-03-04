<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\Comment;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class CommentPostedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public Article $article,
        public Comment $comment
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('New Comment on: ' . $this->article->title)
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('A student commented on your article.')
            ->line('Article: ' . $this->article->title)
            ->line('Comment: ' . \Illuminate\Support\Str::limit($this->comment->content, 100))
            ->action('View Article', url('/writer/dashboard'))
            ->line('Keep up the great work!');
    }
}
