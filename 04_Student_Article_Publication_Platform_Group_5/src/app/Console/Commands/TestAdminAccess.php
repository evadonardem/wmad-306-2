<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestAdminAccess extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:test-admin-access';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Testing admin access...');
        
        // Get admin user
        $admin = \App\Models\User::where('email', 'admin@example.com')->with('roles')->first();
        
        if (!$admin) {
            $this->error('Admin user not found!');
            return 1;
        }
        
        $this->info('Admin user found:');
        $this->info('  Email: ' . $admin->email);
        $this->info('  Name: ' . $admin->name);
        $this->info('  Roles: ' . $admin->roles->pluck('name')->join(', '));
        $this->info('  Has admin role: ' . ($admin->hasRole('admin') ? 'YES' : 'NO'));
        
        // Test role middleware simulation
        $this->info('\nTesting role middleware simulation...');
        
        // Simulate what the middleware does
        if (!$admin->hasRole('admin')) {
            $this->error('  ❌ User would be redirected by role middleware');
        } else {
            $this->info('  ✅ User passes role middleware check');
        }
        
        // Test all admin routes
        $this->info('\nTesting admin routes...');
        $routes = [
            'admin.dashboard' => '/admin/dashboard',
            'admin.users' => '/admin/users',
            'admin.role-requests' => '/admin/role-requests'
        ];
        
        foreach ($routes as $name => $path) {
            try {
                $url = route($name);
                $this->info('  ✅ ' . $name . ': ' . $url);
            } catch (\Exception $e) {
                $this->error('  ❌ ' . $name . ': ' . $e->getMessage());
            }
        }
        
        return 0;
    }
}
