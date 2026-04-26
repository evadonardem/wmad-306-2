<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class RevisionRequestedNotification extends Notification
{
    use Queueable;

    protected $article;
    protected $revision;

    public function __construct(Article $article, $revision)
    {
        $this->article = $article;
        $this->revision = $revision;
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Revision Requested for Your Article')
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('Your article titled "' . $this->article->title . '" requires revision.')
            ->line('Editor comments: ' . $this->revision->comments)
            ->action('View Article', route('writer.articles.edit', $this->article))
            ->line('Please make the requested revisions and resubmit your article.');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'article_id' => $this->article->id,
            'title' => $this->article->title,
            'editor' => $this->revision->editor->name,
            'comments' => $this->revision->comments,
            'message' => 'Revision requested for your article'
        ];
    }
}
