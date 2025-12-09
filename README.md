# Landmark Management App

A Flutter-based mobile application for managing geographical landmarks with GPS coordinates, interactive maps, and image support.

## 📱 App Summary
The Landmark Management App is a full-featured mobile application that allows users to create, view, edit, and delete geographical landmarks. Built with Flutter, it provides a seamless experience for managing location-based data with support for both online and offline modes.
The app integrates with a REST API for cloud storage while maintaining a local SQLite database for offline access. Users can attach images to landmarks (with automatic compression), use GPS to detect their current location, and visualize all landmarks on an interactive map powered by OpenStreetMap.

## ✨ Features

### Core Features
- **📍 Create Landmarks** - Add new landmarks with title, latitude, longitude, and optional images
- **🗺️ Interactive Map View** - Visualize all landmarks on an OpenStreetMap-powered map with custom markers
- **📋 List View** - Browse landmarks in a scrollable list with thumbnail images
- **✏️ Edit Landmarks** - Update existing landmark information and images
- **🗑️ Delete Landmarks** - Remove unwanted landmarks with confirmation dialogs

### Location Features
- **🎯 GPS Integration** - Automatically detect current location with one tap
- **📍 Manual Entry** - Enter coordinates manually with validation
- **🔍 Location Accuracy** - Display GPS accuracy information
- **⚡ High Precision** - Uses best navigation accuracy for precise coordinates

### Image Features
- **📸 Camera Support** - Capture photos directly from the app
- **🖼️ Gallery Selection** - Choose existing photos from device gallery
- **🗜️ Automatic Compression** - Reduces image size to 800x600px at 85% quality
- **⚡ Fast Upload** - Optimized images upload quickly even on slow connections
- **📷 Optional Images** - Create landmarks without images when needed

### Offline Features
- **💾 Local Database** - SQLite caching for offline access
- **🔄 Auto-Sync** - Automatic synchronization when connection is restored
- **📡 Connection Status** - Visual indicator showing online/offline state
- **🔁 Manual Refresh** - Pull-to-refresh and refresh button for manual updates

### User Experience
- **🎨 Modern UI** - Clean, Material Design 3 interface with Google Fonts
- **⏳ Loading Indicators** - Clear feedback during all operations
- **✅ Success Messages** - Confirmation for all successful operations
- **❌ Error Handling** - User-friendly error messages with actionable suggestions
- **🌓 Smooth Animations** - Polished transitions between screens

## 🛠️ Setup Instructions

### Prerequisites

Ensure you have the following installed:
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)
- A physical device or emulator for testing

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/landmark-app.git
   cd landmark-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions**
   
   The app requires location and camera permissions. These are already configured in `android/app/src/main/AndroidManifest.xml`:
   - Internet access
   - Location (fine and coarse)
   - Camera
   - Storage (read/write)

4. **Run the app**
   ```bash
   flutter run
   ```

### API Configuration

The app is configured to use the API endpoint:
```
https://labs.anontech.info/cse489/t3/api.php
```

If you need to change the API endpoint, modify the `baseUrl` constant in:
```
lib/services/api_service.dart
```

### Build for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```




## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── landmark.dart                  # Landmark data model
├── providers/
│   └── landmark_provider.dart         # State management
├── screens/
│   ├── home_screen.dart              # Main navigation
│   ├── overview_screen.dart          # Map view
│   ├── records_screen.dart           # List view
│   ├── new_entry_screen.dart         # Create landmark
│   └── edit_landmark_screen.dart     # Edit landmark
├── services/
│   ├── api_service.dart              # REST API calls
│   └── database_service.dart         # SQLite operations
└── widgets/
    └── landmark_bottom_sheet.dart    # Landmark details popup
```






## 🔌 API Endpoints

### GET - Fetch All Landmarks
```
GET /api.php
```
Returns array of landmark objects.

### POST - Create Landmark
```
POST /api.php
Content-Type: multipart/form-data

Fields: title, lat, lon, image (optional)
```

### PUT - Update Landmark
```
PUT /api.php?id={id}
Content-Type: multipart/form-data

Fields: id, title, lat, lon, image (optional)
```

### DELETE - Delete Landmark
```
DELETE /api.php?id={id}
```

## 📦 Dependencies
### Core
- `flutter_map: ^6.1.0` - Interactive map display
- `latlong2: ^0.9.0` - Latitude/longitude calculations
- `provider: ^6.1.1` - State management
### Networking
- `http: ^1.1.2` - HTTP requests
- `dio: ^5.4.0` - Advanced HTTP client
- `connectivity_plus: ^5.0.2` - Network connectivity
### Database
- `sqflite: ^2.3.0` - SQLite database
- `path_provider: ^2.1.1` - File system paths
### Location
- `geolocator: ^10.1.0` - GPS location services
- `permission_handler: ^11.1.0` - Runtime permissions
### Images
- `image_picker: ^1.0.7` - Camera/gallery selection
- `image: ^4.1.3` - Image processing
- `cached_network_image: ^3.3.1` - Image caching
### UI
- `google_fonts: ^6.1.0` - Custom fonts
- `cupertino_icons: ^1.0.6` - iOS-style icons
## ⚠️ Known Limitations

### API Limitations
- **No Authentication** - The API endpoint doesn't support user authentication, so all data is publicly accessible
- **No Batch Operations** - Must create/update/delete landmarks one at a time
- **Server Processing Delay** - 2-second delay needed after operations for server processing
- **Invalid Data in API** - API sometimes contains landmarks with empty fields that must be filtered

### Offline Limitations
- **Read-Only Offline Mode** - Can only view cached landmarks when offline; create/update/delete require internet
- **No Offline Queue** - Operations attempted while offline fail immediately (no queuing for later)
- **Cache Size** - Local database stores all fetched landmarks, may grow large over time

### Image Limitations
- **Compression is Mandatory** - All images are automatically resized to 800x600px, cannot upload original size
- **Single Image Per Landmark** - Only one image can be attached to each landmark
- **No Image Gallery** - Cannot view multiple images or create an image slideshow

### Location Limitations
- **GPS Required** - Automatic location detection requires GPS to be enabled
- **Accuracy Varies** - Location accuracy depends on GPS signal (works best outdoors)
- **No Address Lookup** - Coordinates only, no reverse geocoding to show addresses
- **Manual Entry Errors** - No validation of whether coordinates are on land/water

### Map Limitations
- **OpenStreetMap Only** - Uses only OpenStreetMap tiles, no alternative map providers
- **Online Map Tiles** - Map requires internet connection to load tiles
- **Basic Markers** - Simple pin markers only, no custom marker designs
- **No Route Planning** - Cannot plan routes between landmarks

### General Limitations
- **Android/iOS Only** - No web or desktop support
- **English Only** - No internationalization/localization support
- **No Search Function** - Cannot search or filter landmarks by name or location
- **No Categories** - Cannot organize landmarks into categories or groups
- **No Sharing** - Cannot share landmarks with other users
- **No Export** - Cannot export landmark data to CSV, JSON, or other formats






## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: ByteBerserk

