# Adopt-a-Dog Flutter App

A Flutter app that fetches real dog images from the Dog CEO API, displays them using Flutter's FutureBuilder and Image widgets, and remembers a user's favorite dog breed across app sessions using shared_preferences.

## Features

- 🐕 Scrollable list of dog breeds fetched from the Dog CEO API
- 📸 Tap any breed to see a random image of that breed
- ❤️ Heart button to save your favorite breed — it is remembered the next time you open the app
- ⭐ Favorites screen that shows the last saved breed and its image

## How to Run

1. Make sure you have Flutter installed on your system
2. Navigate to the project directory: `cd adopt_a_dog`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── breed.dart           # Breed model class
├── screens/
│   ├── breed_list_screen.dart     # Main screen showing all breeds
│   ├── breed_detail_screen.dart   # Screen showing breed details and random image
│   └── favorites_screen.dart      # Screen showing saved favorite breed
└── services/
    ├── dog_api_service.dart       # API service for fetching dog data
    └── prefs_service.dart         # Service for managing shared preferences
```

## Dependencies

- `flutter`: Flutter SDK
- `http`: ^1.6.0 - For making HTTP requests to Dog CEO API
- `shared_preferences`: ^2.5.4 - For persisting favorite breed locally
- `cupertino_icons`: ^1.0.8 - For iOS-style icons

## API Used

- Dog CEO API: https://dog.ceo/api/
  - `/breeds/list/all` - Fetch all dog breeds
  - `/breed/{breed}/images/random` - Fetch random image for a specific breed

## Testing the App

1. Open the app to see the list of dog breeds
2. Tap on any breed to view a random image
3. Use the heart button to save the breed as favorite
4. Navigate to the Favorites screen to see your saved breed
5. Close and reopen the app to verify the favorite is persisted
6. Use the delete button on the Favorites screen to clear your favorite
