import { Head, Link, useForm } from '@inertiajs/react';
import JoditEditor from '@/Components/JoditEditor';

export default function Review({ article }) {
    const { data, setData, post, processing, errors } = useForm({ comments: '' });

    const submitRevisionRequest = (e) => {
        e.preventDefault();
        post(route('editor.articles.request-revision', article.id));
    };

    return (
        <>
            <Head title="Review Article" />
            <div className="p-6 max-w-5xl mx-auto space-y-6">
                <div>
                    <h1 className="text-2xl font-bold">{article?.title}</h1>
                    <p className="text-gray-600">By {article?.writer?.name || 'Unknown writer'}</p>
                </div>

                <JoditEditor value={article?.content || ''} onChange={() => {}} disabled showToolbar={false} />

                <div className="flex gap-3">
                    <Link
                        href={route('editor.articles.edit', article.id)}
                        className="inline-flex items-center px-4 py-2 rounded bg-slate-700 text-white"
                    >
                        Edit with Jodit
                    </Link>
                    <button
                        type="button"
                        onClick={() => post(route('editor.articles.publish', article.id))}
                        className="inline-flex items-center px-4 py-2 rounded bg-green-700 text-white"
                        disabled={processing}
                    >
                        Publish
                    </button>
                </div>

                <form onSubmit={submitRevisionRequest} className="space-y-3">
                    <label className="block text-sm font-medium">Request revision comments</label>
                    <textarea
                        value={data.comments}
                        onChange={(e) => setData('comments', e.target.value)}
                        rows={4}
                        className="w-full border rounded p-2"
                    />
                    {errors.comments && <p className="text-sm text-red-600">{errors.comments}</p>}
                    <button
                        type="submit"
                        className="inline-flex items-center px-4 py-2 rounded bg-amber-700 text-white"
                        disabled={processing}
                    >
                        Request Revision
                    </button>
                </form>
            </div>
        </>
    );
}
