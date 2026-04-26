<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Notifications\Notification;

class RevisionRequestedNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(
        public Article $article,
        public User $editor,
        public string $comments
    ) {
        parent::__construct();
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable): array
    {
        return ['mail', 'database'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail($notifiable): Mailable
    {
        return (new \App\Mail\RevisionRequestedMail($this->article, $this->editor, $this->comments))
            ->to($notifiable->email)
            ->subject($this->getSubject());
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable): array
    {
        return [
            'article_id' => $this->article->id,
            'article_title' => $this->article->title,
            'editor_name' => $this->editor->name,
            'editor_email' => $this->editor->email,
            'revision_comments' => $this->comments,
            'requested_at' => now()->toISOString(),
            'action_url' => route('writer.articles.revise', $this->article),
            'message' => $this->getMessage($notifiable),
        ];
    }

    /**
     * Get the notification subject.
     */
    private function getSubject(): string
    {
        return "Revision Requested: {$this->article->title}";
    }

    /**
     * Get the notification message.
     */
    private function getMessage($notifiable): string
    {
        $writerName = $this->article->writer->name;
        $articleTitle = $this->article->title;
        $editorName = $this->editor->name;
        
        return "Your article '{$articleTitle}' has been reviewed by {$editorName}. Please make the requested revisions and resubmit.";
    }

    /**
     * Get the notification type for database storage.
     */
    public function databaseType(): string
    {
        return 'revision_requested';
    }
}
