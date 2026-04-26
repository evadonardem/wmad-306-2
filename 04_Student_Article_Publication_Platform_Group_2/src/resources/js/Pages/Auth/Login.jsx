import { Head, useForm } from '@inertiajs/react';
import ModernAuthForm from '@/Components/ModernAuthForm';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        post(route('login'), {
            onFinish: () => reset('password'),
        });
    };

    return (
        <>
            <Head title="Log in" />
            <ModernAuthForm
                isLogin={true}
                onSubmit={handleSubmit}
                formData={data}
                setFormData={setData}
                errors={errors}
                processing={processing}
                status={status}
            />
        </>
    );
}
