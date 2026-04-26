<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Notifications\Notification;

class ArticlePublishedNotification extends Notification
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
        return (new \App\Mail\ArticlePublishedMail($this->article, $this->editor))
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
            'editor_name' => $this->editor ? $this->editor->name : 'System',
            'editor_email' => $this->editor ? $this->editor->email : null,
            'published_at' => $this->article->updated_at->toISOString(),
            'action_url' => route('student.articles.show', $this->article),
            'message' => $this->getMessage($notifiable),
        ];
    }

    /**
     * Get the notification subject.
     */
    private function getSubject(): string
    {
        return "Article Published: {$this->article->title}";
    }

    /**
     * Get the notification message.
     */
    private function getMessage($notifiable): string
    {
        $writerName = $this->article->writer->name;
        $articleTitle = $this->article->title;
        $editorName = $this->editor ? $this->editor->name : 'the editorial team';
        
        return "Congratulations {$writerName}! Your article '{$articleTitle}' has been published by {$editorName} and is now live for students to read.";
    }

    /**
     * Get the notification type for database storage.
     */
    public function databaseType(): string
    {
        return 'article_published';
    }
}
