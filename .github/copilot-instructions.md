# TravelEase - AI Coding Instructions

## Project Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but not the focus). Three-tier role system: **User** (travelers), **Admin** (document reviewers), and **Master** (super admins).

**Core Technology Stack:**
- Flutter/Dart for cross-platform mobile UI
- Firebase Auth + Firestore for unified authentication with role-based access
- Firebase Storage for documents (max 10MB, images only) and profile pictures (max 5MB)
- Firebase Cloud Functions + OpenAI GPT-4 Vision for AI document analysis
- **No state management libraries** - pure StatefulWidget + TextEditingController pattern

## Authentication & Role-Based Access Control

### Unified Authentication System
**All roles use Firebase Auth + Firestore profiles** - NO separate admin/master databases:
- **Firebase Authentication** - Stores ALL user credentials (email/password) securely
- **Firestore `users` collection** - Stores user profiles with `role` field
- **NEVER store passwords in Firestore** - they stay encrypted in Firebase Auth

### User Roles
```dart
users/{userId}
  ├── email: string
  ├── fullName: string
  ├── role: "user" | "admin" | "master"  // Role-based access control
  ├── ... other profile data
  └── NO PASSWORD (passwords only in Firebase Auth!)
```

**Role Types:**
- `user` (default) - Regular travelers who upload documents
- `admin` - Document reviewers, can verify/reject user documents
- `master` - Super admins with full system access

**Login Flow:**
1. Sign in with Firebase Auth (email/password)
2. Fetch user profile from Firestore
3. Check `role` field for authorization
4. Navigate to appropriate dashboard or deny access

**Creating Admin/Master Accounts:**
- See `ADMIN_MASTER_SETUP.md` for detailed instructions
- Manual creation via Firebase Console (Auth + Firestore)
- Never allow self-promotion to admin/master in app

## Critical Design Decisions

### Stack-Based Layout Architecture
**Most pages use absolute positioning** via `Stack` + `Positioned` for pixel-perfect designs:
```dart
Stack(
  children: [
    Container(color: Color(0xFFD9D9D9)), // Full background
    Positioned(top: 50, left: 30, child: /* Back button */),
    Positioned(top: 125, left: 30, right: 30, child: /* Content */),
  ],
)
```

**Exception**: `user_homepage.dart` uses responsive `Column` + `ScrollView` pattern for dynamic content.

### Custom AppBar (130px Fixed Height)
**Never use standard AppBar**. All pages use `PreferredSize` with custom container:
```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(130),
  child: Container(
    height: 130,
    color: const Color(0xFF125E77), // Dark teal header
    child: Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: Row(/* menu/back + title + logo */),
    ),
  ),
)
```

### Hard-Coded Brand Colors (No Theme System)
Colors are directly specified - **don't use** `Theme.of(context).primaryColor`:
- `0xFF125E77` - Dark teal (headers, primary text)
- `0xFF348AA7` - Light teal (buttons, borders, accents)
- `0xFFD9D9D9` - Light gray (backgrounds)
- `0xFFA54547` - Red (errors, "Needs Correction")
- `0xFF34C759` - Green ("Verified")
- `0xFFFFA500` - Orange ("Verifying")

### Document Status State Machine
Four states in Firestore (`users/{uid}/checklists/{country}/{docName}/status`):
- `'pending'` (teal) → Initial state
- `'verifying'` (orange) → Under admin review
- `'verified'` (green) → Approved
- `'needs_correction'` (red) → Rejected

## Firebase Data Model

### Firestore Structure
```
users/{userId}/
  fullName, email, phoneNumber, address, passport*, visa*, insurance*
  role: "user" | "admin" | "master"  // Role-based access control
  profileImageUrl: string  // Firebase Storage download URL
  checklists/
    {country}:  // Only ONE country per user (enforced), lowercase_with_underscores format
      {documentName}: {  // lowercase_with_underscores format (e.g., flight_ticket, valid_passport)
        status: string,
        url: string,
        updatedAt: timestamp,
        extractedData: map,  // AI-extracted document data
        aiFeedback: string,  // AI analysis feedback
        analyzedAt: timestamp  // When AI last analyzed
      }
```

