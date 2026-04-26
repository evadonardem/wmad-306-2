import { Head, Link } from '@inertiajs/react';

export default function Revisions({ article }) {
    return (
        <>
            <Head title="Article Revisions" />
            <div className="p-6 max-w-4xl mx-auto">
                <h1 className="text-2xl font-bold mb-2">{article?.title}</h1>
                <p className="text-gray-600 mb-6">All revisions</p>

                <div className="space-y-4">
                    {(article?.revisions || []).map((revision) => (
                        <div key={revision.id} className="border rounded-lg p-4 bg-white">
                            <p className="font-semibold">{revision.editor?.name || 'Editor'}</p>
                            <p className="text-sm text-gray-500 mb-2">
                                {revision.created_at ? new Date(revision.created_at).toLocaleString() : 'N/A'}
                            </p>
                            <p className="whitespace-pre-wrap">{revision.comments}</p>
                        </div>
                    ))}

                    {(article?.revisions || []).length === 0 && (
                        <p className="text-gray-600">No revisions yet.</p>
                    )}
                </div>

                <div className="mt-6">
                    <Link href={route('editor.dashboard')} className="text-blue-600 hover:underline">
                        Back to dashboard
                    </Link>
                </div>
            </div>
        </>
    );
}
