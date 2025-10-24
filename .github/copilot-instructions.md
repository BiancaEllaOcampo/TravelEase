# TravelEase - AI Coding Instructions

## Project Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but not the focus). Three-tier role system: **User** (travelers), **Admin** (document reviewers), and **Master** (super admins).

**Core Technology Stack:**
- Flutter/Dart for cross-platform mobile UI
- Firebase Auth + Firestore for unified authentication with role-based access
- Firebase Storage for documents (max 10MB, images only) and profile pictures (max 5MB)
- Firebase Cloud Functions + OpenAI GPT-4 Vision for AI document analysis
- **No state management libraries** - pure StatefulWidget + TextEditingController pattern

## Critical Architecture Decisions

### 1. Stack-Based Absolute Positioning (Not Responsive)
**Most pages use `Stack` + `Positioned` for pixel-perfect layouts:**
```dart
// Pattern used in 90% of pages (see lib/dev/template.dart)
Stack(
  children: [
    Container(color: Color(0xFFD9D9D9)), // Full background
    Positioned(top: 50, left: 30, child: /* Back button */),
    Positioned(top: 125, left: 30, right: 30, child: /* Content */),
  ],
)
```
**Exception**: `user_homepage.dart` uses responsive `Column` + `ScrollView`.

### 2. Custom 130px AppBar (Never Use Standard AppBar)
**All pages use `PreferredSize` wrapper:**
```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(130),
  child: Container(
    height: 130,
    color: const Color(0xFF125E77), // Dark teal
    child: Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: Row(/* menu/back + title + logo */),
    ),
  ),
)
```

### 3. Hard-Coded Brand Colors (No Theme Lookups)
```dart
// ALWAYS use hex codes directly:
0xFF125E77  // Dark teal (headers, primary text)
0xFF348AA7  // Light teal (buttons, borders)
0xFFD9D9D9  // Light gray (backgrounds)
0xFFA54547  // Red (errors, "needs_correction")
0xFF34C759  // Green ("verified")
0xFFFFA500  // Orange ("verifying")
```
**Don't use**: `Theme.of(context).primaryColor` - colors are hard-coded everywhere.

### 4. Unified Role-Based Authentication
**All roles (User/Admin/Master) share Firebase Auth + Firestore:**
```dart
// CRITICAL: Passwords NEVER in Firestore - only in Firebase Auth
users/{userId} {
  role: "user" | "admin" | "master",  // Role stored here
  email, fullName, profileImageUrl,
  checklists: {...}  // Documents nested here
}
```
**Login pattern**: Authenticate → Fetch Firestore profile → Check `role` field → Route to dashboard.

### 5. Firestore Naming Convention: `lowercase_with_underscores`
**⚠️ CRITICAL: These exact strings are hardcoded in multiple places!**
```dart
// Countries (must match in app, Cloud Functions, Storage paths)
const COUNTRIES = ['japan', 'hong_kong', 'south_korea', 'singapore', 'china'];

// Document Types (must match Cloud Function prompts)
const DOC_TYPES = [
  'flight_ticket',           // ✅ AI supported
  'valid_passport',          // ⚠️ OpenAI may reject (PII)
  'visa',                    // ✅ AI supported
  'proof_of_accommodation'   // ✅ AI supported
];

// Status Values (state machine)
const STATUSES = ['pending', 'verifying', 'verified', 'needs_correction'];

// Role Values (authorization)
const ROLES = ['user', 'admin', 'master'];
```

**Where These Are Used:**
1. Flutter: `user_documents_checklist.dart` - `requirementsByCountry` map
2. Cloud Function: `functions/index.js` - `getPromptForDocType()` switch
3. Storage paths: `user_documents/{userId}/{country}/{docType}/{fileName}`
4. Firestore paths: `users/{uid}/checklists/{country}/{docType}`

**Changing These Requires:**
- [ ] Update Flutter `requirementsByCountry` map in `user_documents_checklist.dart`
- [ ] Update Cloud Function prompts in `functions/index.js`
- [ ] Update Storage rules in `firebase/storage.rules`
- [ ] Migrate existing Firestore data (write migration script)
- [ ] Update any hardcoded string literals across codebase

## Essential Development Patterns