### Firebase Storage Structure
```
storage/
├── user_profiles/
│   └── {userId}/
│       └── profile_{userId}_{timestamp}.jpg  // User profile pictures (max 5MB)
└── user_documents/  // Travel documents with AI analysis
    └── {userId}/
        └── {country}/  // lowercase_with_underscores (e.g., hong_kong)
            └── {docType}/  // lowercase_with_underscores (e.g., flight_ticket)
                └── {fileName}  // Travel documents (max 10MB, images only)
```

### Authentication Pattern
All protected pages check auth state AND role in build():
```dart
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  });
  return Scaffold(body: Center(child: CircularProgressIndicator()));
}

// For admin/master pages, also verify role:
final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
if (userDoc.data()?['role'] != 'admin') {
  // Access denied - redirect
}
```

### One Checklist Constraint
Users can only have ONE active destination checklist. When selecting a new destination in `user_travel_requirements.dart`:
1. Check if checklist exists via Firestore read
2. Show override confirmation dialog
3. Use `update()` (not `merge`) to replace entire checklist

## State Management & Navigation

### Local State Only
- No Provider/Riverpod/Bloc - just `StatefulWidget` + `TextEditingController`
- Validation happens inline in `onPressed` handlers
- User feedback via `ScaffoldMessenger.of(context).showSnackBar()`

### Direct Navigation (No Named Routes)
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const TargetPage(),
));
```

### Shared Checklist Navigation
**Always use** `ChecklistHelper.navigateToChecklist(context)` (in `lib/utils/checklist_helper.dart`):
- Fetches existing checklist from Firestore
- Routes to `UserDocumentsChecklistPage` if found
- Otherwise redirects to `UserTravelRequirementsPage` to create one

## Development Workflow

### Essential Commands (PowerShell)
```powershell
# Flutter
flutter pub get                    # Install/update dependencies
flutter run                        # Run on default device
flutter run -d <device-id>         # Specify device
flutter build apk                  # Build production APK
flutter clean                      # Clean build artifacts

# Firebase Deployment
firebase deploy --only firestore:rules    # Deploy Firestore security rules
firebase deploy --only storage           # Deploy Storage security rules
firebase deploy --only functions         # Deploy Cloud Functions
firebase emulators:start                 # Start local emulators

# Environment Setup
# Create .env file with: OPENAI_API_KEY=your_key_here
# For production: Use Google Secret Manager (see functions/SECRETS_SETUP.md)
```

### Navigation Drawer Pattern
**ALWAYS import from centralized location** - Never copy/paste drawer classes:
```dart
import '../../utils/user_app_drawer.dart';  // For user pages
import '../../utils/admin_app_drawer.dart'; // For admin pages
import '../../utils/master_app_drawer.dart'; // For master pages

Scaffold(
  drawer: const UserAppDrawer(),  // Role-specific drawer
  // ... rest of page
)
```

### Creating New Pages
1. **Copy template**: `lib/dev/template.dart` (back button) or `template_with_menu.dart` (with drawer)
2. **Adjust layout**: Modify `Positioned` coordinates (most pages use Stack-based absolute positioning)
3. **Add auth guard**: Copy auth check pattern from existing role pages
4. **Test via debug page**: Add route to `lib/dev/debug_page.dart`
5. **Place in role folder**: `pages/user/`, `pages/admin/`, or `pages/master/`

### Debug System ⚠️ REMOVE BEFORE PRODUCTION
- Red debug button in `splash_screen.dart` and `user_homepage.dart` opens `debug_page.dart`
- Central navigation hub for testing all pages
- **Critical**: Remove debug button, imports, and entire `lib/dev/` directory before release

## Key Files Reference
- `lib/main.dart` - Entry point, Firebase init, auth state routing
- `lib/pages/splash_screen.dart` - Landing page with login/signup (modern gradient UI)
- `lib/pages/user/user_login.dart` - User authentication with Firebase Auth
- `lib/pages/user/user_signup.dart` - User registration with role='user'
- `lib/pages/user/user_homepage.dart` - User dashboard (responsive layout)
- `lib/pages/user/user_profile.dart` - User profile management with profile picture upload
- `lib/pages/user/user_travel_requirments.dart` - Destination selector, checklist creator
- `lib/pages/user/user_documents_checklist.dart` - Document upload/status tracking
- `lib/pages/user/user_view_document_with_ai.dart` - Document viewer with AI analysis results
- `lib/pages/admin/admin_login.dart` - Admin authentication with role verification
- `lib/pages/admin/admin_dashboard.dart` - Admin dashboard with quick actions
- `lib/pages/master/master_login.dart` - Master authentication with role verification
- `lib/utils/user_app_drawer.dart` - **User navigation drawer** (use for all user pages)
- `lib/utils/admin_app_drawer.dart` - **Admin navigation drawer** (use for all admin pages)
- `lib/utils/checklist_helper.dart` - Shared checklist navigation logic
- `lib/dev/template.dart` - Page template with back button
- `lib/dev/template_with_menu.dart` - Page template with drawer menu
- `lib/dev/debug_page.dart` - Dev navigation hub (**remove for prod**)
- `firebase/storage.rules` - Firebase Storage security rules (profile pictures, documents)
- `functions/index.js` - Cloud Function for AI document analysis (OpenAI GPT-4 Vision)
- `functions/SECRETS_SETUP.md` - Instructions for configuring OpenAI API key securely
- `ADMIN_MASTER_SETUP.md` - Guide for creating admin/master accounts securely

## Recurring Code Patterns

### Standard Back Button
```dart
Positioned(
  top: 50, left: 30,
  child: Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back, color: Colors.black),
    ),
  ),
)
```

### Card Container Style
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0xFF348AA7), width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Padding(padding: const EdgeInsets.all(16), child: /* content */),
)
```

