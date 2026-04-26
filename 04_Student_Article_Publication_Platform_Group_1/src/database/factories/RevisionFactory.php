<?php

namespace Database\Factories;

use App\Models\Revision;
use App\Models\Article;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Revision>
 */
class RevisionFactory extends Factory
{
    protected $model = Revision::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $revisionComments = [
            'Great article overall! However, I noticed a few areas that could be improved. The introduction could be more engaging, and some technical concepts need better explanation. Please consider adding more examples to help readers understand the complex topics.',
            
            'The content is well-researched and informative, but the structure needs work. Consider breaking down the longer paragraphs into shorter, more digestible sections. Also, please add a conclusion that summarizes the key takeaways for readers.',
            
            'I appreciate the depth of this article, but there are some clarity issues. Some technical terms are used without proper explanation. Please define key terms when first introduced and consider adding a glossary section for complex terminology.',
            
            'This is a solid foundation, but it needs more supporting evidence. Please add citations or references to back up your claims. Also, consider including real-world examples or case studies to make the content more relatable.',
            
            'The article has good flow, but the conclusion feels abrupt. Please expand the conclusion to provide better closure and perhaps suggest next steps for readers who want to learn more about this topic.',
            
            'Excellent technical content! However, the formatting needs improvement. Please use proper headings, subheadings, and bullet points to improve readability. Consider adding code blocks with syntax highlighting for technical examples.',
            
            'The research is thorough, but the writing style is too academic for our audience. Please simplify complex concepts and use more conversational language. Consider adding analogies to explain difficult concepts.',
            
            'Good coverage of the topic, but the article lacks visual elements. Please consider adding diagrams, charts, or screenshots to illustrate key concepts. Visual aids would greatly enhance reader understanding.',
        ];

        return [
            'article_id' => Article::factory(),
            'editor_id' => User::factory(),
            'comments' => $this->faker->randomElement($revisionComments),
        ];
    }
}
