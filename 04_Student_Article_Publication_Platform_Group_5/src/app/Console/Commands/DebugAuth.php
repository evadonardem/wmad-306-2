<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class DebugAuth extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:debug-auth';

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
        $this->info('Debugging authentication...');
        
        // Test admin user
        $admin = \App\Models\User::where('email', 'admin@example.com')->with('roles')->first();
        
        if ($admin) {
            $this->info('Admin user found:');
            $this->info('  Email: ' . $admin->email);
            $this->info('  Roles: ' . $admin->roles->pluck('name')->join(', '));
            $this->info('  Has admin role: ' . ($admin->hasRole('admin') ? 'YES' : 'NO'));
            
            // Test route existence
            try {
                $adminRoute = route('admin.dashboard');
                $this->info('  Admin dashboard route: ' . $adminRoute);
            } catch (\Exception $e) {
                $this->error('  Admin dashboard route error: ' . $e->getMessage());
            }
        } else {
            $this->error('Admin user not found!');
        }
        
        return 0;
    }
}
