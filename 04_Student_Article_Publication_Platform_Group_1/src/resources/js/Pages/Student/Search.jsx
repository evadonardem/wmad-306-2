import { Head, Link } from '@inertiajs/react';

export default function Search({ articles, query }) {
    const results = articles?.data || [];

    return (
        <>
            <Head title="Search Articles" />
            <div className="p-6 max-w-5xl mx-auto">
                <h1 className="text-2xl font-bold mb-2">Search results</h1>
                <p className="text-gray-600 mb-6">Query: {query}</p>

                <div className="space-y-4">
                    {results.map((article) => (
                        <div key={article.id} className="border rounded-lg p-4 bg-white">
                            <Link href={route('student.articles.show', article.id)} className="text-lg font-semibold text-blue-700 hover:underline">
                                {article.title}
                            </Link>
                            <p className="text-sm text-gray-600">By {article.writer?.name || 'Unknown writer'}</p>
                        </div>
                    ))}

                    {results.length === 0 && (
                        <p className="text-gray-600">No matching published articles found.</p>
                    )}
                </div>
            </div>
        </>
    );
}