### Centralized Navigation Drawers (NEVER Copy/Paste)
```dart
import '../../utils/user_app_drawer.dart';   // For user pages
import '../../utils/admin_app_drawer.dart';  // For admin pages
import '../../utils/master_app_drawer.dart'; // For master pages

Scaffold(drawer: const UserAppDrawer())  // Import, don't duplicate
```

### Shared Checklist Navigation
```dart
// ALWAYS use helper instead of duplicating logic
import '../../utils/checklist_helper.dart';
await ChecklistHelper.navigateToChecklist(context);
```

### Auth Guard Pattern (Copy This to All Protected Pages)
```dart
@override
Widget build(BuildContext context) {
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
  // For admin/master pages, also fetch and check role field
}
```

### Image Upload Pattern
**Complete implementation with error handling:**
```dart
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Configuration Constants
const int PROFILE_MAX_SIZE = 5 * 1024 * 1024;    // 5MB
const int DOCUMENT_MAX_SIZE = 10 * 1024 * 1024;  // 10MB
const int PROFILE_MAX_WIDTH = 800;
const int PROFILE_MAX_HEIGHT = 800;
const int DOCUMENT_MAX_WIDTH = 1920;
const int DOCUMENT_MAX_HEIGHT = 1920;
const int IMAGE_QUALITY = 85;

// 1. Pick image (with source selection)
Future<void> _uploadImage({required bool isDocument}) async {
  final ImagePicker picker = ImagePicker();
  
  // Show source selection (camera or gallery)
  final ImageSource? source = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Select Image Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  
  if (source == null) return;
  
  final XFile? image = await picker.pickImage(
    source: source,
    maxWidth: isDocument ? DOCUMENT_MAX_WIDTH : PROFILE_MAX_WIDTH,
    maxHeight: isDocument ? DOCUMENT_MAX_HEIGHT : PROFILE_MAX_HEIGHT,
    imageQuality: IMAGE_QUALITY,
  );
  
  if (image == null) return;
  
  // 2. Upload to Storage with proper paths
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not authenticated');
  
  setState(() => _isUploading = true);
  
  try {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = isDocument 
      ? 'doc_${country}_${docType}_$timestamp.jpg'
      : 'profile_${user.uid}_$timestamp.jpg';
    
    // Build Storage reference - EXACT PATH STRUCTURE REQUIRED
    final Reference storageRef = isDocument
      ? FirebaseStorage.instance.ref()
          .child('user_documents')
          .child(user.uid)
          .child(country)           // e.g., 'japan', 'hong_kong'
          .child(docType)           // e.g., 'flight_ticket', 'visa'
          .child(fileName)
      : FirebaseStorage.instance.ref()
          .child('user_profiles')
          .child(user.uid)
          .child(fileName);
    
    // Upload with metadata
    final File file = File(image.path);
    final UploadTask uploadTask = storageRef.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
          'type': isDocument ? 'document' : 'profile',
        },
      ),
    );
    
    // Wait for upload
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    
    // 3. Update Firestore using dot notation (CRITICAL!)
    if (isDocument) {
      // For documents: triggers AI Cloud Function
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'checklists.$country.$docType.status': 'verifying',
        'checklists.$country.$docType.url': downloadUrl,
        'checklists.$country.$docType.updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // For profile pictures
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDocument 
            ? 'Document uploaded! AI analysis in progress...' 
            : 'Profile picture updated!'),
          backgroundColor: Color(0xFF34C759),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Color(0xFFA54547),
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isUploading = false);
  }
}
```

**Storage Path Requirements:**
- Profile: `user_profiles/{userId}/profile_{userId}_{timestamp}.jpg`
- Documents: `user_documents/{userId}/{country}/{docType}/{fileName}`
- **Must be EXACT** - Cloud Function parses path with `split('/')` expecting 5 parts for documents

### Pull-to-Refresh Pattern
```dart
RefreshIndicator(
  onRefresh: _loadData,  // Async reload method
  color: const Color(0xFF348AA7),
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),  // Critical!
    children: [/* content */],
  ),
)
```

## Firebase Configuration (CRITICAL - DO NOT MODIFY WITHOUT TESTING)

