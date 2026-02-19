# Firebase Setup Guide

Complete guide for setting up Firebase services for the NDT Toolkit app.

## 🎯 Overview

NDT Toolkit uses multiple Firebase services:
- **Firebase Hosting** - Web app hosting
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Analytics** - User analytics
- **Firebase Crashlytics** - Crash reporting (Android/iOS)
- **Firebase Performance** - Performance monitoring
- **Cloud Functions** - Server-side logic

---

## 📋 Initial Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Enter project name: `ndt-toolkit`
4. Enable Google Analytics (recommended)
5. Create project

### 2. Register Apps

#### Web App
1. In Firebase Console, click **Add app** → **Web** (</> icon)
2. App nickname: `NDT Toolkit Web`
3. Check **Firebase Hosting**
4. Register app
5. Copy Firebase config object

#### Android App
1. Click **Add app** → **Android**
2. Android package name: `com.ndttoolkit.app`
3. Download `google-services.json`
4. Place in `android/app/` directory

#### iOS App
1. Click **Add app** → **iOS**
2. iOS bundle ID: `com.ndttoolkit.app`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/` directory

---

## 🔥 Firebase Hosting Setup

### Configure Multiple Sites

1. **In Firebase Console:**
   - Go to **Hosting** section
   - Click **Add another site**
   - Create sites:
     - `ndt-toolkit` (production)
     - `ndt-toolkit-preview` (preview)
     - `admin-ndt-toolkit` (admin)
     - `ndt-toolkit-marketing` (marketing)

2. **Configure Locally:**
   
   See [Domain Setup Guide](./DOMAIN_SETUP.md) for detailed multi-site configuration.

---

## 🔐 Firebase Authentication

### Enable Authentication Providers

1. **In Firebase Console:**
   - Go to **Authentication** → **Sign-in method**
   
2. **Enable Email/Password:**
   - Click **Email/Password**
   - Enable both options
   - Save

3. **Configure Email Templates (Optional):**
   - Go to **Templates** tab
   - Customize email verification template
   - Customize password reset template

### Email Verification

The app enforces email verification for new users:
- Existing users are grandfathered (no verification required)
- New signups must verify email before full access
- Configured in `lib/services/auth_service.dart`

---

## 📊 Cloud Firestore

### Security Rules

Update `firestore.rules` for your collections:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Defect entries
    match /defect_entries/{entryId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Photo identifications
    match /photo_identifications/{photoId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.userId;
    }
    
    // Admin-only collections
    match /news_updates/{updateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### Deploy Rules

```bash
firebase deploy --only firestore:rules
```

### Indexes

Firestore indexes are defined in `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "defect_entries",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "photo_identifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

---

## 📦 Firebase Storage

### Storage Rules

Update `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Procedures - admins can write, all authenticated users can read
    match /procedures/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Defect photos - users can read/write their own
    match /defect_photos/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Exports - users can read/write their own
    match /exports/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Deploy storage rules:
```bash
firebase deploy --only storage
```

### Storage Structure

```
storage/
├── procedures/
│   ├── {clientName}/
│   │   └── *.pdf
│   └── defectidentifiertool/
│       └── *.pdf
├── defect_photos/
│   └── {userId}/
│       └── *.jpg
└── exports/
    └── {userId}/
        └── *.xlsx
