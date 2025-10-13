# TravelEase AI Coding Instructions

## Project Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but inactive). Firebase-integrated with three user roles: **User**, **Admin**, and **Master**.

## Critical Architecture Decisions

### Three-Role System Architecture 
- **User**: End travelers managing documents and checklists (`lib/pages/user/`)
- **Admin**: System administrators managing users and requirements (`lib/pages/admin/`)  
- **Master**: Super administrators with full system control (`lib/pages/master/`)

Each role has dedicated login flows and dashboard interfaces.

### Stack-Based Absolute Positioning (Not Standard Flutter Layouts!)
Every page uses `Stack` with `Positioned` widgets instead of Column/Row:
```dart
// From template.dart - all pages follow this structure
Stack(
  children: [
    Container(color: Color(0xFFD9D9D9)), // Full-screen background
    Positioned(top: 50, left: 30, child: /* Back button */),
    Positioned(top: 125, left: 30, right: 30, child: /* Content card */),
  ],
)
```
**Why**: Design requires pixel-perfect positioning. Don't refactor to Column/ListView without understanding this constraint.

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
- `0xFFA54547`: Red (alerts/destructive actions)

**Don't use `Theme.of(context).primaryColor`** - colors are directly specified throughout codebase.

### Firebase Integration
- Firebase Core and Auth configured for Android/iOS platforms
- API keys and configuration in `lib/firebase_options.dart` 
- Authentication ready but forms still have TODO placeholders for backend integration

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

## Important Constraints
- **No backend integration yet**: Forms have TODO comments where API calls should go
- **No state management library**: Just StatefulWidget + local controllers
- **No routing library**: Direct Navigator.push everywhere
- **No database/persistence**: All data is ephemeral
- **iOS not tested**: Android emulator/device only
- **Typography**: 'Kumbh Sans' font family hardcoded in all TextStyle widgets (set globally but also repeated locally)

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