# Flutter Map Demo – Pickup & Drop-off Distance Tracker
This Flutter application demonstrates how to fetch the user's current location, set a pickup and drop-off point, calculate the distance between them, and display it on a map using flutter_map (an open-source alternative to Google Maps).

📋 Features

Get current user location using Geolocator

Display location and coordinates on Flutter Map

Select and update pickup and drop-off locations

Convert coordinates into readable addresses using Geocoding

Calculate distance in kilometers

Display estimated fare based on distance

Manage state efficiently with Provider

🛠️ Setup Instructions
1. Clone the Repository
git clone https://github.com/Awais-Aslam/flutter_map_demo
cd flutter_map_demo

2. Install Dependencies

Make sure Flutter is installed on your system. Then run:

flutter pub get

3. Configure Location Permissions
For Android:

Add the following permissions in android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />


Inside the <application> tag:

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />


Note: API key is not required since flutter_map uses open-source tile services (e.g., OpenStreetMap).

For iOS:

Add this to your ios/Runner/Info.plist:

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to show your current position.</string>

🧩 Dependencies Used
Package	Version	Description
flutter_map	^7.0.2	Used to display maps (OpenStreetMap tiles) instead of Google Maps
provider	^6.1.5+1	State management for updating pickup/drop-off and UI data
geolocator	^12.0.0	Get current location and calculate distances between coordinates
latlong2	^0.9.1	Provides latitude and longitude data types
geocoding	^4.0.0	Converts coordinates into readable addresses (reverse geocoding)
🗺️ Map Configuration

This project uses flutter_map, which relies on OpenStreetMap tiles.
No Google Maps API key is required.

Example tile layer configuration:

TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.flutter_map_demo',
),

🚧 Known Limitation

Currently, the polyline drawn between pickup and drop-off points appears as a straight line rather than following actual road routes.
This happens because flutter_map uses raw geographical coordinates and does not have built-in route rendering (unlike Google Maps which supports route APIs).

You can integrate routing APIs like OSRM or Mapbox Directions API in the future to show real road paths.

💰 Fare Calculation

The estimated fare is calculated based on a fixed rate of €1 per kilometer:

double get estimatedFare => distanceKm * 1.0;

🚀 Running the App

Run the app using:

flutter run

Ensure your emulator or device has location services enabled.
