import { Head } from '@inertiajs/react';
import ArticleForm from './ArticleForm';

export default function Edit({ article, categories = [] }) {
    return (
        <>
            <Head title="Edit Article" />
            <ArticleForm article={article} categories={categories} isEdit />
        </>
    );
}
