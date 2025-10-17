# TravelEase AI Coding Instructions

## Project Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but inactive). Firebase-integrated with three user roles: **User**, **Admin**, and **Master**.

## Critical Architecture Decisions

### Three-Role System Architecture 
- **User**: End travelers managing documents and checklists (`lib/pages/user/`)
- **Admin**: System administrators managing users and requirements (`lib/pages/admin/`)  
- **Master**: Super administrators with full system control (`lib/pages/master/`)

Each role has dedicated login flows and dashboard interfaces.

### Layout Patterns
**Template Pages**: Most pages use `Stack` with `Positioned` widgets for pixel-perfect positioning:
```dart
// From template.dart - standard template structure
Stack(
  children: [
    Container(color: Color(0xFFD9D9D9)), // Full-screen background
    Positioned(top: 50, left: 30, child: /* Back button */),
    Positioned(top: 125, left: 30, right: 30, child: /* Content card */),
  ],
)
```

**User Homepage Exception**: `user_homepage.dart` uses a responsive Column layout instead:
```dart
// Responsive layout for user homepage
SingleChildScrollView(
  padding: EdgeInsets.symmetric(horizontal: 34, vertical: 31),
  child: Column(
    children: [
      // Dynamic spacing with SizedBox between elements
      SizedBox(height: 20),
      // Content widgets...
    ],
  ),
)
```
**Why the difference**: Homepage needs to be responsive across devices, while other pages prioritize exact design specifications.

### AppBar Pattern (Not Using Standard AppBar)
Uses `PreferredSize` widget for custom 130px header:
```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(130),
  child: Container(
    height: 130,
    color: const Color(0xFF125E77), // Primary dark color
    child: Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: Row(/* Title, logo, menu button */),
    ),
  ),
)
```

### Brand Colors (Hard-coded, No Theme)
- `0xFF125E77`: Dark teal (headers, titles, primary UI)  
- `0xFF348AA7`: Light teal (buttons, borders, accents, logo circles)  
- `0xFFD9D9D9`: Light gray (backgrounds)  
- `0xFFA54547`: Red (alerts/destructive actions, "Needs Correction" status)
- `0xFF34C759`: Green (success states, "Verified" status)
- `0xFFFFA500`: Yellow/Orange ("Verifying" status)

**Don't use `Theme.of(context).primaryColor`** - colors are directly specified throughout codebase.

### Document Status System
Document verification uses four status states with color coding:
- **Pending** (Teal `0xFF348AA7`): Initial state, awaiting upload
- **Verifying** (Yellow `0xFFFFA500`): Under review by admin
- **Verified** (Green `0xFF34C759`): Approved and valid
- **Needs Correction** (Red `0xFFA54547`): Rejected, requires resubmission

Status values in Firestore: `'pending'`, `'verifying'`, `'verified'`, `'needs_correction'`

### Firebase Integration
- Firebase Core and Auth configured for Android/iOS platforms
- Cloud Firestore configured for data persistence
- API keys and configuration in `lib/firebase_options.dart`
- **Authentication**: Firebase Auth integrated with user state management
- **Database Structure**:
  ```
  users/{userId}/
    - profile fields (fullName, email, phone, address, etc.)
    - checklists: {
        [country]: {
          [documentName]: {
            status: 'pending' | 'verifying' | 'verified' | 'needs_correction',
            url: '',
            updatedAt: timestamp
          }
        }
      }
  ```
- **Checklist Constraint**: Only ONE destination checklist allowed per user at a time (override behavior implemented)

## Development Workflow

### Creating New Pages
1. Copy `lib/dev/template.dart` (simple back button) or `template_with_menu.dart` (with drawer menu)
2. Adjust `Positioned` coordinates for your content layout
3. Add navigation entry to `lib/dev/debug_page.dart` for testing
4. Import in source pages that navigate to it
5. Follow role-based directory structure: `user/`, `admin/`, or `master/`

### Debug Navigation System
- `lib/dev/debug_page.dart`: Central navigation hub with ALL pages listed
- Access via red debug button in top-right of `splash_screen.dart`
- **CRITICAL**: Remove debug button and `debug_page.dart` imports before production
- Use `_buildDebugButton()` helper for consistent debug menu entries

