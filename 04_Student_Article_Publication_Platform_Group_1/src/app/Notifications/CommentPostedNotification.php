<?php

namespace App\Notifications;

use App\Models\Article;
use App\Models\Comment;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Notifications\Notification;

class CommentPostedNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(
        public Comment $comment
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
        return (new \App\Mail\CommentPostedMail($this->comment))
            ->to($notifiable->email)
            ->subject($this->getSubject());
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable): array
    {
        return [
            'comment_id' => $this->comment->id,
            'article_id' => $this->comment->article->id,
            'article_title' => $this->comment->article->title,
            'student_name' => $this->comment->student->name,
            'student_email' => $this->comment->student->email,
            'comment_content' => $this->comment->content,
            'commented_at' => $this->comment->created_at->toISOString(),
            'action_url' => route('student.articles.show', $this->comment->article),
            'message' => $this->getMessage($notifiable),
        ];
    }

    /**
     * Get the notification subject.
     */
    private function getSubject(): string
    {
        return "New Comment on: {$this->comment->article->title}";
    }

    /**
     * Get the notification message.
     */
    private function getMessage($notifiable): string
    {
        $studentName = $this->comment->student->name;
        $articleTitle = $this->comment->article->title;
        $commentPreview = substr($this->comment->content, 0, 50) . (strlen($this->comment->content) > 50 ? '...' : '');
        
        return "A new comment has been posted on your article '{$articleTitle}' by {$studentName}: \"{$commentPreview}\"";
    }

    /**
     * Get the notification type for database storage.
     */
    public function databaseType(): string
    {
        return 'comment_posted';
    }
}
