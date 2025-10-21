# TravelEase - AI Coding Instructions

## Architecture Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but not the focus). Three-tier role system: **User** (travelers), **Admin** (document reviewers), and **Master** (super admins).

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
All protected pages check auth state in build():
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
- `lib/pages/user/user_homepage.dart` - User dashboard (responsive layout)
- `lib/pages/user/user_profile.dart` - User profile management with profile picture upload
- `lib/pages/user/user_travel_requirments.dart` - Destination selector, checklist creator
- `lib/pages/user/user_documents_checklist.dart` - Document upload/status tracking
- `lib/pages/user/user_view_document_with_ai.dart` - Document viewer with AI analysis results
- `lib/utils/user_app_drawer.dart` - **User navigation drawer** (use for all user pages)
- `lib/utils/checklist_helper.dart` - Shared checklist navigation logic
- `lib/dev/template.dart` - Page template with back button
- `lib/dev/template_with_menu.dart` - Page template with drawer menu (imports user_app_drawer)
- `lib/dev/debug_page.dart` - Dev navigation hub (**remove for prod**)
- `firebase/storage.rules` - Firebase Storage security rules (profile pictures, documents)
- `functions/index.js` - Cloud Function for AI document analysis (OpenAI GPT-4 Vision)
- `functions/SECRETS_SETUP.md` - Instructions for configuring OpenAI API key securely

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