### Firestore Security Rules (`firebase/firestore.rules`)
**Helper Functions - Used Throughout Rules:**
```javascript
function isAuthenticated() {
  return request.auth != null;
}

function getUserRole() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
}

function isAdmin() {
  return isAuthenticated() && getUserRole() == 'admin';
}

function isMaster() {
  return isAuthenticated() && getUserRole() == 'master';
}

function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

**Users Collection Rules:**
```javascript
match /users/{userId} {
  // Read: Owner OR Admin OR Master
  allow read: if isOwner(userId) || isAdmin() || isMaster();
  
  // Create: Must match own UID during signup
  allow create: if isAuthenticated() && request.auth.uid == userId;
  
  // Update: Owner OR Master (masters can change roles)
  allow update: if isOwner(userId) || isMaster();
  
  // Delete: Master only
  allow delete: if isMaster();
  
  // Nested checklist subcollection
  match /checklists/{country}/{document=**} {
    allow read: if isOwner(userId) || isAdmin() || isMaster();
    allow write: if isOwner(userId);  // Only owner can modify
  }
}
```

**Announcements Collection Rules:**
```javascript
match /announcements/{announcementId} {
  allow read: if request.auth != null;  // All authenticated users
  allow create, update, delete: if isAdmin() || isMaster();  // Admin/Master only
}
```

### Firebase Storage Rules (`firebase/storage.rules`)
**⚠️ CRITICAL: Public read required for AI to access images!**

```javascript
// Profile Pictures (5MB limit, auth required for read)
match /user_profiles/{userId}/{fileName} {
  allow read: if request.auth != null;  // Any authenticated user
  allow write: if request.auth != null 
               && request.auth.uid == userId
               && request.resource.size < 5 * 1024 * 1024  // 5MB
               && request.resource.contentType.matches('image/.*');
}

// Travel Documents (10MB limit, PUBLIC READ for AI)
match /user_documents/{userId}/{country}/{documentType}/{fileName} {
  allow read: if true;  // ⚠️ PUBLIC - OpenAI needs this!
  allow write: if request.auth != null 
               && request.auth.uid == userId
               && request.resource.size < 10 * 1024 * 1024  // 10MB
               && request.resource.contentType.matches('image/.*');
}
```

### Firestore Data Structure (EXACT SCHEMA)
```javascript
users/{userId}/
  email: string
  fullName: string
  phoneNumber: string (optional)
  address: string (optional)
  role: "user" | "admin" | "master"  // CRITICAL for authorization
  profileImageUrl: string (Storage URL)
  createdAt: timestamp
  updatedAt: timestamp
  checklists: {  // Map, NOT subcollection
    [country]: {  // ONE country only: "japan", "hong_kong", "south_korea", "singapore", "china"
      [documentType]: {  // "flight_ticket", "valid_passport", "visa", "proof_of_accommodation"
        status: "pending" | "verifying" | "verified" | "needs_correction"
        url: string (Storage download URL)
        updatedAt: timestamp
        analyzedAt: timestamp (when AI last ran)
        extractedData: map {  // AI-extracted fields
          // Document-specific fields (see AI section)
        }
        aiFeedback: string (AI analysis result or error message)
      }
    }
  }

announcements/{announcementId}/
  title: string
  content: string
  date: timestamp
  createdBy: string (userId of admin/master)
```

### Firestore Update Pattern (CRITICAL)
**Use dot notation for nested updates to avoid overwriting:**
```dart
// ✅ CORRECT - Updates specific field only
await FirebaseFirestore.instance.collection('users').doc(userId).update({
  'checklists.japan.flight_ticket.status': 'verifying',
  'checklists.japan.flight_ticket.url': downloadUrl,
  'checklists.japan.flight_ticket.updatedAt': FieldValue.serverTimestamp(),
});

// ❌ WRONG - Overwrites entire checklists map
await FirebaseFirestore.instance.collection('users').doc(userId).update({
  'checklists': {
    'japan': {'flight_ticket': {...}}  // Deletes other documents!
  }
});
```

## AI Document Verification Pipeline (CRITICAL - OpenAI Integration)

### Complete Flow
1. **User uploads** → Flutter calls `FirebaseStorage.instance.ref().child('user_documents/$userId/$country/$docType/$fileName').putFile()`
2. **Storage trigger** → `onObjectFinalized` event fires in `functions/index.js`
3. **Path validation** → Must match exact pattern: `user_documents/{userId}/{country}/{docType}/{fileName}`
4. **Status update** → Firestore: `checklists.{country}.{docType}.status = 'verifying'`
5. **URL generation** → Public URL: `https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encodedPath}?alt=media`
6. **OpenAI call** → POST to `https://api.openai.com/v1/chat/completions`
7. **Result parsing** → Extract JSON from AI response
8. **Firestore update** → Save `extractedData`, `aiFeedback`, `status`, `analyzedAt`

