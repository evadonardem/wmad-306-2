<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestAuth extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:test-auth';

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
        $this->info('Testing authentication...');
        
        // Check users
        $users = \App\Models\User::with('roles')->get();
        $this->info('Total users: ' . $users->count());
        
        foreach ($users as $user) {
            $this->info('User: ' . $user->email . ' | Roles: ' . $user->roles->pluck('name')->join(', '));
            
            // Test password verification
            if (\Hash::check('password', $user->password)) {
                $this->info('  ✓ Password "password" works for ' . $user->email);
            } else {
                $this->error('  ✗ Password "password" failed for ' . $user->email);
            }
        }
        
        return 0;
    }
}