```

---

## 📈 Firebase Analytics

### Web Analytics Setup

Analytics is initialized in `web/index.html`:

```javascript
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
import { getAnalytics } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-analytics.js';

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
```

### Flutter Analytics

Configured in `lib/services/analytics_service.dart`:

```dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Log events
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
```

### Key Events Tracked

- Screen views
- Button clicks
- Feature usage
- Defect logging
- Photo uploads
- Calculator usage
- PDF generation
- Error occurrences

---

## 🔥 Firebase Crashlytics (Mobile)

### Android Setup

Already configured in:
- `android/app/build.gradle` - Crashlytics plugin
- `android/build.gradle` - Crashlytics dependency

### iOS Setup

Already configured in:
- `ios/Runner/Info.plist` - Firebase configuration
- Podfile includes Firebase Crashlytics

### Usage

Crashlytics automatically captures:
- Fatal crashes
- Non-fatal errors
- Custom logs
- User IDs

Manual error reporting:
```dart
FirebaseCrashlytics.instance.recordError(error, stackTrace);
```

---

## ⚡ Firebase Performance Monitoring

### Web Performance

Configured in `lib/services/performance_service.dart`:

```dart
class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<void> startTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.start();
  }
}
```

### Key Metrics Monitored

- Page load times
- API call latency
- Database query times
- Image upload times
- PDF generation times

---

## ☁️ Cloud Functions

### Setup Functions

```bash
cd functions
npm install
```

### Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:analyzeDefectOnCreate
```

### Key Functions

1. **analyzeDefectOnCreate** - AI defect analysis
2. **analyzePhotoIdentificationOnCreate** - Photo AI identification
3. **invalidateCacheOnPdfUpload** - Cache management
4. **invalidateCacheOnPdfDelete** - Cache cleanup
5. **exportMethodHoursToExcel** - Server-side Excel generation

### Function Configuration

Environment variables set via:
```bash
firebase functions:config:set someservice.key="THE API KEY"
```

---

## 🔧 Firebase CLI Commands

### Installation

```bash
npm install -g firebase-tools
```

### Login

```bash
firebase login
```

### Initialize Project

```bash
firebase init
```

Select:
- Hosting
- Firestore
- Storage
- Functions

### Deploy Everything

```bash
firebase deploy
```

### Deploy Specific Services

```bash
# Hosting only
firebase deploy --only hosting

# Firestore rules only
firebase deploy --only firestore:rules

# Functions only
firebase deploy --only functions

# Storage rules only
firebase deploy --only storage
```

### View Logs

```bash
# Functions logs
firebase functions:log

# Hosting logs
firebase hosting:channel:list
```

---

## 📱 Platform-Specific Configuration

### Web Configuration

Firebase config in `web/index.html`:

```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "ndt-toolkit.firebaseapp.com",
  projectId: "ndt-toolkit",
  storageBucket: "ndt-toolkit.appspot.com",
  messagingSenderId: "...",
  appId: "...",
  measurementId: "..."
};
```

### Android Configuration

`android/app/google-services.json` - Contains all Firebase configuration

### iOS Configuration

`ios/Runner/GoogleService-Info.plist` - Contains all Firebase configuration

---

## 🔐 Security Best Practices

### API Keys

- Web API keys are safe to expose (restricted by domain)
- Never commit service account keys to git
- Use environment variables for sensitive data in functions

### Firestore Rules

- Always validate user ownership
- Use server timestamps for data integrity
- Validate data types and required fields
- Test rules thoroughly

### Storage Rules

- Enforce size limits
- Validate file types
- Use user-specific paths
- Implement rate limiting if needed

---

## 🆘 Troubleshooting

### "Permission Denied" Errors

1. Check Firestore/Storage rules
2. Verify user is authenticated
3. Confirm user has correct permissions
4. Check field validation in rules

### Functions Not Triggering

1. Check function deployment status
2. Review function logs: `firebase functions:log`
3. Verify trigger configuration
4. Check for runtime errors

### Analytics Not Working

1. Verify Firebase config is correct
2. Check analytics is initialized
3. Test in production (not localhost)
4. Allow 24-48 hours for data to appear

---

## 📚 Related Documentation

- [Domain Setup](./DOMAIN_SETUP.md) - Configure hosting domains
- [GitHub Actions](./GITHUB_ACTIONS.md) - Automated deployments
- [Build Configuration](../guides/BUILD_CONFIGURATION.md) - Build settings

---

## 🔗 Official Documentation

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

**Last Updated:** February 19, 2026
