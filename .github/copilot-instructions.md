# TravelEase AI Coding Instructions

## Project Overview
TravelEase is a Flutter mobile app for Philippine travel document verification with AI-assisted checklist systems. Primary development target is Android, with iOS structure present but not actively developed.

## Architecture & Design Patterns

### UI Layout Strategy
All pages use **Stack-based absolute positioning** instead of standard Flutter layouts:
- Background container fills entire screen with `Color(0xFFD9D9D9)`
- Banner positioned at `top: 48, height: 82` with brand colors
- UI elements positioned with specific `Positioned` widgets and fixed coordinates
- Cards and buttons use precise pixel positioning (e.g., `top: 255, left: 30, right: 30`)

#### Card Styling Pattern
```dart
// Standard card container with blue border
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: const Color(0xFF348AA7),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: /* card content */,
  ),
)
```

Example from `template.dart` and `splash_screen.dart`:
```dart
Positioned(
  top: 48,
  left: 0,
  right: 0,
  height: 82,
  child: Container(
    color: const Color(0xFF125E77),
    // Banner content
  ),
),
```

### Color Scheme (Consistent Across All Pages)
- Primary dark: `Color(0xFF125E77)` (headers, titles)
- Primary light: `Color(0xFF348AA7)` (buttons, accents)
- Background: `Color(0xFFD9D9D9)` (light gray)
- Alert/Error: `Color(0xFFA54547)` (red for important actions)
- Text: White on colored backgrounds, black/dark on light backgrounds

### Typography Standards
- **Font Family**: 'Kumbh Sans' (set globally in `main.dart`)
- **Title Text**: 25px, FontWeight.bold, white on dark backgrounds
- **Body Text**: 16-20px, varies by context
- **Button Text**: 20-25px, FontWeight.bold, white
- **Welcome Text**: RichText with emphasized user name in bold
- **Feature Text**: 18px titles, 14px descriptions with grey[600] color

### Navigation Pattern
- Uses basic `Navigator.push/pop` - no named routes or advanced routing
- Back buttons are custom 60x60 white containers with black arrow icons
- Each page includes a debug-accessible `DebugPage` for development navigation
- Pages import their direct navigation targets (no central router)
- User homepage uses custom AppBar with menu, title, and logo layout
- Feature navigation uses list-style buttons with icons and descriptions

## Development Workflow

### Page Creation Process
1. Start with `template.dart` as the base structure
2. Copy the Stack layout with background, banner, and back button
3. Add page-specific content using `Positioned` widgets
4. Update banner text and add page to `debug_page.dart` for testing
5. Import new page in relevant navigation source files

### Debug & Development
- `debug_page.dart` provides navigation to all pages during development
- Red debug button in top-right of splash screen (remove for production)
- All form interactions show placeholder `TODO:` comments for backend integration
- SnackBar pattern used for user feedback (see `user_login.dart`)

### State Management
- Currently uses basic StatefulWidget for forms
- TextEditingController pattern for input fields
- No external state management (Redux, Provider, etc.) implemented yet
- Form validation is inline within button handlers

## Key Files & Structure

- `lib/main.dart`: App entry point, theme configuration, routes to SplashScreen
- `lib/pages/splash_screen.dart`: Landing page with login/signup options
- `lib/pages/debug_page.dart`: Development navigation hub (remove for production)
- `lib/pages/template.dart`: Base template for new page creation
- `lib/pages/user_*.dart`: User-facing authentication and main app pages
- `lib/pages/admin_*.dart`: Administrative interface pages

## Code Style & Patterns

### Widget Organization
```dart
// Always use const constructors where possible
const Text(
  'Welcome to TravelEase',
  style: TextStyle(
    color: Colors.white,
    fontSize: 25,
    fontWeight: FontWeight.bold,
    fontFamily: 'Kumbh Sans',
  ),
)
```

### Button Styling Patterns

#### Primary Action Buttons
```dart
// Standard button container pattern for primary actions
Container(
  height: 65,
  decoration: BoxDecoration(
    color: const Color(0xFF348AA7),
    borderRadius: BorderRadius.circular(50),
  ),
  child: MaterialButton(
    onPressed: () { /* handler */ },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    child: const Text(/* button text */),
  ),
)
```

#### Feature Buttons (List Style)
```dart
// Feature button pattern used in user homepage
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF125E77),
    padding: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF348AA7), width: 2),
    ),
    elevation: 3,
  ),
  child: Row(
    children: [
      // Icon container with background
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF348AA7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF348AA7), size: 28),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: /* title style */),
            Text(description, style: /* description style */),
          ],
        ),
      ),
      const Icon(Icons.arrow_forward_ios, color: Color(0xFF348AA7)),
    ],
  ),
)
```

### Input Field Pattern
- Black border, white background
- Custom height (typically 50px)
- Kumbh Sans font family
- Password fields include visibility toggle
- Validation happens in button press handlers

## Dependencies & Build

### Current Dependencies
- Pure Flutter with material design - minimal external packages
- `flutter_lints` for code quality
- No authentication, networking, or database packages yet

### Development Commands
```bash
# Get dependencies
flutter pub get

# Run on Android (primary target)
flutter run

# Build for Android
flutter build apk
```

### Platform Focus
- **Primary**: Android development and testing
- **Secondary**: iOS project structure exists but not actively developed
- **Not implemented**: Web, desktop platforms

## TODO Integration Points
- Authentication backend integration needed in login pages
- Document upload and AI verification system (referenced in UI but not implemented)
- Profile management system
- Travel requirements database
- Real-time document verification API

## Important Notes
- Remove `debug_page.dart` and debug button before production
- All "About Us", "Mission & Vision" links are placeholder implementations
- Form validation is basic - enhance before production
- No data persistence layer implemented yet
- AI feedback system referenced in UI but backend not connected