### Cloud Function Configuration (`functions/index.js`)
**⚠️ DO NOT CHANGE THESE VALUES WITHOUT TESTING:**
```javascript
const {onObjectFinalized} = require("firebase-functions/v2/storage");
const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");

setGlobalOptions({
  timeoutSeconds: 300,    // ⚠️ AI needs time - don't reduce below 180
  memory: "1GiB",         // ⚠️ Large images need memory - don't reduce
});

const openaiApiKey = defineSecret("OPENAI_API_KEY");  // Secret Manager in production

exports.analyzeDocument = onObjectFinalized(
  { secrets: [openaiApiKey] },  // Grant access to secret
  async (event) => {
    // Function logic...
  }
);
```

### OpenAI API Configuration
**Model: `gpt-4o` (latest with vision)**
```javascript
{
  model: "gpt-4o",              // ⚠️ Don't use gpt-4-vision-preview (deprecated)
  messages: [{
    role: "user",
    content: [
      { type: "text", text: prompt },
      { 
        type: "image_url",
        image_url: {
          url: imageUrl,        // Public Firebase Storage URL
          detail: "high"        // ⚠️ Required for OCR accuracy
        }
      }
    ]
  }],
  max_tokens: 1500,             // ⚠️ Increase if responses truncated
  temperature: 0.2              // ⚠️ Low for consistency (0.0-0.3 recommended)
}
```

### Document Type Prompts (EXACT FORMATS)
**Each prompt expects JSON response:**
```javascript
{
  "isValid": true/false,
  "extractedData": { /* document-specific fields */ },
  "feedback": "Detailed explanation or 'No issues detected'"
}
```

**Flight Ticket (`flight_ticket`):**
- passenger, airline, flightNumber, departure, departureDate, arrival, arrivalDate, bookingCode

**Valid Passport (`valid_passport`):**
- fullName, passportNumber, nationality, dateOfBirth, expiryDate
- ⚠️ **OpenAI may reject** due to PII policy → returns error → admin manual review

**Visa (`visa`):**
- visaType, visaNumber, fullName, validFrom, validUntil

**Proof of Accommodation (`proof_of_accommodation`):**
- hotelName, bookingRef, guestName, checkIn, checkOut

### Error Handling in Cloud Function
```javascript
try {
  // AI analysis
} catch (error) {
  console.error("❌ Error analyzing document:", error);
  
  // ⚠️ CRITICAL: Mark as needs_correction, NOT pending
  await admin.firestore().collection("users").doc(userId).update({
    [`checklists.${country}.${docType}.status`]: "needs_correction",
    [`checklists.${country}.${docType}.aiFeedback`]: `Error: ${error.message}. Please try again.`,
  });
}
```

### Local Testing Setup
```powershell
# 1. Create .env in functions/ directory (gitignored)
cd functions
echo "OPENAI_API_KEY=sk-proj-..." > .env

# 2. Install dependencies
npm install

# 3. Start emulators (uses .env automatically)
firebase emulators:start

# 4. Test upload via app (points to emulator Storage)
# Emulator logs show AI analysis in real-time
```

### Production Secret Manager Setup
```powershell
# Set secret in Google Cloud (do ONCE per project)
firebase functions:secrets:set OPENAI_API_KEY

# Deploy function with secret access
firebase deploy --only functions

# View secret value (if needed)
firebase functions:secrets:access OPENAI_API_KEY
```

### Common AI Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Status stuck on "verifying" | Function timeout/crash | Check Cloud Functions logs in Firebase Console |
| "Public URL not accessible" | Storage rules wrong | Ensure `allow read: if true` for `user_documents/**` |
| "OPENAI_API_KEY not configured" | Missing secret | Run `firebase functions:secrets:set OPENAI_API_KEY` |
| Passport analysis fails | OpenAI PII policy | Expected - admins must manually verify passports |
| JSON parse error | Malformed AI response | Check `parseAIResponse()` - may need prompt tuning |
| Rate limit error | Too many API calls | OpenAI has TPM/RPM limits - add retry logic |

