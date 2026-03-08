<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title inertia>User Mail App</title>

    @viteReactRefresh
    @vite('resources/js/app.jsx')
    @inertiaHead
  </head>

  <body style="margin:0; background:#020617; color:#e5e7eb;">
    <header style="
      padding:1rem 1.5rem;
      border-bottom:1px solid #1e293b;
      font-family:system-ui;
    ">
      <strong>📨 User Mail</strong>
    </header>

    @inertia
  </body>
</html>
