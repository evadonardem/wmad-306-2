<?php

namespace App\Http\Controllers;

use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class ErrorController extends Controller
{
    /**
     * Display the 403 Forbidden error page.
     */
    public function forbidden(): InertiaResponse
    {
        return Inertia::render('Errors/ForbiddenError');
    }
}
