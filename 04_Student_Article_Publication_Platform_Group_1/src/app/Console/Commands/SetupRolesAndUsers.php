<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Database\Seeders\QuickSetupSeeder;

class SetupRolesAndUsers extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:setup-roles';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Quick setup for roles, permissions, and test users';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Setting up roles, permissions, and test users...');
        
        $seeder = new QuickSetupSeeder();
        $seeder->run();
        
        $this->info('Setup completed successfully!');
        $this->newLine();
        $this->info('You can now login with:');
        $this->info('Writer: writer@test.com / password');
        $this->info('Editor: editor@test.com / password');
        $this->info('Student: student@test.com / password');
        $this->info('Admin: admin@test.com / password');
        
        return Command::SUCCESS;
    }
}
