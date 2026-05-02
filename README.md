# wmad-306-2

## Local CORS proxy for Superhero API

To run the web app without browser CORS blocking, start the proxy first:

```powershell
cd c:\Users\PatrickLaron\wmad-306-2
dart proxy_server.dart
```

Then launch the Flutter web app:

```powershell
cd hero_battle
flutter run -d chrome
```
