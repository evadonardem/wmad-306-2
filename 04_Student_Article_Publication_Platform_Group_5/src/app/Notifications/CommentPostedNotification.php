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

    protected $comment;
    protected $article;

    public function __construct(Comment $comment, Article $article)
    {
        $this->comment = $comment;
        $this->article = $article;
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('New Comment on Your Published Article')
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('A new comment has been posted on your article "' . $this->article->title . '".')
            ->line('Comment by ' . $this->comment->student->name . ': ' . $this->comment->content)
            ->action('View Article', route('student.articles.show', $this->article))
            ->line('Thank you for contributing to our publication platform!');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'article_id' => $this->article->id,
            'comment_id' => $this->comment->id,
            'title' => $this->article->title,
            'commenter' => $this->comment->student->name,
            'comment' => $this->comment->content,
            'message' => 'New comment posted on your article'
        ];
    }
}
