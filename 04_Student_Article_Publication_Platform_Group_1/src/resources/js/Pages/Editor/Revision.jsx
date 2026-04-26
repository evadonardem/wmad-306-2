import { Head, Link } from '@inertiajs/react';

export default function Revision({ article }) {
    const latestRevision = article?.revisions?.[0];

    return (
        <>
            <Head title="Latest Revision" />
            <div className="p-6 max-w-4xl mx-auto">
                <h1 className="text-2xl font-bold mb-4">Latest Revision</h1>
                {latestRevision ? (
                    <div className="border rounded-lg p-4 bg-white">
                        <p className="font-semibold">{latestRevision.editor?.name || 'Editor'}</p>
                        <p className="text-sm text-gray-500 mb-2">
                            {latestRevision.created_at ? new Date(latestRevision.created_at).toLocaleString() : 'N/A'}
                        </p>
                        <p className="whitespace-pre-wrap">{latestRevision.comments}</p>
                    </div>
                ) : (
                    <p className="text-gray-600">No revision found.</p>
                )}

                <div className="mt-6">
                    <Link href={route('editor.dashboard')} className="text-blue-600 hover:underline">
                        Back to dashboard
                    </Link>
                </div>
            </div>
        </>
    );
}
