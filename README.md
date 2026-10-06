# Campus Lost & Found 📱🎓

> **College Final Year / Practical No. 12 Project for Web and Mobile Application Development**

A complete, full-stack, cross-platform mobile application designed for college campuses to help students report lost items, browse found items, and manage item recovery safely.

---

## 📌 Problem Statement

Every day on college campuses, students lose valuable belongings such as laptops, ID cards, wallets, keys, and textbooks. Existing methods for recovering lost items (like WhatsApp group messages or physical notice boards) are unorganized, non-searchable, and inefficient. 

**Campus Lost & Found** solves this problem by offering a centralized mobile application with search, filter, real-time item status tracking, image upload capabilities, and authenticated access.

---

## ✨ Features

- 🔐 **Firebase Authentication**: Email/Password Registration and Login with token verification.
- 🔍 **Real-time Search & Filter**: Instant search by item title, category, or location, filtered by *Lost* or *Found*.
- 📷 **Firebase Storage Image Upload**: Image capture & gallery selection with instant cloud storage preview.
- ⚡ **Node.js & Express REST API**: Modular backend handling CRUD operations with Firebase Admin SDK token verification.
- 🛡️ **Protected Item CRUD**: Only authenticated item owners can update or delete their reports.
- 👤 **Profile & My Reports**: Manage user profile and view all reported items in one place.
- 🎨 **Material 3 UI Aesthetics**: Modern, accessible, and responsive design built for college demo presentations.

---

## 🏗️ System Architecture

```
                    FLUTTER MOBILE & WEB APP
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
    Firebase Auth       Cloud Firestore      Firebase Storage
 (User Login/Signup)   (Real-time Database)  (Image Cloud Storage)
```

---

## 🛠️ Technology Stack

| Layer | Technologies |
| :--- | :--- |
| **Frontend Mobile App** | Flutter 3.29, Dart 3.7, Material 3, Provider, Cloud Firestore SDK, Image Picker |
| **Database & Cloud Services** | Firebase Cloud Firestore, Firebase Authentication, Firebase Storage |

---

## 📂 Project Structure

```
campus-lost-found/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js          # Firebase Admin SDK configuration
│   │   ├── controllers/
│   │   │   └── itemController.js    # Item CRUD business logic & fallbacks
│   │   ├── middleware/
│   │   │   └── authMiddleware.js    # Firebase ID Token verification
│   │   ├── routes/
│   │   │   └── itemRoutes.js        # Express REST API routes
│   │   └── server.js                # Express app entry point & health check
│   ├── .env.example                 # Environment variables template
│   ├── package.json                 # Node.js dependencies
│   └── test_api.js                  # Automated REST API test suite
│
├── mobile/
│   ├── lib/
│   │   ├── main.dart                # App entry point & MultiProvider
│   │   ├── firebase_options.dart    # Firebase platform options configuration
│   │   ├── models/
│   │   │   └── item.dart            # Item data model & JSON serialization
│   │   ├── services/
│   │   │   ├── api_service.dart     # HTTP client service for backend REST API
│   │   │   ├── auth_service.dart    # Firebase Auth state manager
│   │   │   └── storage_service.dart # Firebase Storage upload service
│   │   ├── screens/
│   │   │   ├── splash_screen.dart   # Animated splash screen
│   │   │   ├── login_screen.dart    # Authentication login
│   │   │   ├── register_screen.dart # User registration
│   │   │   ├── home_screen.dart     # Dashboard, search, filters
│   │   │   ├── add_item_screen.dart # Report lost/found item with image
│   │   │   ├── item_details_screen.dart # Full item details, contact & owner actions
│   │   │   ├── edit_item_screen.dart    # Edit report
│   │   │   ├── profile_screen.dart     # User profile
│   │   │   └── my_reports_screen.dart  # User's items
│   │   └── widgets/
│   │       ├── item_card.dart       # Reusable item card
│   │       ├── status_chip.dart     # Lost/Found badge
│   │       └── loading_widget.dart  # Custom loaders & empty states
│   └── pubspec.yaml                 # Flutter dependencies
│
├── README.md                        # Project documentation
└── PROJECT_DOCUMENTATION.md         # College Practical No. 12 report
```

---

## 🚀 Getting Started

### 1. Backend Setup

1. Navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file based on `.env.example`:
   ```env
   PORT=5000
   NODE_ENV=development
   FIREBASE_PROJECT_ID=campus-lost-found-app
   ```
4. Start the server:
   ```bash
   npm run dev
   ```
5. Test the health endpoint:
   `http://localhost:5000/api/health`

---

### 2. Mobile Setup

1. Navigate to the `mobile/` directory:
   ```bash
   cd mobile
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter app:
   ```bash
   flutter run
   ```

---

## 📡 REST API Endpoints & Postman Documentation

| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/health` | Public | Health status check |
| `GET` | `/api/items` | Public | Get all lost & found items (supports `?status=Lost`, `?category=Bags`, `?search=library`) |
| `GET` | `/api/items/:id` | Public | Get item details by ID |
| `POST` | `/api/items` | Protected | Create new item report (Header: `Authorization: Bearer <ID_TOKEN>`) |
| `PUT` | `/api/items/:id` | Protected | Edit item report (Owner only) |
| `DELETE` | `/api/items/:id` | Protected | Delete item report (Owner only) |

### Postman Testing Example:
To test protected endpoints (`POST`, `PUT`, `DELETE`), pass the Firebase ID token in the Header:
```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```
*(In development mode, `Authorization: Bearer mock-token-student-123` can be used for rapid testing).*

---

## ☁️ Deployment (Render Web Service)

1. Connect repository to [Render](https://render.com).
2. Select **Web Service**, directory `backend`.
3. Build Command: `npm install`
4. Start Command: `node src/server.js`
5. Add Environment Variables on Render:
   - `PORT`: `5000`
   - `NODE_ENV`: `production`
   - `FIREBASE_PROJECT_ID`: `<your-project-id>`
   - `FIREBASE_CLIENT_EMAIL`: `<your-client-email>`
   - `FIREBASE_PRIVATE_KEY`: `<your-private-key>`
6. Update `ApiService.baseUrl` in `mobile/lib/services/api_service.dart` with your deployed Render URL:
   `https://your-app.onrender.com/api`

---

## 📦 Release APK Build

To build the release APK for Android deployment:
```bash
cd mobile
flutter build apk --release
```
The generated APK will be located at:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔮 Future Scope

- 🔔 Push Notifications when a matching item is reported.
- 💬 In-App Chat between item owner and finder.
- 🗺️ Interactive Campus Map indicating precise GPS locations.
