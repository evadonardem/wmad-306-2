import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';

export default function Dashboard() {
    return (
        <AuthenticatedLayout
            header={
                <h2 className="text-xl font-semibold leading-tight text-gray-800">
                    Dashboard
                </h2>
            }
        >
            <Head title="Dashboard" />

            {/* UI-only layout */}
            <div
                className="min-h-screen"
                style={{ backgroundColor: '#f5f7fa' }}
            >
                {/* Add bottom padding so content is not covered by fixed footer */}
                <div className="pb-16">
                    <main className="py-8">
                        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                            {/* Top Card */}
                            <div className="mb-5 overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-200">
                                <div className="p-5 sm:p-6">
                                    <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                                        <div>
                                            <p className="text-[11px] font-semibold uppercase tracking-wider text-gray-500">
                                                Project Tracker
                                            </p>
                                            <h3 className="mt-1 text-base font-semibold text-gray-900">
                                                Welcome back
                                            </h3>
                                            <p className="mt-1 text-sm text-gray-600">
                                                Simple overview page (UI only).
                                            </p>
                                        </div>

                                        <span className="inline-flex items-center gap-2 rounded-full bg-emerald-50 px-3 py-1 text-xs font-medium text-emerald-700 ring-1 ring-emerald-200">
                                            <span className="h-2 w-2 rounded-full bg-emerald-500" />
                                            Active
                                        </span>
                                    </div>

                                    {/* Realistic note */}
                                    <div className="mt-4 rounded-xl bg-gray-50 p-3.5 ring-1 ring-gray-200">
                                        <p className="text-sm font-medium text-gray-900">
                                            You’re logged in.
                                        </p>
                                        <p className="mt-0.5 text-sm text-gray-600">
                                            Use the top navigation to open{' '}
                                            <span className="font-medium text-gray-800">Projects</span> and{' '}
                                            <span className="font-medium text-gray-800">Tasks</span>.
                                        </p>
                                    </div>
                                </div>
                            </div>

                            {/* Cards */}
                            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
                                <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-gray-200 transition hover:shadow-md">
                                    <div className="flex items-center justify-between">
                                        <p className="text-sm font-semibold text-gray-900">Projects</p>
                                        <span className="rounded-full bg-blue-50 px-2.5 py-1 text-[11px] font-medium text-blue-700 ring-1 ring-blue-100">
                                            CRUD
                                        </span>
                                    </div>
                                    <p className="mt-2.5 text-sm text-gray-600">
                                        Create, edit, and delete projects.
                                    </p>
                                    <div className="mt-4 h-1.5 w-full rounded-full bg-gray-100">
                                        <div className="h-1.5 w-2/3 rounded-full bg-gray-300" />
                                    </div>
                                    <p className="mt-2 text-xs text-gray-500">Simple and clean.</p>
                                </div>

                                <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-gray-200 transition hover:shadow-md">
                                    <div className="flex items-center justify-between">
                                        <p className="text-sm font-semibold text-gray-900">Tasks</p>
                                        <span className="rounded-full bg-purple-50 px-2.5 py-1 text-[11px] font-medium text-purple-700 ring-1 ring-purple-100">
                                            Status
                                        </span>
                                    </div>
                                    <p className="mt-2.5 text-sm text-gray-600">
                                        Add tasks with priority and toggle status.
                                    </p>
                                    <div className="mt-4 h-1.5 w-full rounded-full bg-gray-100">
                                        <div className="h-1.5 w-1/2 rounded-full bg-gray-300" />
                                    </div>
                                    <p className="mt-2 text-xs text-gray-500">Organized per project.</p>
                                </div>

                                <div className="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-gray-200 transition hover:shadow-md">
                                    <div className="flex items-center justify-between">
                                        <p className="text-sm font-semibold text-gray-900">System</p>
                                        <span className="rounded-full bg-gray-50 px-2.5 py-1 text-[11px] font-medium text-gray-700 ring-1 ring-gray-200">
                                            Ready
                                        </span>
                                    </div>
                                    <p className="mt-2.5 text-sm text-gray-600">
                                        Backend and frontend are running normally.
                                    </p>
                                    <div className="mt-4 h-1.5 w-full rounded-full bg-gray-100">
                                        <div className="h-1.5 w-5/6 rounded-full bg-gray-300" />
                                    </div>
                                    <p className="mt-2 text-xs text-gray-500">Dashboard is UI-only.</p>
                                </div>
                            </div>
                        </div>
                    </main>
                </div>

                {/* Sticky footer (always visible) */}
                <footer className="fixed bottom-0 left-0 w-full border-t border-gray-200 bg-white">
                    <div className="mx-auto flex max-w-7xl items-center justify-center px-4 py-3 text-center text-xs text-gray-500 sm:px-6 lg:px-8">
                        Project Tracker by Freddie Visaya
                    </div>
                </footer>
            </div>
        </AuthenticatedLayout>
    );
}
