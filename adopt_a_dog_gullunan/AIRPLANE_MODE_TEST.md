# Airplane Mode Test Guide - Image Caching

## Overview
The app now uses `CachedNetworkImage` which automatically caches images locally. This allows images to be displayed even when the device is in airplane mode (offline).

## What's Changed
1. **Added Dependency**: `cached_network_image: ^3.3.1` in `pubspec.yaml`
2. **Updated BreedDetailScreen**: 
   - Replaced `Image.network()` with `CachedNetworkImage()`
   - Added placeholder widget while loading
   - Added error widget for failed loads
   - Images are now cached to device storage automatically

## Manual Test Steps

### Test 1: Initial Load with Network
1. Run the app with network connectivity
2. Navigate to **BreedListScreen**
3. Select any breed (e.g., "Bulldog")
4. Wait for the image to load completely
5. The image is now cached locally
6. ✅ Verify: Image displays without issues

### Test 2: Airplane Mode - Cached Image Still Visible
1. Select a different breed and let it load (to cache another image)
2. Enable **Airplane Mode** on your device
3. Navigate back to the first breed you viewed
4. ✅ Verify: The previously cached image still displays
5. ✅ Verify: No error messages appear

### Test 3: Sub-breed Filtering Works Offline
1. With a breed that has sub-breeds (e.g., "Bulldog" with "French" sub-breed):
2. While in Airplane Mode, tap on the **"French"** chip
3. If that sub-breed image was previously loaded, it will display from cache
4. ✅ Verify: Navigation between chips works smoothly

### Test 4: Clear Cache / First Offline Load
1. Enable Airplane Mode
2. Navigate to a breed you haven't viewed before
3. ✅ Verify: Loading indicator appears
4. ✅ Verify: After timeout, error widget displays (expected behavior)

### Test 5: Resume Normal Operation
1. Disable Airplane Mode
2. Select the breed again
3. ✅ Verify: Image loads fresh from network
4. ✅ Verify: New image is cached for next offline access

## Technical Details

### CachedNetworkImage Features Used
```dart
CachedNetworkImage(
  imageUrl: snapshot.data!,          // URL to load
  height: 300,
  fit: BoxFit.cover,
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(),  // Shows while loading
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),  // Shows on error
)
```

### Cache Location
- **Android**: `/data/data/{package_name}/cache/libCachedImageData`
- **iOS**: `Library/Caches/ImageCache`
- **Windows**: `AppData/Local/Packages/{package_name}/LocalCache`
- **Web**: Browser cache storage

### Cache Invalidation
- Images are cached indefinitely by default
- Delete app cache to clear cached images
- CachedNetworkImage manages memory efficiently

## Expected Behavior Summary

| Scenario | Expected Result |
|----------|-----------------|
| Load image with network | Image loads from API, cached locally |
| Access cached image offline | Image displays from cache ✅ |
| Try new image offline | Loading spinner then error icon |
| Switch sub-breeds offline | Works if cached, shows error if not |
| Resume online after offline | Fresh load from API, new cache |

## Troubleshooting

**Image not loading?**
- Check network connectivity (except in airplane mode test)
- Verify dog.ceo API is accessible: https://dog.ceo/api/

**Cache not working?**
- Clear app cache: Settings → Apps → Adopt-a-Dog → Storage → Clear Cache
- Restart app and reload images
- Check device has available storage space

**Want to clear cache manually?**
- Android: Settings → Apps → Adopt-a-Dog → Storage → Clear Cache
- iOS: Settings → General → iPhone Storage → Adopt-a-Dog → Offload App (keeps data) or Delete App (removes all)
- Manual: Use app settings (if implemented) or reinstall app