### Monitoring AI Performance
```dart
// In Flutter, check analyzedAt timestamp
final doc = await FirebaseFirestore.instance
  .collection('users').doc(userId).get();
final checklist = doc.data()?['checklists']?[country]?[docType];

print('Status: ${checklist['status']}');
print('AI Feedback: ${checklist['aiFeedback']}');
print('Analyzed At: ${checklist['analyzedAt']}');
print('Extracted Data: ${checklist['extractedData']}');
```

## Creating New Pages

### Quick Start
1. **Copy template**: `lib/dev/template.dart` (back button) or `template_with_menu.dart` (drawer)
2. **Adjust `Positioned` coordinates**: Hardcoded layout, measure from designs
3. **Add auth guard**: Copy pattern from `user_documents_checklist.dart`
4. **Place in role folder**: `pages/user/`, `pages/admin/`, or `pages/master/`

### Standard Back Button (Recurring Pattern)
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

## Essential Commands (PowerShell)

```powershell
# Flutter Development
flutter pub get                           # Install dependencies
flutter run                               # Run on default device
flutter run -d <device-id>                # Specify device
flutter clean                             # Clean build cache
flutter build apk                         # Production build

# Firebase Deployment
firebase deploy --only firestore:rules    # Deploy Firestore security rules
firebase deploy --only storage            # Deploy Storage security rules
firebase deploy --only functions          # Deploy Cloud Functions
firebase emulators:start                  # Local testing (requires .env in functions/)

# Local AI Testing
cd functions; echo "OPENAI_API_KEY=sk-..." > .env; cd ..
firebase emulators:start
```

## Critical Dependencies & Versions

**Flutter SDK:** `^3.9.2`

**Core Firebase Packages (pubspec.yaml):**
```yaml
firebase_core: ^4.1.1        # Firebase initialization
firebase_auth: ^6.1.0        # Authentication
cloud_firestore: ^6.0.3     # Database
firebase_storage: ^13.0.3   # File storage
```

**Other Dependencies:**
```yaml
flutter_dotenv: ^6.0.0      # Environment variables (.env file)
url_launcher: ^6.2.0        # Open external URLs
image_picker: ^1.0.7        # Camera/gallery access
intl: ^0.20.2               # Date formatting
```

**Cloud Function Dependencies (functions/package.json):**
```json
{
  "firebase-admin": "^12.0.0",  // Firestore/Storage access
  "firebase-functions": "^5.0.0",  // Cloud Functions v2
  "axios": "^1.6.0"  // HTTP client for OpenAI API
}
```

**⚠️ Breaking Change Warnings:**
- Firebase packages use null-safety - keep versions aligned
- Cloud Functions v2 required for `defineSecret()` API
- `image_picker` requires Android permissions in `AndroidManifest.xml`
- OpenAI API model `gpt-4o` - don't downgrade to `gpt-4-vision-preview`

## Known Constraints & Gotchas

- **One Checklist Per User**: Firestore enforces single country per user. Use `update()` (not `merge`) to replace.
- **No Tests**: `test/` directory unused. Manual testing only.
- **iOS Untested**: Android-only development and QA.
- **AI Passport Limitation**: OpenAI API blocks passports → admin manual verification required.
- **Debug System**: `lib/dev/debug_page.dart` with red button in splash/homepage. **REMOVE BEFORE PRODUCTION**.
- **Global Font**: 'Kumbh Sans' set in `main.dart` but also redundantly specified in widgets.

## Key Files Reference

**Must-read for context:**
- `lib/main.dart` - Entry point, Firebase init, StreamBuilder auth routing
- `firebase/firestore.rules` - Role-based access control helpers (`isAdmin()`, `isMaster()`)
- `firebase/storage.rules` - Public read for AI, size limits (5MB profiles, 10MB docs)
- `functions/index.js` - OpenAI integration, document analysis prompts
- `lib/utils/checklist_helper.dart` - Shared checklist navigation logic
- `lib/dev/template.dart` - Page template with standard layout

**Documentation:**
- `ADMIN_MASTER_SETUP.md` - Manual account creation via Firebase Console
- `functions/SECRETS_SETUP.md` - OpenAI API key setup (Secret Manager vs .env)
- `README.md` - Full setup instructions and architecture overview