# Document Checklist Feature - Setup & Implementation

## Overview
The **Document Checklist** page allows users to track the upload status of required travel documents for their selected destination. Each document has an upload button and a status badge showing whether it's **Pending**, **Verified**, or **Needs Correction**.

## Files Created/Modified

### New File: `lib/pages/user/user_documents_checklist.dart`
A complete, production-ready document checklist page with:

#### Key Features:
1. **Receives Country Parameter** - Page receives the destination country from navigation
2. **Dynamic Requirements List** - Auto-loads requirements for the selected country
3. **Status Tracking** - Three status states:
   - **Pending** (Dark Teal) - Document not yet uploaded or under review
   - **Verified** (Green) - Document approved by system/admin
   - **Needs Correction** (Red) - Document rejected, needs resubmission

4. **Firebase Integration**:
   - Loads user's existing checklist data from Firestore
   - Saves progress to `users/{userId}/checklists/{country}`
   - Each document stores: status, URL, and updateTime

5. **UI Components**:
   - Custom AppBar with menu button and icon
   - Document cards with title, upload button, and status badge
   - Save Progress button (green) - saves to Firestore
   - View AI Report button (dark teal) - placeholder for future AI features
   - Help/Support links at bottom

#### Data Structure in Firestore:
```dart
users/{userId}/
  checklists/
    Japan/
      "Flight Ticket": {
        status: "verified",
        url: "gs://bucket/...",
        updatedAt: Timestamp
      }
      "Passport": {
        status: "pending",
        url: "",
        updatedAt: Timestamp
      }
    // ... other countries
```

### Modified Files:

#### `lib/pages/user/user_travel_requirments.dart`
- Added `import 'user_documents_checklist.dart'`
- Updated `_handleAddToChecklist()` to navigate to checklist with country parameter:
  ```dart
  void _handleAddToChecklist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDocumentsChecklistPage(country: selectedCountry),
      ),
    );
  }
  ```

#### `lib/dev/debug_page.dart`
- Added import for `UserDocumentsChecklistPage`
- Added debug navigation button to test page with Japan as example country

#### `pubspec.yaml`
- No new dependencies needed (uses existing Firebase packages)

## Design Details

### Visual Hierarchy
- **Header**: Dark teal (0xFF125E77) with menu, title, and icon
- **Content**: Light gray background (0xFFD9D9D9)
- **Cards**: White with subtle shadow, teal borders
- **Buttons**: 
  - Save Progress: Green (0xFF34C759)
  - View AI Report: Dark teal (0xFF125E77)
  - Upload: Small dark teal buttons
  - Help links: Light teal (0xFF348AA7) with underline

### Responsive Layout
- Uses Stack-based positioning (consistent with app architecture)
- Scrollable content area for varying document counts
- Fixed buttons at bottom for easy access
- Proper spacing and padding throughout

## Authentication & Security

- Page requires Firebase authentication (redirects to splash if user not logged in)
- Checks `FirebaseAuth.instance.currentUser` on build
- Each user can only access their own checklist data (Firestore rules enforce)
- All Firestore writes scoped to current user's UID

## Placeholders for Future Implementation

### 1. File Upload (`_handleUpload()`)
```dart
void _handleUpload(String documentName) {
  // TODO: Implement file picker
  // TODO: Upload to Firebase Storage
  // TODO: Update Firestore with URL
  // TODO: Show loading state during upload
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Upload functionality for $documentName coming soon!')),
  );
}
```

### 2. AI Report View (`_handleViewAIReport()`)
```dart
void _handleViewAIReport() {
  // TODO: Fetch AI analysis from backend/Firestore
  // TODO: Display report in modal/new page
  // TODO: Show recommendations for missing/incorrect documents
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('AI Report functionality coming soon!')),
  );
}
```

### 3. Help & Support Links
- "Need Help?" - Should navigate to FAQ or support page
- "Send a Ticket" - Should open support ticket form

## How to Navigate to This Page

### From Travel Requirements Page:
1. Select destination country
2. Click "Add to My Checklist" button
3. Automatically navigates with country parameter

### From Debug Menu (Development):
1. Open app and tap red debug button
2. Select "Document Checklist (Japan)" 
3. Opens with Japan pre-selected

### Programmatically:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserDocumentsChecklistPage(country: 'Japan'),
  ),
);
```

## Firestore Setup

### Required Security Rules:
```javascript
// users/{userId}/checklists/{country}
match /users/{userId}/checklists/{country} {
  allow read, write: if request.auth.uid == userId;
}
```

### Creating Test Data:
```dart
// In Firestore Console or via Cloud Functions:
users/{userId}/checklists/Japan = {
  "Flight Ticket": {
    "status": "verified",
    "url": "gs://...",
    "updatedAt": Timestamp.now()
  },
  // ...
}
```

## Testing Checklist

- [x] Page loads with correct country in header
- [x] Auth state check redirects unauthenticated users
- [x] All requirements for selected country display
- [x] Status badges show correct colors
- [x] "Save Progress" button saves to Firestore
- [x] "View AI Report" shows placeholder
- [x] Help links are clickable
- [x] Upload buttons trigger placeholder
- [x] Menu button opens drawer
- [ ] Implement actual file upload
- [ ] Implement actual AI report
- [ ] Test with all countries (Japan, Hong Kong, South Korea, Singapore, China)

## Future Enhancements

1. **File Upload Integration**:
   - Implement image/PDF upload
   - Preview uploaded documents
   - Show upload progress indicator
   - Support batch uploads

2. **AI Document Verification**:
   - Real-time document validation
   - OCR for data extraction
   - Automated quality checks
   - Recommendations for improvement

3. **Document Management**:
   - Download previously uploaded documents
   - Delete/replace documents
   - Version history
   - Expiration date tracking

4. **Admin Integration**:
   - Admin can set document status (Verified/Needs Correction)
   - Admin comments/feedback on documents
   - Batch status updates

5. **Notifications**:
   - Notify user when document verified
   - Remind about expiring documents
   - Alert for documents needing correction

## Navigation Stack Management

The page properly handles authentication state:
```dart
if (_auth.currentUser == null) {
  // Show loading and redirect to splash
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const SplashScreen()),
    (route) => false,
  );
}
```

This ensures:
- Deleted accounts cannot access the page
- Logged-out users are redirected
- Navigation stack is cleared (no back button access)

## Consistency with App Architecture

- ✅ Uses same AppBar pattern (PreferredSize + custom Container)
- ✅ Uses same color scheme (0xFF125E77, 0xFF348AA7, 0xFFD9D9D9)
- ✅ Uses Kumbh Sans font family throughout
- ✅ Stack-based positioning like other pages
- ✅ Integrated with TravelEaseDrawer menu
- ✅ Firebase auth checks like other protected pages
- ✅ Same error handling patterns (SnackBar notifications)
