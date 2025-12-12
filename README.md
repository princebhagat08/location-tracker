# Location Tracking Module – Flutter

This project implements a real-time location tracking feature using `flutter_map`, `geolocator`, `geocoding`, and `GetX` for state management. The application continuously listens to the user’s location, converts latitude-longitude to a readable address, stores history, and follows MVVM architecture.

---

## 🚀 Features
- Permission handling (fine + coarse)
- Real-time GPS location
- Reverse Geocoding (City, Pin, State)
- Automatic UI updates
- Location history with timestamps
- Clean MVVM architecture
- State stored only in memory

---

## 🧩 Packages Used

| Package | Purpose |
|--------|---------|
| geolocator | Real-time GPS updates |
| geocoding | Convert coordinates → address |
| flutter_map | Display map using OpenStreetMap |
| GetX | State management & MVVM |

---

## 📍 Why flutter_map instead of Google Maps?
- Completely open-source
- No API key required
- Lightweight and fast
- Uses OpenStreetMap tiles
- Easier integration

---

## 🛰 How Location Works
1. Request permissions
2. Fetch current GPS location
3. Listen to movement stream
4. Convert coordinates to address
5. Push updates to UI using GetX
6. Maintain history list

---

## 📦 Architecture (MVVM)
```text
lib/
├── controllers/
│   ├── location_controller.dart
│   └── theme_controller.dart
├── core/
│   ├── constants/
│   └── services/
├── models/
│   └── user_location.dart
├── views/
│   ├── widgets/
│   └── home_screen.dart
└── main.dart

- Model → location data
- Controller → business logic and streams
- View → UI + map

```
---

No Google Maps API was used. Everything is achieved with flutter_map, geolocator, and geocoding.

## Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/83bd6a30-a237-4fcb-886c-88b372c8e4c7" width="200" />
  <img src="https://github.com/user-attachments/assets/08a9ff13-3923-4760-82f8-b7375aa8a918" width="200" />
  <img src="https://github.com/user-attachments/assets/75f892cd-2f50-4459-b4ce-f6c2b43646a4" width="200" />
   <img src="https://github.com/user-attachments/assets/1bb7f73f-d574-4747-832c-b6ab8a2df07d" width="200" />
</p>







