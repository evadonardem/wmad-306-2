import { Head } from '@inertiajs/react';
import ArticleForm from './ArticleForm';

export default function Create({ categories = [] }) {
    return (
        <>
            <Head title="Create Article" />
            <ArticleForm categories={categories} />
        </>
    );
}
