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
  checklists/
    {country}:  // Only ONE country per user (enforced)
      {documentName}: {
        status: string,
        url: string,
        updatedAt: timestamp
      }
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
- `lib/pages/splash_screen.dart` - Landing page with login/signup
- `lib/pages/user/user_homepage.dart` - User dashboard (responsive layout)
- `lib/pages/user/user_travel_requirments.dart` - Destination selector, checklist creator
- `lib/pages/user/user_documents_checklist.dart` - Document upload/status tracking
- `lib/utils/checklist_helper.dart` - Shared checklist navigation logic
- `lib/dev/template.dart` - Page template with back button
- `lib/dev/template_with_menu.dart` - Page template with drawer menu
- `lib/dev/debug_page.dart` - Dev navigation hub (**remove for prod**)

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
- **File upload TODO** - Document upload UI exists, needs Firebase Storage backend
- **AI analysis TODO** - Report view placeholder only
- **Admin workflows incomplete** - Admin/Master role pages partially implemented
- Typography: 'Kumbh Sans' set globally in `main.dart` but also specified locally in widgets

## Before Production Checklist
- [ ] Remove `lib/dev/debug_page.dart` and all imports
- [ ] Remove debug button from `splash_screen.dart`
- [ ] Implement Firebase Storage for document uploads
- [ ] Add comprehensive form validation
- [ ] Replace SnackBar error handling with proper UI
- [ ] Test on physical Android devices
- [ ] Complete admin review workflow
- [ ] Implement AI document verification backend