### Image Upload Pattern (Profile Pictures & Documents)
```dart
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

// 1. Pick image (camera or gallery)
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: ImageSource.camera,  // or ImageSource.gallery
  imageQuality: 85,
);

// 2. Optimize image (different sizes for profiles vs documents)
final bytes = await image.readAsBytes();
final decodedImage = img.decodeImage(bytes);
final resized = img.copyResize(
  decodedImage!,
  width: 800,   // 800 for profiles, 1920 for documents
  height: 800,  // 800 for profiles, 1920 for documents
);
final compressedBytes = img.encodeJpg(resized, quality: 85);

// 3. Upload to Firebase Storage
final storageRef = FirebaseStorage.instance.ref();
final fileRef = storageRef.child('user_profiles/$userId/profile_${userId}_${timestamp}.jpg');
await fileRef.putData(compressedBytes);
final downloadUrl = await fileRef.getDownloadURL();

// 4. Update Firestore with URL
await FirebaseFirestore.instance.collection('users').doc(userId).update({
  'profileImageUrl': downloadUrl,
});
```

### Pull-to-Refresh Pattern
```dart
RefreshIndicator(
  onRefresh: _loadData,  // Async method that fetches fresh data
  color: const Color(0xFF348AA7),  // Teal brand color
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),  // Enable pull even when content fits screen
    children: [/* content */],
  ),
)
```

## Known Limitations
- **No tests** - `test/` directory unused
- **iOS untested** - Android only
- **AI cannot analyze passports** - OpenAI blocks sensitive PII documents; admins must manually review
- **Admin workflows incomplete** - Admin/Master role pages partially implemented
- Typography: 'Kumbh Sans' set globally in `main.dart` but also specified locally in widgets

## AI Document Verification Workflow

### How It Works (Cloud Function Pipeline)
1. **User uploads document** → Firebase Storage (`user_documents/{userId}/{country}/{docType}/`)
2. **Cloud Function triggers** → `onObjectFinalized` event fires
3. **Status update** → Firestore status changes to `'verifying'`
4. **OpenAI analysis** → GPT-4 Vision analyzes public download URL
5. **Results saved** → Firestore updated with `extractedData`, `aiFeedback`, status
6. **User notified** → Pull-to-refresh shows updated status

### Supported Documents (with Limitations)
- ✅ **flight_ticket** - Extracts passenger, airline, flight number, dates, booking code
- ✅ **visa** - Extracts visa type, number, validity dates, applicant info
- ✅ **proof_of_accommodation** - Extracts hotel name, booking ref, check-in/out dates
- ❌ **valid_passport** - OpenAI blocks PII analysis; returns error → admin manual review required

### Cloud Function Configuration
```javascript
// functions/index.js
// Key points:
// - Timeout: 300 seconds (AI analysis can be slow)
// - Memory: 1GiB (handles large images)
// - Secret: OPENAI_API_KEY via Firebase Secret Manager
// - Model: gpt-4o (latest with vision)
// - Temperature: 0.2 (consistent results)
// - Max tokens: 1500
```

