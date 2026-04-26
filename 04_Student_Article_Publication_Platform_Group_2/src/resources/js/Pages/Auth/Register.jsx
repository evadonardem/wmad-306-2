import { Head, useForm } from '@inertiajs/react';
import ModernAuthForm from '@/Components/ModernAuthForm';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        post(route('register'), {
            onFinish: () => reset('password', 'password_confirmation'),
        });
    };

    return (
        <>
            <Head title="Register" />
            <ModernAuthForm
                isLogin={false}
                onSubmit={handleSubmit}
                formData={data}
                setFormData={setData}
                errors={errors}
                processing={processing}
            />
        </>
    );
}
