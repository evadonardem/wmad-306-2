import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, usePage } from '@inertiajs/react';
import { Box } from '@mui/material';

export default function Dashboard() {
    const { recentPublications = [] } = usePage().props;

    const publicationCards = recentPublications.length > 0 ? recentPublications : [
        { id: 'placeholder-1', title: 'Campus Sustainability Initiatives', content: 'Sample publication preview text.', writer: { name: 'Editorial Team' }, category: { name: 'Campus Life' }, cover_image_url: null },
        { id: 'placeholder-2', title: 'Research Spotlight: AI in Education', content: 'Sample publication preview text.', writer: { name: 'Editorial Team' }, category: { name: 'Technology' }, cover_image_url: null },
        { id: 'placeholder-3', title: 'Student Voices: Community Service', content: 'Sample publication preview text.', writer: { name: 'Editorial Team' }, category: { name: 'Culture' }, cover_image_url: null },
    ];

    // Streamlined animations just for the feed cards
    const cardAnimations = `
        @keyframes reveal-up {
            0% { transform: translateY(40px); opacity: 0; filter: blur(4px); }
            100% { transform: translateY(0); opacity: 1; filter: blur(0); }
        }
        .animate-reveal-0 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
        .animate-reveal-1 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
        .animate-reveal-2 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
        
        .bento-card:hover .bento-img { transform: scale(1.08); }
    `;

    return (
        <AuthenticatedLayout fullWidth={true}>
            <Head title="Home Feed" />
            <style>{cardAnimations}</style>

            <Box className="w-full">
                {/* Publication Feed Section */}
                <section className="dashboard-feed-section py-12 sm:py-16 transition-colors duration-300">
                    <div className="dashboard-feed-wrap mx-auto max-w-7xl px-4 lg:px-8">
                        <div className="dashboard-feed-header mb-10">
                            <h1 className="text-3xl font-black tracking-tight text-gray-900 dark:text-white sm:text-4xl">
                                Latest Publications
                            </h1>
                            <p className="mt-2 text-lg text-gray-600 dark:text-gray-400">
                                Discover the newest stories, research, and campus news.
                            </p>
                        </div>
                        
                        <div className="dashboard-feed-grid grid max-w-2xl grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-3">
                            {publicationCards.map((publication, i) => (
                                <article 
                                    key={publication.id} 
                                    className={`dashboard-feed-card bento-card group flex flex-col bg-white dark:bg-gray-800/80 rounded-[2rem] shadow-sm border border-gray-100 dark:border-gray-700/50 overflow-hidden hover:shadow-[0_20px_40px_rgb(47,111,219,0.1)] hover:-translate-y-2 transition-all duration-500 will-change-transform animate-reveal-${i % 3}`}
                                >
                                    {/* Image Half */}
                                    <div className="dashboard-feed-image relative w-full h-56 shrink-0 overflow-hidden bg-gray-200 dark:bg-gray-900">
                                        <img
                                            src={publication.cover_image_url || 'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=1200&q=80'}
                                            alt={publication.title}
                                            className="bento-img absolute inset-0 h-full w-full object-cover transition-transform duration-700 ease-out"
                                        />
                                        <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
                                        
                                        <div className="absolute top-4 left-4">
                                            <span className="inline-flex items-center rounded-full bg-white/90 dark:bg-black/50 backdrop-blur-md px-3 py-1 text-xs font-black uppercase tracking-wider text-[#2f6fdb]">
                                                {publication.category?.name || 'General'}
                                            </span>
                                        </div>
                                    </div>
                                    {/* Content Half */}
                                    <div className="dashboard-feed-content flex flex-1 flex-col justify-between p-6 sm:p-8">
                                        <div className="flex-1">
                                            <h3 className="dashboard-feed-title text-xl sm:text-2xl font-bold leading-tight text-gray-900 dark:text-white group-hover:text-[#2f6fdb] transition-colors line-clamp-2">
                                                {publication.title}
                                            </h3>
                                            <p className="mt-4 line-clamp-3 text-sm sm:text-base leading-relaxed text-gray-600 dark:text-gray-400">
                                                {(publication.content || '').replace(/<[^>]*>?/gm, '')}
                                            </p>
                                        </div>
                                        
                                        {/* Footer Area */}
                                        {/* Footer Area */}
                                        <div className="mt-6 pt-6 border-t border-gray-200/60 dark:border-gray-700/60">
                                            <div className="flex flex-wrap items-center gap-2 mb-4">
                                                <p className="text-xs sm:text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide">
                                                    By {publication.writer?.name || 'Anonymous'}
                                                </p>
                                                
                                                {/* Writer Tier Badge */}
                                                <span className="inline-flex items-center rounded-md bg-[#2f6fdb]/10 px-2 py-1 text-[10px] font-black uppercase tracking-wider text-[#2f6fdb]">
                                                    {publication.writer?.writer_tier || 'Entry-Level Writer'}
                                                </span>
                                            </div>
                                            
                                            <Link 
                                                href={route('publications.show', publication.id)} 
                                                className="flex w-full items-center justify-center gap-2 rounded-xl bg-gray-50 dark:bg-gray-900 px-4 py-3 text-sm font-bold text-[#2f6fdb] shadow-sm ring-1 ring-inset ring-gray-200 dark:ring-gray-700 hover:bg-[#2f6fdb] hover:text-white hover:ring-transparent transition-all duration-300"
                                            >
                                                Read Article <span aria-hidden="true" className="text-lg leading-none">&rarr;</span>
                                            </Link>
                                        </div>
                                    </div>
                                </article>
                            ))}
                        </div>
                    </div>
                </section>
                
                {/* Minimal Footer */}
                <footer className="dashboard-feed-footer py-8 transition-colors duration-300">
                    <div className="mx-auto max-w-7xl px-6 lg:px-8 text-center">
                        <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                            © {new Date().getFullYear()} Campus Press. All rights reserved.
                        </p>
                    </div>
                </footer>
            </Box>
        </AuthenticatedLayout>
    );
}