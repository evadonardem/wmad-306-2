<?php

namespace App\Mail;

use App\Models\Article;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ArticleSubmittedMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     */
    public function __construct(
        public Article $article,
        public User $editor = null
    ) {
        $this->article = $article;
        $this->editor = $editor;
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
            view: 'emails.article-submitted',
            with: [
                'article' => $this->article,
                'editor' => $this->editor,
                'writerName' => $this->article->writer->name,
                'actionUrl' => route('editor.articles.review', $this->article),
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
        return "New Article Submitted: {$this->article->title}";
    }
}