### Running the App (Android-First)
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected Android device/emulator
flutter run -d <device-id>   # If multiple devices connected
flutter build apk            # Build Android APK for testing
```

**No tests exist yet** - the `test/` directory structure is not implemented.

## Code Patterns You'll See Everywhere

### Back Button Pattern
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

### Card Container Pattern
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

### Form State Management Pattern
- Uses `StatefulWidget` + `TextEditingController` (no Provider/Riverpod/Bloc)
- Validation is inline in button `onPressed` handlers
- User feedback via `ScaffoldMessenger.of(context).showSnackBar()`
- All forms have placeholder TODO comments for backend integration
- Example pattern in `lib/pages/user/user_login.dart`

### Navigation (No Named Routes)
```dart
// Direct MaterialPageRoute - used everywhere
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const UserHomePage()),
);
```

### Shared Utility Classes
- **ChecklistHelper** (`lib/utils/checklist_helper.dart`): Centralized navigation logic for document checklist access
  ```dart
  // Fetches user's existing checklist from Firestore, navigates accordingly
  ChecklistHelper.navigateToChecklist(context);
  ```
  - Checks authentication
  - Fetches existing checklist from Firestore
  - Navigates to checklist page if found, or redirects to Travel Requirements page
  - Used by: user_homepage.dart, template_with_menu.dart

### Two AppBar Variants
- **Simple**: Back button + title + logo (template.dart)
- **With Menu**: Hamburger menu + title + logo + drawer (template_with_menu.dart)

## Key Files
- `lib/main.dart`: Entry point, sets global font to 'Kumbh Sans', routes to `SplashScreen`
- `lib/pages/splash_screen.dart`: Landing page with login/signup buttons
- `lib/dev/debug_page.dart`: Dev-only navigation menu (remove for production)
- `lib/dev/template.dart`: Template for new pages
- `lib/pages/user/*.dart`: User-facing pages (login, signup, homepage, travel requirements)
- `lib/pages/admin/*.dart`: Admin pages (login, dashboard, user management)
- `lib/pages/master/*.dart`: Master admin pages (system-wide control)
- `lib/firebase_options.dart`: Firebase configuration for Android/iOS
- `lib/utils/checklist_helper.dart`: Shared utility for consistent checklist navigation

## Implemented Features

### User Profile & Navigation
- **User Homepage** (`lib/pages/user/user_homepage.dart`):
  - Responsive Column layout with dynamic spacing
  - "Go to Profile" button navigates to user profile page
  - "Documents Checklist" button uses ChecklistHelper for smart navigation
  - "View Announcements" button (placeholder for future implementation)
  - Import prefix pattern used to resolve TravelEaseDrawer symbol conflicts

### Document Checklist System
- **Travel Requirements** (`lib/pages/user/user_travel_requirments.dart`):
  - Firebase integration: Saves checklist to Firestore before navigation
  - Override confirmation dialog when changing destination
  - Properly replaces entire checklist when selecting new destination (uses `update()` instead of `merge`)
  - One checklist per user constraint enforced
  
- **Documents Checklist** (`lib/pages/user/user_documents_checklist.dart`):
  - Loads country-specific checklist from Firestore
  - Four status states: pending, verifying, verified, needs_correction
  - Color-coded status indicators
  - Progress saving to Firestore
  - File upload integration (TODO: Connect to Firebase Storage)
  - AI report view (TODO: Implement AI analysis)

- **Shared Navigation** (`lib/utils/checklist_helper.dart`):
  - Centralized logic for accessing document checklist
  - Fetches existing checklist from Firestore
  - Smart routing: Navigate to existing checklist or redirect to Travel Requirements

### Menu Integration
- **TravelEaseDrawer** (`lib/dev/template_with_menu.dart`):
  - "View My Documents" menu item uses ChecklistHelper for consistent navigation
  - Profile, Settings, Support menu items (placeholders for future implementation)

## Important Constraints
- **No state management library**: Just StatefulWidget + local controllers
- **No routing library**: Direct Navigator.push everywhere
- **iOS not tested**: Android emulator/device only
- **Typography**: 'Kumbh Sans' font family hardcoded in all TextStyle widgets (set globally but also repeated locally)
- **One checklist per user**: Users can only have one active destination checklist at a time (override behavior enforced)

## Known Issues & Future Work
- **File Upload**: Document upload UI exists but needs Firebase Storage integration
- **AI Analysis**: AI feedback report functionality not yet implemented
- **Announcements Page**: Button exists but page not created
- **Menu TODOs**: About Us, Feedback, Support, Settings, Privacy Policy, Terms of Service pages
- **Admin/Master Roles**: Backend integration for admin review workflow not implemented

## Before Production
- Remove `lib/dev/debug_page.dart` and its imports
- Remove debug button from `splash_screen.dart`
- Implement proper form validation
- Add backend API integration
- Add proper error handling beyond SnackBars
- Test on physical Android devices
- Implement proper form validation
- Add backend API integration
- Add proper error handling beyond SnackBars
- Test on physical Android devices