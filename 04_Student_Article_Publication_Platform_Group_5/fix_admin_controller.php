<?php

echo "=== Fixing AdminController Issues ===\n\n";

// 1. Check if we're in the right directory
if (!file_exists('artisan')) {
    echo "❌ Error: Please run this script from the Laravel project root directory.\n";
    echo "Current directory: " . getcwd() . "\n";
    echo "Look for the 'artisan' file and run this script from that directory.\n";
    exit(1);
}

echo "✅ Found artisan file - correct directory\n\n";

// 2. Check if AdminController exists
$controllerPath = 'app/Http/Controllers/AdminController.php';
if (!file_exists($controllerPath)) {
    echo "❌ AdminController not found at: {$controllerPath}\n";
    echo "Creating AdminController...\n";
    
    // Create the AdminController file
    $controllerContent = '<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\RoleRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;
use Inertia\Inertia;

class AdminController extends Controller
{
    public function __construct()
    {
        $this->middleware([\'auth\', \'role:admin\']);
    }

    /**
     * Display the admin dashboard.
     */
    public function dashboard()
    {
        $stats = [
            \'total_users\' => User::count(),
            \'students\' => User::role(\'student\')->count(),
            \'writers\' => User::role(\'writer\')->count(),
            \'editors\' => User::role(\'editor\')->count(),
            \'pending_requests\' => RoleRequest::pending()->count(),
        ];

        $recentUsers = User::latest()
            ->take(5)
            ->get([\'id\', \'name\', \'email\', \'created_at\']);

        $pendingRequests = RoleRequest::with(\'user\')
            ->pending()
            ->latest()
            ->take(10)
            ->get();

        return Inertia::render(\'Admin/Dashboard\', [
            \'stats\' => $stats,
            \'recentUsers\' => $recentUsers,
            \'pendingRequests\' => $pendingRequests,
        ]);
    }

    /**
     * Display all users for management.
     */
    public function users()
    {
        $users = User::with(\'roles\')
            ->latest()
            ->get();

        return Inertia::render(\'Admin/Users\', [
            \'users\' => $users,
        ]);
    }

    /**
     * Update user role.
     */
    public function updateUserRole(Request $request, User $user)
    {
        $request->validate([
            \'role\' => \'required|in:student,writer,editor,admin\',
        ]);

        // Remove all existing roles
        $user->roles()->detach();
        
        // Assign new role
        $user->assignRole($request->role);

        return back()->with(\'success\', "User role updated to {$request->role} successfully.");
    }

    /**
     * Display all role requests.
     */
    public function roleRequests()
    {
        $requests = RoleRequest::with([\'user\', \'approvedBy\'])
            ->latest()
            ->get();

        return Inertia::render(\'Admin/RoleRequests\', [
            \'requests\' => $requests,
        ]);
    }

    /**
     * Approve a role request.
     */
    public function approveRoleRequest(RoleRequest $roleRequest)
    {
        Gate::authorize(\'manage-role-requests\');

        $roleRequest->update([
            \'status\' => \'approved\',
            \'approved_by\' => Auth::id(),
        ]);

        // Assign the requested role to the user
        $roleRequest->user->assignRole($roleRequest->requested_role);

        return back()->with(\'success\', \'Role request approved successfully.\');
    }

    /**
     * Reject a role request.
     */
    public function rejectRoleRequest(Request $request, RoleRequest $roleRequest)
    {
        Gate::authorize(\'manage-role-requests\');

        $request->validate([
            \'admin_notes\' => \'nullable|string|max:500\',
        ]);

        $roleRequest->update([
            \'status\' => \'rejected\',
            \'approved_by\' => Auth::id(),
            \'admin_notes\' => $request->admin_notes,
        ]);

        return back()->with(\'success\', \'Role request rejected.\');
    }

    /**
     * Display user details.
     */
    public function userDetail(User $user)
    {
        $user->load([\'roles\', \'articles\', \'roleRequests\' => function($query) {
            $query->latest();
        }]);

        return Inertia::render(\'Admin/UserDetail\', [
            \'user\' => $user,
        ]);
    }

    /**
     * Delete a user.
     */
    public function deleteUser(User $user)
    {
        Gate::authorize(\'delete-users\');

        if ($user->id === Auth::id()) {
            return back()->with(\'error\', \'You cannot delete your own account.\');
        }

        $user->delete();

        return back()->with(\'success\', \'User deleted successfully.\');
    }
}';
    
    file_put_contents($controllerPath, $controllerContent);
    echo "✅ AdminController created\n";
} else {
    echo "✅ AdminController already exists\n";
}

// 3. Clear autoloader
echo "\nClearing autoloader...\n";
system('composer dump-autoload');

// 4. Clear cache
echo "Clearing Laravel cache...\n";
system('php artisan cache:clear');
system('php artisan config:clear');
system('php artisan route:clear');

// 5. Test the controller
echo "\nTesting AdminController...\n";
try {
    if (class_exists('App\Http\Controllers\AdminController')) {
        echo "✅ AdminController class found\n";
    } else {
        echo "❌ AdminController class not found\n";
    }
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

echo "\n=== Testing Routes ===\n";
system('php artisan route:list --name=admin');

echo "\n=== Setup Complete ===\n";
echo "Try running: php artisan route:list\n";
echo "If still having issues, restart your Laravel server: php artisan serve\n";
