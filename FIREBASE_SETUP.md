# Firebase Setup for User Profile

## Firestore Database Structure

The user profile page uses Cloud Firestore to store and retrieve user information. Here's the structure:

### Collection: `users`
Document ID: User's Firebase Auth UID

#### Fields:

```javascript
{
  // Personal Information
  "fullName": string,              // User's full name
  "email": string,                 // User's email address (from Auth)
  "phoneNumber": string,           // Phone number with country code
  "address": string,               // Full address
  
  // Travel Documents
  "passportNumber": string,        // Passport number
  "passportExpiration": string,    // Passport expiration date (MM/DD/YYYY)
  "visaNumber": string,            // Visa type or number
  "insuranceProvider": string,     // Travel insurance provider name
  
  // Additional Information
  "emergencyContact": string,      // Emergency contact information
  "preferredAirport": string,      // Preferred departure airport
  "preferredLanguages": string,    // Comma-separated list of languages
  
  // Security & Preferences
  "twoFactorEnabled": boolean,     // Two-factor authentication status
  "dataProcessingConsent": boolean,// User consent for data processing
  "profileImageUrl": string,       // URL to profile picture (nullable)
  
  // Metadata
  "createdAt": timestamp,          // Document creation timestamp
  "updatedAt": timestamp           // Last update timestamp
}
```

## Setup Instructions

### 1. Enable Cloud Firestore

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **TravelEase**
3. Navigate to **Firestore Database** in the left sidebar
4. Click **Create database**
5. Start in **test mode** for development (change to production rules later)
6. Choose a location close to your users (e.g., `asia-southeast1` for Philippines)

### 2. Security Rules (Development)

For development, use these rules (in Firestore Rules tab):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Security Rules (Production - More Secure)

For production, use stricter rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can read their own document
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Users can create their own document on signup
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Users can update their own document, but not change email
      allow update: if request.auth != null 
                    && request.auth.uid == userId
                    && request.resource.data.email == resource.data.email;
      
      // Only users can delete their own account
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## How It Works

### On Page Load:
1. The app checks if a user is logged in via Firebase Auth
2. It fetches the user's profile from Firestore using their UID
3. If no profile exists, it creates a new document with default values
4. Profile data is loaded into the text controllers for display/editing

### On Save:
1. User clicks "Save Information" button
2. App validates that user is still logged in
3. All form data is sent to Firestore via `update()` method
4. `updatedAt` timestamp is automatically set
5. Success/error message is shown to user

### On Delete Account:
1. User confirms account deletion in a dialog
2. User's Firestore document is deleted
3. User's Firebase Auth account is deleted
4. User is redirected to splash screen

## Testing

### Create Test Data:

1. Run the app and sign up a new user
2. The profile will be automatically created in Firestore
3. Navigate to My Profile and fill in the information
4. Click "Save Information"
5. Check Firebase Console → Firestore Database to see the data

### Manual Test in Firebase Console:

You can manually create test documents:

1. Go to Firestore Database
2. Create collection: `users`
3. Add document with ID = a test user's Auth UID
4. Add fields as shown in the structure above
5. Run the app and log in with that user

## Important Notes

- **Email is read-only**: Email comes from Firebase Auth and should not be changed in Firestore
- **Profile images**: Image URLs are stored, but upload functionality needs to be implemented with Firebase Storage
- **Data validation**: Add validation rules in both client (Flutter) and server (Firestore Rules)
- **Privacy**: Ensure compliance with data protection laws (GDPR, PDPA, etc.)
- **Backup**: Enable automatic backups in Firebase Console for production

## Next Steps

- [ ] Implement profile image upload with Firebase Storage
- [ ] Add form validation before saving
- [ ] Implement password change with Firebase Auth
- [ ] Add real-time listeners for profile updates
- [ ] Create indexes for efficient queries (if needed)
- [ ] Implement data export for user privacy compliance
