<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\Revision;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class RevisionRequestedNotification extends Notification
{
    use Queueable;

    protected $revision;

    public function __construct(Revision $revision)
    {
        $this->revision = $revision;
    }

    public function via($notifiable)
    {
        return ['mail', 'database'];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('Revision Requested')
            ->line('A revision has been requested for your article: '.$this->revision->article->title)
            ->line('Comments: '.$this->revision->comments)
            ->action('View Article', url(route('writer.dashboard')));
    }

    public function toArray($notifiable)
    {
        return [
            'revision_id' => $this->revision->id,
            'article_id' => $this->revision->article->id,
            'article_title' => $this->revision->article->title,
            'comments' => $this->revision->comments,
            'type' => 'revision_requested',
            'message' => 'Revision requested for: ' . $this->revision->article->title
        ];
    }
}
