import { Head, Link } from '@inertiajs/react';

export default function Welcome({ auth, articles }) {
    return (
        <>
            <Head title="Welcome - SAPP" />
            <div className="relative min-h-screen bg-gray-50 selection:bg-indigo-600 selection:text-white">
                
                {/* --- NAVIGATION HEADER --- */}
                <nav className="sticky top-0 z-10 w-full border-b border-gray-200 bg-white/80 backdrop-blur-md">
                    <div className="mx-auto flex max-w-7xl items-center justify-between p-4 px-6">
                        {/* Branding */}
                        <div className="flex items-center gap-2">
                            <div className="h-8 w-8 rounded bg-indigo-600 flex items-center justify-center text-white font-bold">S</div>
                            <span className="text-xl font-bold tracking-tight text-gray-900">SAPP</span>
                        </div>

                        {/* Action Buttons */}
                        <div className="flex items-center gap-4">
                            {auth.user ? (
                                <Link
                                    href={auth.user.role?.toLowerCase() === 'editor' 
                                        ? route('editor.dashboard') 
                                        : route('dashboard')
                                    }
                                    className="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 transition"
                                >
                                    Go to Dashboard
                                </Link>
                            ) : (
                                <>
                                    <Link
                                        href={route('login')}
                                        className="text-sm font-semibold leading-6 text-gray-900 hover:text-indigo-600 transition"
                                    >
                                        Log in
                                    </Link>
                                    <Link
                                        href={route('register')}
                                        className="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 transition"
                                    >
                                        Register
                                    </Link>
                                </>
                            )}
                        </div>
                    </div>
                </nav>

                {/* --- HERO SECTION --- */}
                <main className="mx-auto max-w-7xl px-6 py-16">
                    <header className="mb-16 text-center">
                        <h1 className="text-4xl font-extrabold tracking-tight text-gray-900 sm:text-6xl">
                            Student Article <span className="text-indigo-600">Publication</span> Platform
                        </h1>
                        <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-gray-600">
                            The official hub for student voices. Read verified academic works, sports updates, and campus news.
                        </p>
                    </header>

                    {/* --- PUBLISHED ARTICLES GALLERY --- */}
                    <div className="grid grid-cols-1 gap-x-8 gap-y-10 md:grid-cols-2 lg:grid-cols-3">
                        {articles && articles.length > 0 ? (
                            articles.map((article) => (
                                <article 
                                    key={article.id} 
                                    className="flex flex-col items-start justify-between rounded-2xl bg-white p-8 shadow-sm ring-1 ring-gray-200 transition-all hover:shadow-md"
                                >
                                    <div className="flex items-center gap-x-4 text-xs">
                                        <time className="text-gray-500">
                                            {new Date(article.created_at).toLocaleDateString()}
                                        </time>
                                        <span className="relative z-10 rounded-full bg-indigo-50 px-3 py-1.5 font-medium text-indigo-600 uppercase">
                                            {article.category?.name || 'Article'}
                                        </span>
                                    </div>
                                    <div className="group relative">
                                        <h3 className="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                                            <Link href={route('articles.show', article.id)}>
                                                <span className="absolute inset-0" />
                                                {article.title}
                                            </Link>
                                        </h3>
                                        <p className="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">
                                            {article.content?.substring(0, 120)}...
                                        </p>
                                    </div>
                                    <div className="relative mt-8 flex items-center gap-x-4">
                                        <div className="text-sm leading-6">
                                            <p className="font-semibold text-gray-900">
                                                <span className="absolute inset-0" />
                                                {article.user?.name}
                                            </p>
                                            <p className="text-gray-600">Student Writer</p>
                                        </div>
                                    </div>
                                </article>
                            ))
                        ) : (
                            <div className="col-span-full rounded-2xl border-2 border-dashed border-gray-200 py-24 text-center">
                                <h3 className="text-sm font-semibold text-gray-900">No articles yet</h3>
                                <p className="mt-1 text-sm text-gray-500">The publication queue is currently being reviewed by editors.</p>
                            </div>
                        )}
                    </div>
                </main>

                <footer className="mt-24 border-t border-gray-200 bg-white py-12">
                    <div className="mx-auto max-w-7xl px-6 text-center text-sm text-gray-500">
                        &copy; {new Date().getFullYear()} SAPP - Built with Laravel & React.
                    </div>
                </footer>
            </div>
        </>
    );
}