<?php

namespace App\Mail;

use App\Models\Article;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class RevisionRequestedMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     */
    public function __construct(
        public Article $article,
        public User $editor,
        public string $comments
    ) {
        $this->article = $article;
        $this->editor = $editor;
        $this->comments = $comments;
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
            view: 'emails.revision-requested',
            with: [
                'article' => $this->article,
                'editor' => $this->editor,
                'comments' => $this->comments,
                'writerName' => $this->article->writer->name,
                'actionUrl' => route('writer.articles.revise', $this->article),
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
        return "Revision Requested: {$this->article->title}";
    }
}
