<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class RevisionRequestedNotification extends Notification
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
            'type' => 'revision_requested',
            'title' => 'Revision Requested',
            'message' => sprintf('An editor requested revisions for "%s".', $this->article->title),
            'url' => route('writer.dashboard'),
            'article_id' => $this->article->id,
        ];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Revision Requested: ' . $this->article->title)
            ->greeting('Hello ' . $notifiable->name . '!')
            ->line('An editor has requested revisions on your article.')
            ->line('Title: ' . $this->article->title)
            ->action('Edit Article', url('/writer/articles/' . $this->article->id . '/edit'))
            ->line('Please review the feedback and make the necessary changes.');
    }
}
