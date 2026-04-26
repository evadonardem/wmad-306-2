import { Head, Link } from '@inertiajs/react';

export default function MyComments({ comments = [] }) {
    return (
        <>
            <Head title="My Comments" />

            <div className="min-h-screen bg-slate-950 text-slate-100 p-6">
                <div className="max-w-5xl mx-auto">
                    <div className="flex items-center justify-between mb-6">
                        <h1 className="text-3xl font-bold">My Comments</h1>
                        <Link
                            href={route('student.dashboard')}
                            className="px-4 py-2 rounded-md bg-slate-800 hover:bg-slate-700"
                        >
                            Back to Dashboard
                        </Link>
                    </div>

                    {comments.length === 0 ? (
                        <div className="bg-slate-900 border border-slate-700 rounded-lg p-8 text-center">
                            <p className="text-xl font-semibold mb-2">No comments yet</p>
                            <p className="text-slate-400 mb-4">Comment on a published article and it will appear here.</p>
                            <Link
                                href={route('student.dashboard')}
                                className="inline-block px-4 py-2 rounded-md bg-blue-600 hover:bg-blue-500 text-white"
                            >
                                Browse Articles
                            </Link>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {comments.map((comment) => (
                                <div key={comment.id} className="bg-slate-900 border border-slate-700 rounded-lg p-5">
                                    <h2 className="text-lg font-semibold text-white mb-1">
                                        {comment.article?.title || 'Untitled Article'}
                                    </h2>
                                    <p className="text-sm text-slate-400 mb-3">
                                        Author: {comment.article?.writer?.name || 'Unknown'}
                                    </p>

                                    <div className="bg-slate-800 border border-slate-700 rounded p-3 mb-3">
                                        <p className="text-slate-100 whitespace-pre-wrap">{comment.content}</p>
                                    </div>

                                    <div className="flex items-center justify-between">
                                        <p className="text-xs text-slate-500">
                                            {comment.created_at ? new Date(comment.created_at).toLocaleString() : ''}
                                        </p>
                                        {comment.article?.id && (
                                            <Link
                                                href={route('student.articles.show', comment.article.id)}
                                                className="text-sm text-blue-400 hover:underline"
                                            >
                                                View Article
                                            </Link>
                                        )}
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </>
    );
}
