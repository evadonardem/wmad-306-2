import { Head, Link } from '@inertiajs/react';

export default function Show({ article }) {
    return (
        <>
            <Head title={article?.title || 'Article'} />
            <div className="p-6 max-w-5xl mx-auto">
                <div className="mb-6">
                    <h1 className="text-3xl font-bold mb-2">{article?.title}</h1>
                    <p className="text-gray-600">
                        Status: {article?.status?.name || 'Unknown'} | Category: {article?.category?.name || 'None'}
                    </p>
                </div>

                <article className="bg-white border rounded-lg p-6 mb-8">
                    <div dangerouslySetInnerHTML={{ __html: article?.content || '' }} />
                </article>

                <div className="flex gap-3 mb-8">
                    <Link href={route('writer.articles.edit', article.id)} className="px-4 py-2 rounded bg-blue-700 text-white">
                        Edit Article
                    </Link>
                    <Link href={route('writer.articles.revisions', article.id)} className="px-4 py-2 rounded bg-slate-700 text-white">
                        View Revisions
                    </Link>
                    <Link href={route('writer.dashboard')} className="px-4 py-2 rounded border">
                        Back to Dashboard
                    </Link>
                </div>

                <section className="mb-8">
                    <h2 className="text-xl font-semibold mb-3">Revision History</h2>
                    <div className="space-y-3">
                        {(article?.revisions || []).map((revision) => (
                            <div key={revision.id} className="border rounded p-3 bg-white">
                                <p className="font-semibold">{revision.editor?.name || 'Editor'}</p>
                                <p className="text-sm text-gray-500 mb-1">
                                    {revision.created_at ? new Date(revision.created_at).toLocaleString() : 'N/A'}
                                </p>
                                <p>{revision.comments}</p>
                            </div>
                        ))}
                        {(article?.revisions || []).length === 0 && <p className="text-gray-600">No revisions yet.</p>}
                    </div>
                </section>
            </div>
        </>
    );
}
