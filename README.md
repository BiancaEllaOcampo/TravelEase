# TravelEase

A Flutter mobile application for Philippine travel document verification with AI-assisted checklists. Features role-based access control (User, Admin, Master) and automated document analysis using OpenAI GPT-4 Vision.

## Summary

TravelEase is a comprehensive mobile application that helps Filipino travelers prepare and verify required travel documents for international destinations. The app provides destination-specific document checklists, AI-powered document verification, and a multi-tier role system for document review and administration. Currently focused on Android as the primary development platform.

## Key Features

### For Travelers (User Role)
- **Document Checklists** - Country-specific requirements for Japan, Hong Kong, South Korea, Singapore, and China
- **AI Document Verification** - Automated analysis of flight tickets, visas, and accommodation proofs using OpenAI GPT-4 Vision
- **Real-time Status Tracking** - Track document status: Pending → Verifying → Verified/Needs Correction
- **Document Management** - Upload via camera or gallery with automatic image optimization
- **Profile Management** - Upload and manage profile pictures with Firebase Storage
- **Pull-to-Refresh** - Real-time updates on document verification status
- **Announcements** - View system-wide announcements from administrators

### For Administrators (Admin Role)
- **Document Review** - Manual review and verification of user documents
- **User Management** - View and manage user accounts
- **Announcements** - Create, edit, and manage system announcements
- **Dashboard** - Quick access to pending reviews and system statistics

### For Super Admins (Master Role)
- **Full System Access** - Complete control over users, admins, and system settings
- **User & Admin Management** - Create, modify, and delete accounts across all roles
- **System Announcements** - Manage all announcements with full CRUD operations

## Tech Stack

### Frontend
- **Flutter (Dart)** - Cross-platform UI framework
- **Material Design** - Modern, consistent UI components
- **Custom Design System** - Brand colors and typography (Kumbh Sans font)

### Backend & Services
- **Firebase Authentication** - Secure user authentication and role-based access control
- **Cloud Firestore** - NoSQL database for user profiles, checklists, and announcements
- **Firebase Storage** - Secure file storage for profile pictures and travel documents
- **Firebase Cloud Functions** - Serverless backend for AI document analysis
- **OpenAI GPT-4 Vision API** - AI-powered document verification and data extraction

### Security
- **Firebase Security Rules** - Granular access control for Firestore and Storage
- **Role-Based Authorization** - Three-tier system (User, Admin, Master)
- **Secure Secret Management** - OpenAI API keys stored in Google Secret Manager

### Development Tools
- **Android Studio** - Primary IDE for Android development
- **Firebase CLI** - Deploy security rules, functions, and manage Firebase services
- **Git & GitHub** - Version control and collaboration

## Architecture

### Authentication System
- **Unified Firebase Auth** - All roles (User, Admin, Master) use the same authentication system
- **Firestore Role Field** - Role stored in `users` collection for authorization
- **NO Password Storage** - Passwords remain encrypted in Firebase Auth only

### Data Model
```
users/{userId}/
  ├── email, fullName, phoneNumber, address
  ├── role: "user" | "admin" | "master"
  ├── profileImageUrl: string (Firebase Storage URL)
  └── checklists/
      └── {country}/ (lowercase_with_underscores: japan, hong_kong, etc.)
          └── {documentName}/ (flight_ticket, valid_passport, visa, etc.)
              ├── status: "pending" | "verifying" | "verified" | "needs_correction"
              ├── url: string (Firebase Storage URL)
              ├── extractedData: map (AI-extracted document data)
              ├── aiFeedback: string (AI analysis feedback)
              ├── analyzedAt: timestamp
              └── updatedAt: timestamp

announcements/{announcementId}/
  ├── title: string
  ├── content: string
  ├── date: timestamp
  └── createdBy: string
```

### Firebase Storage Structure
```
storage/
├── user_profiles/{userId}/
│   └── profile_{userId}_{timestamp}.jpg (max 5MB)
└── user_documents/{userId}/{country}/{docType}/
    └── {fileName} (max 10MB, images only)
```

## What we're using

