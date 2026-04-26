<?php

namespace App\Mail;

use App\Models\Comment;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class CommentPostedMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     */
    public function __construct(
        public Comment $comment
    ) {
        $this->comment = $comment;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): \Illuminate\Mail\Envelope
    {
        return new \Illuminate\Mail\Envelope(
            subject: $this->getSubject(),
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): \Illuminate\Mail\Content
    {
        return new \Illuminate\Mail\Content(
            view: 'emails.comment-posted',
            with: [
                'comment' => $this->comment,
                'article' => $this->comment->article,
                'writerName' => $this->comment->article->writer->name,
                'actionUrl' => route('student.articles.show', $this->comment->article),
            ],
        );
    }

    /**
     * Get the attachments for the message.
     */
    public function attachments(): array
    {
        return [];
    }

    /**
     * Get the notification subject.
     */
    private function getSubject(): string
    {
        return "New Comment on: {$this->comment->article->title}";
    }
}
