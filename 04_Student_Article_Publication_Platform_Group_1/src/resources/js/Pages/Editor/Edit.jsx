import { Head } from '@inertiajs/react';
import ArticleForm from '@/Pages/Writer/ArticleForm';

export default function Edit({ article, categories = [] }) {
    return (
        <>
            <Head title="Editor Edit Article" />
            <ArticleForm
                article={article}
                categories={categories}
                isEdit
                updateRouteName="editor.articles.update"
                dashboardRouteName="editor.dashboard"
            />
        </>
    );
}
