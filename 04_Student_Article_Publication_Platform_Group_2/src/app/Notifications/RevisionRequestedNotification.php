<?php

namespace App\Notifications;

use App\Models\Article;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class RevisionRequestedNotification extends Notification
{
    use Queueable;

    public function __construct(public Article $article) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Revision Requested: ' . $this->article->title)
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('An editor has requested revisions on your article.')
            ->line('Title: ' . $this->article->title)
            ->action('View Article', url('/writer/dashboard'))
            ->line('Please review the feedback and revise your article.');
    }
}
