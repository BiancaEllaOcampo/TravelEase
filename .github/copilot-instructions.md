# TravelEase - AI Coding Instructions

## Architecture Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but not the focus). Three-tier role system: **User** (travelers), **Admin** (document reviewers), and **Master** (super admins).

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

### Navigation Drawer (UserAppDrawer)
**ALWAYS import from centralized location** - Never copy/paste the drawer class:
```dart
import '../../utils/user_app_drawer.dart';  // Adjust path as needed

Scaffold(
  drawer: const UserAppDrawer(),
  // ... rest of page
)
```
The user navigation drawer lives in `lib/utils/user_app_drawer.dart` as a single source of truth.
Future admin and master drawers will follow the same pattern (admin_app_drawer.dart, master_app_drawer.dart).

### Creating New Pages
1. Copy `lib/dev/template.dart` (simple back) or `template_with_menu.dart` (with drawer)
2. Adjust `Positioned` coordinates for layout
3. Add to `lib/dev/debug_page.dart` for testing
4. Place in role directory: `user/`, `admin/`, or `master/`

### Debug System ⚠️ REMOVE BEFORE PRODUCTION
- Red debug button in `splash_screen.dart` opens `debug_page.dart`
- Central navigation hub for all pages
- **Must remove** debug button and imports before release

### Running the App
```powershell
flutter pub get              # Install deps
flutter run                  # Run on Android device/emulator
flutter run -d <device-id>   # Specify device if multiple connected
flutter build apk            # Build APK
```

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

## Known Limitations
- **No tests** - `test/` directory unused
- **iOS untested** - Android only
- **AI cannot analyze passports** - OpenAI blocks sensitive PII documents; admins must manually review
- **Admin workflows incomplete** - Admin/Master role pages partially implemented
- Typography: 'Kumbh Sans' set globally in `main.dart` but also specified locally in widgets

## Recently Implemented Features
- ✅ **Role-Based Authentication System** - Unified auth with Firebase Auth + Firestore role field
  - All users (regular/admin/master) use same Firebase Auth system
  - Role stored in Firestore `users` collection: 'user', 'admin', or 'master'
  - Login flows verify role and route to appropriate dashboard
  - Admin/master accounts created manually via Firebase Console
  - NO passwords stored in Firestore (security best practice)
  - See `ADMIN_MASTER_SETUP.md` for admin/master account creation guide
  
- ✅ **Modern Splash Screen UI** - Enhanced landing page with gradient backgrounds, decorative circles, and polished button designs
  - LinearGradient background (teal to gray)
  - Reduced background image opacity for better text contrast
  - Gradient buttons with shadows
  - Enhanced typography with letter spacing
  
- ✅ **Profile Picture Upload** - Users can upload/change profile pictures via camera or gallery
  - Uses Firebase Storage (`user_profiles/{userId}/` path)
  - Image picker with camera and gallery options
  - Automatic image optimization (800×800, 85% quality)
  - Security rules limit uploads to 5MB, images only
  - Real-time UI updates with loading states
  - Proper error handling with user feedback
  - See `PROFILE_PICTURE_IMPLEMENTATION.md` for full technical details
  - See `DEPLOYMENT_GUIDE.md` for testing instructions

- ✅ **Travel Documents Upload** - Users can upload travel documents (passport, visa, flight tickets, etc.)
  - Uses Firebase Storage (`user_documents/{userId}/{country}/{docType}/` path)
  - Camera and gallery options via image picker
  - Automatic image optimization (1920×1920, 85% quality)
  - Security rules limit uploads to 10MB, images only
  - Auto-status change to 'verifying' after upload
  - Re-upload functionality on document view page
  - Loading overlays during upload
  - Success/error notifications
  - See `TRAVEL_DOCUMENTS_UPLOAD.md` for full technical details
  - See `UPLOAD_FEATURE_COMPLETE.md` for quick reference

- ✅ **AI Document Verification** - Automated document analysis using OpenAI GPT-4 Vision
  - Cloud Function triggers on document upload to Firebase Storage
  - Analyzes flight tickets, visas, and accommodation proofs
  - Extracts structured data (passenger names, flight numbers, dates, etc.)
  - Provides validation feedback (missing info, expiry warnings)
  - Updates Firestore with analysis results in real-time
  - **Limitation**: Cannot analyze passports due to OpenAI PII restrictions
  - API key stored securely in Firebase Secrets (Google Secret Manager)
  - Public Storage URLs for AI access (see `firebase/storage.rules`)
  - Document-specific prompts for each travel document type
  - Auto-status updates: `pending` → `verifying` → `verified`/`needs_correction`
  - See `functions/SECRETS_SETUP.md` for Cloud Function configuration
  - See `functions/index.js` for implementation details

- ✅ **Announcements System** - Role-based announcements for all users
  - **Admin Announcements** (`lib/pages/admin/admin_announcements.dart`)
    - Full CRUD operations (create, read, update, delete)
    - Modern card-based UI with gradient headers
    - Real-time updates via Firestore StreamBuilder
    - Filtered view: admins see all announcements
    - Date/time formatting with intl package
  - **Master Announcements** (`lib/pages/master/master_announcements.dart`)
    - Same CRUD capabilities as admin
    - Full system visibility and control
  - **User Announcements** (`lib/pages/user/user_announcements.dart`)
    - Read-only access (no create/edit/delete)
    - Modern preview cards with "Read More" functionality
    - Full-view dialog with gradient header
    - Empty/loading/error states with user-friendly messages
    - Integrated into user drawer and homepage
  - Firestore collection: `announcements` with fields: title, content, date, createdBy
  - Security rules enforce role-based access control

- ✅ **Enhanced Document UI** - Modern design for document viewing and management
  - **Document View Page** (`lib/pages/user/user_view_document_with_ai.dart`)
    - Empty state: 20px border radius, circular icon background, larger fonts
    - Document details card: 20px border radius, full-width image preview (200×200px)
    - Status badge in header with color-coded indicators
    - Card-style extracted data section with white field cards
    - Color-coded AI feedback (green for success, yellow for warnings)
    - Side-by-side action buttons (re-upload and view full)
    - Re-upload button with white icon (fixed purple icon bug)
  - **Checklist Page** (`lib/pages/user/user_documents_checklist.dart`)
    - Removed unused "Save Progress" and "View AI Report" buttons
    - Cleaner layout with reduced bottom bar (160px → 60px)
    - More screen space for document list
    - Help links preserved for user support

- ✅ **Pull-to-Refresh Functionality** - Real-time document status updates
  - **RefreshIndicator** added to both document pages
  - **Checklist Page**: Swipe down refreshes all document statuses for country
  - **Document View Page**: Swipe down refreshes individual document data
  - Teal color indicator (0xFF348AA7) matching app branding
  - AlwaysScrollableScrollPhysics for consistent behavior on short content
  - Reuses existing Firestore query methods (_loadChecklistData, _loadDocumentData)
  - Native iOS/Android pull-down gesture support
  - Automatic loading state and completion handling
  - Critical for document verification workflow (status changes from AI/admin)

- ✅ **Firestore Key Format Consistency** - All keys use `lowercase_with_underscores`
  - Countries: `japan`, `hong_kong`, `singapore`, `south_korea`, `china`
  - Documents: `flight_ticket`, `valid_passport`, `visa`, `proof_of_accommodation`
  - Prevents data mismatch between app, Cloud Functions, and Firebase Storage
  - User-facing display names converted to Firestore keys automatically

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