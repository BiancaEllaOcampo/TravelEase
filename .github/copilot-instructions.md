# TravelEase AI Coding Instructions

## Project Overview
Flutter mobile app for Philippine travel document verification with AI-assisted checklists. **Android-first** development (iOS structure exists but inactive). Pure Flutter - no external packages for auth/networking yet.

## Critical Architecture Decisions

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
- `0xFF125E77`: Dark teal (headers, titles)  
- `0xFF348AA7`: Light teal (buttons, borders, accents)  
- `0xFFD9D9D9`: Light gray (backgrounds)  
- `0xFFA54547`: Red (alerts/destructive actions)

**Don't use `Theme.of(context).primaryColor`** - colors are directly specified throughout codebase.

## Development Workflow

### Creating New Pages
1. Copy `lib/dev/template.dart` (simple) or `template_with_menu.dart` (with drawer)
2. Adjust `Positioned` coordinates for your content
3. Add navigation entry to `lib/dev/debug_page.dart` for testing
4. Import in source pages that navigate to it

### Debug Navigation
- `lib/dev/debug_page.dart`: Central navigation hub during development
- Access via red button in top-right of `splash_screen.dart`
- **Remove before production**: Delete debug button and `debug_page.dart` imports

### Running the App
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected Android device/emulator
flutter run -d <device-id>   # If multiple devices
flutter build apk            # Build Android APK
```

No tests exist yet (`test/` directory doesn't exist).

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

### Form State Management
- Uses `StatefulWidget` + `TextEditingController` (no Provider/Riverpod/Bloc)
- Validation is inline in button `onPressed` handlers
- User feedback via `ScaffoldMessenger.of(context).showSnackBar()`
- Example: `lib/pages/user_login.dart`

### Navigation (No Named Routes)
```dart
// Direct MaterialPageRoute - used everywhere
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const UserHomePage()),
);
```

## Key Files
- `lib/main.dart`: Entry point, sets global font to 'Kumbh Sans', routes to `SplashScreen`
- `lib/pages/splash_screen.dart`: Landing page with login/signup buttons
- `lib/dev/debug_page.dart`: Dev-only navigation menu (remove for production)
- `lib/dev/template.dart`: Template for new pages
- `lib/pages/user_*.dart`: User-facing pages (login, signup, homepage, travel requirements)
- `lib/pages/admin_*.dart`: Admin pages (login, dashboard, user management)

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