### Testing AI Locally
```powershell
# 1. Set up OpenAI API key in functions/.env
cd functions
echo "OPENAI_API_KEY=sk-..." > .env

# 2. Start Firebase emulators
firebase emulators:start

# 3. Upload test document via app (points to emulator)
# OR manually trigger via Firebase Console Storage
```

### Debugging AI Failures
- Check Cloud Functions logs: Firebase Console → Functions → Logs
- Common issues:
  - Missing OPENAI_API_KEY secret in production
  - Image URL not publicly accessible (check storage.rules)
  - OpenAI API rate limits or billing issues
  - Invalid document type (typo in Firestore key)
  - Image too large or corrupted

## Recently Implemented Features

### ✅ Role-Based Authentication System
- Unified auth: Firebase Auth + Firestore `role` field ('user', 'admin', 'master')
- Login flows verify role and route to appropriate dashboard
- Admin/master accounts created manually via Firebase Console (see `ADMIN_MASTER_SETUP.md`)
- **Security**: NO passwords stored in Firestore, only in Firebase Auth

### ✅ Profile Picture Upload
- Firebase Storage path: `user_profiles/{userId}/profile_{userId}_{timestamp}.jpg`
- Image optimization: 800×800px, 85% quality, max 5MB
- Camera and gallery options via `image_picker`
- See `PROFILE_PICTURE_IMPLEMENTATION.md` for details

### ✅ Travel Documents Upload
- Firebase Storage path: `user_documents/{userId}/{country}/{docType}/{fileName}`
- Image optimization: 1920×1920px, 85% quality, max 10MB
- Auto-status change to `'verifying'` after upload
- Re-upload functionality on document view page
- See `TRAVEL_DOCUMENTS_UPLOAD.md` for details

### ✅ AI Document Verification
- Cloud Function (`functions/index.js`) triggers on Storage upload
- OpenAI GPT-4 Vision analyzes documents and extracts structured data
- **Limitation**: Cannot analyze passports due to OpenAI PII restrictions
- API key stored in Firebase Secret Manager (production) or `.env` (local)
- Public Storage URLs required for AI access (see `firebase/storage.rules`)
- See `functions/SECRETS_SETUP.md` for configuration

### ✅ Announcements System
- Firestore collection: `announcements` (title, content, date, createdBy)
- **Admin/Master**: Full CRUD with card-based UI and StreamBuilder
- **User**: Read-only with preview cards and "Read More" dialog
- Security rules enforce role-based access control

### ✅ Enhanced Document UI
- Modern card designs with 20px border radius
- Color-coded status badges and AI feedback
- Full-width image previews (200×200px)
- Side-by-side action buttons (re-upload, view full)

### ✅ Pull-to-Refresh Functionality
- `RefreshIndicator` on checklist and document view pages
- Teal color (0xFF348AA7) matching app branding
- Critical for real-time status updates from AI/admin reviews

### ✅ Firestore Key Format Consistency
- **All keys use** `lowercase_with_underscores`
- Countries: `japan`, `hong_kong`, `singapore`, `south_korea`, `china`
- Documents: `flight_ticket`, `valid_passport`, `visa`, `proof_of_accommodation`
- Prevents data mismatch between app, Cloud Functions, and Storage

## Before Production Checklist
- [ ] Remove `lib/dev/debug_page.dart` and all imports
- [ ] Remove debug button from `splash_screen.dart` and `user_homepage.dart`
- [x] ~~Deploy Firebase Storage security rules~~ (COMPLETE - public read for AI)
- [x] ~~Implement Firebase Storage for document uploads~~ (COMPLETE)
- [x] ~~Implement AI document verification backend~~ (COMPLETE - Cloud Function with OpenAI)
- [ ] Configure OpenAI API key in production (see `functions/SECRETS_SETUP.md`)
- [ ] Add comprehensive form validation
- [ ] Replace SnackBar error handling with proper UI
- [ ] Test on physical Android devices
- [ ] Complete admin review workflow for manual document verification
- [ ] Add iOS permissions to Info.plist for camera/photo library
- [ ] Implement cleanup Cloud Function for old profile pictures
- [ ] Implement cleanup Cloud Function for old travel documents
- [ ] Add document viewer with zoom/pan functionality
- [ ] Monitor OpenAI API usage and set billing alerts
- [ ] Add real-time Firestore listeners for status updates (optional)
- [ ] Implement confidence scoring for AI results (optional)
- [ ] Add retry logic for OpenAI API failures (optional)