- **Framework**: Flutter (Dart)
- **Primary Platform**: Android (development, testing, and releases)
- **Secondary**: iOS support exists but not actively tested
- **Languages**: Dart (Flutter), JavaScript (Cloud Functions), C++ (native), Swift (iOS), HTML

## AI Document Verification

### Supported Documents
- ✅ **Flight Tickets** - Extract passenger names, airlines, flight numbers, dates, booking codes
- ✅ **Visas** - Extract visa type, number, validity dates, applicant information
- ✅ **Proof of Accommodation** - Extract hotel names, booking references, check-in/out dates
- ⚠️ **Passports** - Cannot be analyzed due to OpenAI PII restrictions (manual admin review required)

### How It Works
1. User uploads document to Firebase Storage
2. Cloud Function triggers on upload
3. OpenAI GPT-4 Vision analyzes document image
4. Extracted data and feedback saved to Firestore
5. Status updated automatically (pending → verifying → verified/needs_correction)
6. User receives real-time updates via pull-to-refresh

### AI Limitations
- **Privacy Policy Restrictions**: OpenAI blocks analysis of sensitive PII documents (passports)
- **Image Quality**: Best results with clear, well-lit images
- **Language Support**: Optimized for English and common travel document formats

## Getting Started (Development)

### Prerequisites
1. **Flutter SDK**: https://flutter.dev/docs/get-started/install
2. **Android Studio**: Install and set up Android SDK
3. **Firebase Account**: Create a project at https://firebase.google.com
4. **OpenAI API Key**: Required for AI document verification (https://platform.openai.com)

### Environment Variables

The project uses a `.env` file for sensitive configuration, for more information, kindly contact any of the contributors

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/BiancaEllaOcampo/TravelEase.git
   cd travelease2
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Add your `google-services.json` to `android/app/`
   - Deploy Firestore security rules:
     ```bash
     firebase deploy --only firestore:rules
     ```
   - Deploy Storage security rules:
     ```bash
     firebase deploy --only storage
     ```

4. **Cloud Functions Setup** (for AI verification):
   ```bash
   cd functions
   npm install
   ```
   - **Set OpenAI API key as Firebase Secret**:
     ```bash
     firebase functions:secrets:set OPENAI_API_KEY
     ```
   - For local development: Create `.env` file in `functions/` directory with `OPENAI_API_KEY=sk-proj-...`
   - Deploy functions:
     ```bash
     firebase deploy --only functions
     ```
   - **Never commit API keys to Git!** Secrets are stored encrypted in Google Secret Manager

5. **Run on Android device or emulator**:
   ```bash
   flutter run
   ```
   
   If multiple devices connected:
   ```bash
   flutter run -d <device-id>
   ```

### Admin/Master Account Setup

Admin and Master accounts must be created manually via Firebase Console:

**Method 1: Firebase Console (Recommended)**
1. Go to Firebase Console → Authentication → Users → "Add user"
2. Create account with email/password, copy the User UID
3. Go to Firestore Database → `users` collection → "Add document"
4. Use the User UID as Document ID and add fields:
   ```javascript
   {
     "email": "admin@travelease.com",
     "fullName": "Admin Name",
     "role": "admin",  // or "master"
     "phoneNumber": "",
     "address": "",
     "profileImageUrl": null,
     "createdAt": [timestamp],
     "updatedAt": [timestamp]
   }
   ```

**Method 2: Promote Existing User**
1. Go to Firestore Database → `users` collection
2. Find user's document by UID
3. Edit document and change `role: "user"` to `role: "admin"` or `role: "master"`

**Security Notes:**
- ❌ NEVER store passwords in Firestore (only in Firebase Auth)
- ❌ Never allow self-promotion to admin/master roles in the app
- ✅ Use Firebase Security Rules to enforce role-based access control
- ✅ Verify roles on both client and server side

## Project Structure

```
lib/
├── main.dart                  # Entry point, Firebase initialization
├── firebase_options.dart      # Auto-generated Firebase config
├── pages/
│   ├── splash_screen.dart     # Landing page with login/signup
│   ├── user/                  # User role pages
│   │   ├── user_login.dart
│   │   ├── user_signup.dart
│   │   ├── user_homepage.dart
│   │   ├── user_profile.dart
│   │   ├── user_travel_requirements.dart
│   │   ├── user_documents_checklist.dart
│   │   ├── user_view_document_with_ai.dart
│   │   └── user_announcements.dart
│   ├── admin/                 # Admin role pages
│   │   ├── admin_login.dart
│   │   ├── admin_dashboard.dart
│   │   ├── admin_announcements.dart
│   │   └── admin_manage_users.dart
│   └── master/                # Master role pages
│       ├── master_login.dart
│       ├── master_dashboard.dart
│       └── master_announcements.dart
├── utils/
│   ├── user_app_drawer.dart   # User navigation drawer
│   ├── admin_app_drawer.dart  # Admin navigation drawer
│   └── checklist_helper.dart  # Shared checklist navigation
└── dev/
    ├── debug_page.dart        # Development navigation hub (REMOVE BEFORE PRODUCTION)
    ├── template.dart          # Page template with back button
    └── template_with_menu.dart # Page template with drawer

functions/
├── index.js                   # Cloud Function for AI document analysis
├── package.json
└── .env                       # Environment variables

firebase/
├── storage.rules             # Firebase Storage security rules
└── firestore.rules           # Firestore Database rules

.env                           # Environment variables for local development (gitignored)
.gitignore                     # Git ignore rules (includes .env)
```

## Key Documentation Files

- `.github/copilot-instructions.md` - Comprehensive development guidelines and architecture decisions
- `functions/index.js` - Cloud Function for AI document analysis with OpenAI integration
- `firebase/firestore.rules` - Database security rules with role-based access control
- `firebase/storage.rules` - File storage security rules (5MB profiles, 10MB documents)
- `android/app/src/main/AndroidManifest.xml` - Android permissions for camera and storage

## Design System

### Brand Colors
- `0xFF125E77` - Dark teal (headers, primary text)
- `0xFF348AA7` - Light teal (buttons, borders, accents)
- `0xFFD9D9D9` - Light gray (backgrounds)
- `0xFFA54547` - Red (errors, "Needs Correction")
- `0xFF34C759` - Green ("Verified")
- `0xFFFFA500` - Orange ("Verifying")

### Typography
- Font Family: **Kumbh Sans** (set globally in `main.dart`)
- Custom AppBar: 130px fixed height with teal background
- Letter spacing for enhanced readability

## Known Limitations

- **iOS Platform**: Untested - Android-only development
- **AI Passport Analysis**: OpenAI blocks sensitive PII - admin manual review required
- **No Automated Tests**: `test/` directory unused
- **Single Country Per User**: Firestore structure allows only one country checklist per user

## Deployment Checklist

### Before Production
- [ ] Remove debug system (`lib/dev/debug_page.dart` and red buttons)
- [ ] Deploy Firebase Security Rules: `firebase deploy --only firestore:rules,storage`
- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Set OpenAI API key: `firebase functions:secrets:set OPENAI_API_KEY`
- [ ] Test all three roles (User, Admin, Master)
- [ ] Test document upload and AI verification
- [ ] Test profile picture upload
- [ ] Verify security rules in Firebase Console
- [ ] Enable Firebase Analytics (optional)
- [ ] Set up Firebase Crashlytics (optional)

### Production Monitoring
- Monitor Cloud Functions logs in Firebase Console
- Check OpenAI API usage and billing
- Monitor Firebase Storage usage
- Review Firestore security rules regularly
- Set up usage alerts for Firebase services

## Contributing

This project is currently in active development. Please follow the coding guidelines in `.github/copilot-instructions.md` for consistency.

## Project Information

**Educational Purpose**: This project was developed as an academic requirement for **Mapúa University**.

**Course**: ITS120L - Application Development and Emerging Technologies Laboratory

**Development Team**:
- Eugene Cayle L. Maniego
- John Ivan Gabriel G. Gacay
- Bianca Ella D. Ocampo
- Zaki Nathaniel U. Tanig

**Institution**: Mapúa University
**Academic Year**: 2025-2026

## License

This project is developed for educational purposes.