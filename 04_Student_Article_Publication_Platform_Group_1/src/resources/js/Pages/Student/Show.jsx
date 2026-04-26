import { Head, Link, useForm } from '@inertiajs/react';

export default function Show({ article, relatedArticles = [] }) {
    const { data, setData, post, processing, errors, reset } = useForm({ content: '' });

    const handleGoBack = () => {
        if (typeof window !== 'undefined' && window.history.length > 1) {
            window.history.back();
            return;
        }

        window.location.href = route('student.dashboard');
    };

    const submitComment = (e) => {
        e.preventDefault();
        post(route('student.articles.comment', article.id), {
            onSuccess: () => reset('content')
        });
    };

    return (
        <>
            <Head title={article?.title || 'Article'} />
            <div className="p-6 max-w-5xl mx-auto space-y-8 text-slate-900">
                <button
                    type="button"
                    onClick={handleGoBack}
                    className="inline-flex items-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-2 font-medium text-slate-800 transition hover:bg-slate-100"
                >
                    <span aria-hidden="true">←</span>
                    Back
                </button>

                <article className="bg-white border rounded-lg p-6 text-slate-900">
                    <h1 className="text-3xl font-bold mb-2 text-slate-900">{article?.title}</h1>
                    <p className="text-slate-700 mb-6">By {article?.writer?.name || 'Unknown writer'}</p>
                    <div className="text-slate-800" dangerouslySetInnerHTML={{ __html: article?.content || '' }} />
                </article>

                <section className="bg-white border rounded-lg p-6 text-slate-900">
                    <h2 className="text-xl font-semibold mb-4 text-slate-900">Comments</h2>
                    <form onSubmit={submitComment} className="space-y-3 mb-6">
                        <textarea
                            value={data.content}
                            onChange={(e) => setData('content', e.target.value)}
                            rows={4}
                            className="w-full border rounded p-2 bg-white text-slate-900 placeholder:text-slate-500"
                            placeholder="Write a comment"
                        />
                        {errors.content && <p className="text-sm text-red-600">{errors.content}</p>}
                        <button type="submit" disabled={processing} className="px-4 py-2 rounded bg-blue-700 text-white">
                            Post Comment
                        </button>
                    </form>

                    <div className="space-y-3">
                        {(article?.comments || []).map((comment) => (
                            <div key={comment.id} className="border rounded p-3 bg-slate-50 text-slate-900">
                                <p className="font-semibold text-slate-900">{comment.student?.name || 'Student'}</p>
                                <p className="text-slate-800">{comment.content}</p>
                            </div>
                        ))}
                    </div>
                </section>

                <section className="bg-white border rounded-lg p-6 text-slate-900">
                    <h2 className="text-xl font-semibold mb-3 text-slate-900">Related Articles</h2>
                    <div className="space-y-2">
                        {relatedArticles.map((related) => (
                            <Link key={related.id} href={route('student.articles.show', related.id)} className="block text-blue-700 hover:underline">
                                {related.title}
                            </Link>
                        ))}
                    </div>
                </section>
            </div>
        </>
    );
}
