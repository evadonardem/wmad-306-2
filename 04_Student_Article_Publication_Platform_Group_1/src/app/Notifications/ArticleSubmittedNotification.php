<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Notifications\Notification;

class ArticleSubmittedNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(
        public Article $article,
        public User $editor = null
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
        return (new \App\Mail\ArticleSubmittedMail($this->article, $notifiable))
            ->to($this->getEditorEmail($notifiable))
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
            'article_status' => $this->article->status->name,
            'writer_name' => $this->article->writer->name,
            'writer_email' => $this->article->writer->email,
            'submitted_at' => $this->article->updated_at->toISOString(),
            'action_url' => route('editor.articles.review', $this->article),
            'message' => $this->getMessage($notifiable),
        ];
    }

    /**
     * Get the notification subject.
     */
    private function getSubject(): string
    {
        return "New Article Submitted: {$this->article->title}";
    }

    /**
     * Get the notification message.
     */
    private function getMessage($notifiable): string
    {
        $writerName = $this->article->writer->name;
        $articleTitle = $this->article->title;
        
        return "New article '{$articleTitle}' has been submitted by {$writerName} and is ready for your review.";
    }

    /**
     * Get the target editor email.
     */
    private function getEditorEmail($notifiable): string
    {
        // If a specific editor is assigned, notify them
        if ($this->editor) {
            return $this->editor->email;
        }

        // Otherwise, notify all editors
        return $notifiable->email;
    }

    /**
     * Get the notification type for database storage.
     */
    public function databaseType(): string
    {
        return 'article_submitted';
    }
}
