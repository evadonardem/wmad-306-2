import React from 'react';

export default function Users({ users = [] }) {
    return (
        <div className="container mx-auto p-6">
            <h1 className="text-3xl font-bold mb-6">Users List</h1>

            {users.length > 0 ? (
                <div className="overflow-x-auto">
                    <table className="min-w-full bg-white border border-gray-300 rounded-lg shadow">
                        <thead>
                            <tr className="bg-gray-200">
                                <th className="px-6 py-3 text-left font-semibold text-gray-700">ID</th>
                                <th className="px-6 py-3 text-left font-semibold text-gray-700">Name</th>
                                <th className="px-6 py-3 text-left font-semibold text-gray-700">Email</th>
                                <th className="px-6 py-3 text-left font-semibold text-gray-700">Created At</th>
                            </tr>
                        </thead>
                        <tbody>
                            {users.map((user) => (
                                <tr key={user.id} className="border-t hover:bg-gray-50">
                                    <td className="px-6 py-3 text-gray-700">{user.id}</td>
                                    <td className="px-6 py-3 text-gray-700">{user.name}</td>
                                    <td className="px-6 py-3 text-gray-700">{user.email}</td>
                                    <td className="px-6 py-3 text-gray-700">
                                        {new Date(user.created_at).toLocaleDateString()}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            ) : (
                <p className="text-gray-500">No users found.</p>
            )}
        </div>
    );
}
