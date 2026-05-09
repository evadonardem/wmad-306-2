<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Users</title>
        @vite('resources/css/app.css')
    </head>
    <body>
        <div id="app"></div>
        <script>
            window.users = @json($users);
        </script>
        @vite('resources/js/app.jsx')
    </body>
</html>

