<?php

namespace Database\Factories;

use App\Models\Comment;
use App\Models\Article;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Comment>
 */
class CommentFactory extends Factory
{
    protected $model = Comment::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $comments = [
            'This is exactly what I was looking for! The explanation is clear and the examples really helped me understand the concept. Thank you for taking the time to write such a comprehensive article.',
            
            'Great article! I especially appreciated the practical examples you included. It would be helpful if you could add a section about common pitfalls to avoid when implementing this approach.',
            
            'I found this article very informative, but I have a question about the third section. Could you elaborate more on the performance implications? Overall, excellent work!',
            
            'This is a fantastic resource for beginners. The step-by-step approach makes it easy to follow along. I\'ve already started implementing some of these techniques in my own projects.',
            
            'Excellent coverage of the topic! I\'ve been struggling with this concept for weeks, and your article finally made it click. The real-world examples were particularly helpful.',
            
            'Thank you for sharing this! I have one suggestion - consider adding a troubleshooting section for common issues that people might encounter. Otherwise, this is perfect.',
            
            'This article came at the perfect time! I\'m currently working on a project that needs exactly this functionality. Your detailed explanation saved me hours of research.',
            
            'I really enjoyed reading this! The writing style is engaging and the content is well-structured. I\'ve already shared this with my team members.',
            
            'Fantastic article! The depth of research shows in the quality of the content. I particularly appreciated the historical context you provided in the introduction.',
            
            'This is exactly what our community needed! The clear explanations and practical examples make this accessible to developers at all skill levels. Looking forward to more articles like this.',
        ];

        return [
            'article_id' => Article::factory()->published(),
            'student_id' => User::factory(),
            'content' => $this->faker->randomElement($comments),
        ];
    }
}
