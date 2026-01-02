# **TravelEase: Technical Documentation**

**Version 1.0**

**Date: November 8, 2025**

## 1. Introduction

### 1.1. Project Overview
TravelEase is a Flutter-based mobile application designed to streamline the process of travel document verification for Filipino travelers. The application leverages AI-powered analysis to assist in verifying document authenticity and completeness, aiming to reduce manual processing times and improve the travel experience. It features a role-based system with three distinct user tiers: **Users** (travelers), **Admins** (document reviewers), and **Masters** (super administrators with elevated privileges).

### 1.2. Purpose and Scope
The primary purpose of TravelEase is to provide a centralized platform for travelers to manage their required travel documents and for administrative staff to verify them efficiently.

**Scope:**
*   **Platform:** Android-first mobile application, with an existing but untested iOS project structure.
*   **User Roles:**
    *   **User:** Can create an account, upload travel documents for specific countries, track verification status, and view announcements.
    *   **Admin:** Can review user-submitted documents, update their verification status, and manage announcements.
    *   **Master:** Possesses all Admin capabilities plus the ability to manage user roles and perform system-level administrative tasks.
*   **Core Functionality:** AI-assisted document checklists, document upload (images only), status tracking (`pending`, `verifying`, `verified`, `needs_correction`), and role-based access control.
*   **Supported Countries:** Japan, Hong Kong, South Korea, Singapore, China.
*   **Supported Documents:** Flight Ticket, Valid Passport, Visa, Proof of Accommodation.

### 1.3. Target Audience
This document is intended for:
*   **Software Developers:** To understand the codebase, architecture, and development patterns for maintenance and future development.
*   **System Administrators:** To understand the Firebase backend configuration, deployment procedures, and security rules.
*   **Project Managers:** To get a high-level overview of the system's components and technical implementation.

## 2. System Architecture

### 2.1. Technology Stack
*   **Mobile App (Frontend):** Flutter/Dart
*   **Backend-as-a-Service (BaaS):**
    *   **Authentication:** Firebase Authentication
    *   **Database:** Cloud Firestore
    *   **File Storage:** Firebase Storage
    *   **Serverless Functions:** Firebase Cloud Functions for Node.js
*   **AI/Machine Learning:** OpenAI GPT-4o (via API) for document analysis.
*   **Version Control:** Git

### 2.2. High-Level Architecture
TravelEase follows a classic client-server architecture where the Flutter mobile application acts as the client and Firebase services provide the backend infrastructure.

1.  **Client (Flutter App):** Handles all UI, state management (using `StatefulWidget`), and user interaction. It communicates directly with Firebase services for data, authentication, and file storage.
2.  **Firebase (Backend):**
    *   **Firebase Auth** manages user sign-up, login, and session persistence.
    *   **Cloud Firestore** stores all application data, including user profiles, roles, and document checklist metadata.
    *   **Firebase Storage** stores user-uploaded images for profile pictures and travel documents.
    *   **Firebase Cloud Functions** are triggered by events (e.g., a new document upload to Storage) to perform server-side logic, primarily the AI analysis pipeline.
3.  **OpenAI API (External Service):** A Cloud Function calls the OpenAI API, sending it a public URL to a document image stored in Firebase Storage. The API returns structured JSON data with extracted information and feedback, which is then saved back to Firestore.

### 2.3. Frontend Architecture
*   **UI Framework:** Flutter.
*   **State Management:** The project deliberately avoids external state management libraries (like Provider, BLoC, or Riverpod). State is managed locally within `StatefulWidget`s using `setState()` and `TextEditingController`.
*   **Layout:** The majority of pages use a rigid, non-responsive layout built with `Stack` and `Positioned` widgets for pixel-perfect design implementation. This is a critical architectural decision for design consistency.
*   **Navigation:** Navigation is handled via Flutter's built-in `Navigator` API. Centralized helper classes (`UserAppDrawer`, `AdminAppDrawer`, `MasterAppDrawer`, `ChecklistHelper`) are used to avoid code duplication.
*   **Authentication Flow:** The app uses a two-step authentication process on startup:
    1.  `StreamBuilder` listens to `FirebaseAuth.instance.authStateChanges()`.
    2.  If a user is logged in, a `FutureBuilder` fetches the user's document from the `users` collection in Firestore to retrieve their `role`.
    3.  The app then navigates to the appropriate dashboard (`UserHomePage`, `AdminDashboardPage`, or `MasterDashboardPage`) based on the role.

### 2.4. Backend Architecture (Firebase)

#### 2.4.1. Cloud Firestore Data Model
The database uses a main collection `users` and a secondary collection `announcements`.

*   **`users/{userId}`:**
    *   `role`: (String) "user", "admin", or "master". Critical for authorization.
    *   `email`: (String) User's email.
    *   `fullName`: (String) User's full name.
    *   `profileImageUrl`: (String) Download URL for the profile picture in Firebase Storage.
    *   `checklists`: (Map) A nested map object containing document information.
        *   `{country_key}`: (Map) e.g., "japan"
            *   `{doc_type_key}`: (Map) e.g., "flight_ticket"
                *   `status`: (String) "pending", "verifying", "verified", "needs_correction".
                *   `url`: (String) Download URL for the document image.
                *   `updatedAt`: (Timestamp)
                *   `aiFeedback`: (String) Feedback from the AI analysis.
                *   `extractedData`: (Map) Data extracted by the AI.

*   **`announcements/{announcementId}`:**
    *   `title`: (String)
    *   `content`: (String)
    *   `date`: (Timestamp)
    *   `createdBy`: (String) UID of the admin/master who created it.

#### 2.4.2. Firebase Storage Structure
*   **Profile Pictures:** `user_profiles/{userId}/{fileName}`
*   **Travel Documents:** `user_documents/{userId}/{country}/{docType}/{fileName}`
    *   This path structure is critical, as the Cloud Function parses it to get context for the AI analysis.

#### 2.4.3. Firebase Security Rules
Security is enforced via `firestore.rules` and `storage.rules`.
*   **Firestore Rules:**
    *   Users can only read/write their own data (`isOwner(userId)`).
    *   Admins and Masters have read access to all user data.
    *   Only Masters can change a user's `role`.
    *   Announcements can be read by any authenticated user but only created/updated/deleted by Admins or Masters.
*   **Storage Rules:**
    *   Users can only write to their own storage paths.
    *   Profile pictures are readable by any authenticated user.
    *   **Travel documents are publicly readable (`allow read: if true;`)**. This is a mandatory requirement to allow the OpenAI API to access the image URLs for analysis.

#### 2.4.4. Cloud Functions: AI Document Analysis
A single Cloud Function, `analyzeDocument`, is triggered by the `onObjectFinalized` event in Firebase Storage when a new file is uploaded to the `user_documents/` path.
1.  **Trigger:** File upload to Storage.
2.  **Execution:**
    *   The function validates the file path to ensure it's a document.
    *   It updates the document status in Firestore to `verifying`.
    *   It constructs a prompt based on the document type (e.g., "flight_ticket").
    *   It calls the OpenAI GPT-4o API with the prompt and the public URL of the uploaded image.
    *   It parses the JSON response from OpenAI.
3.  **Result:** The function updates the corresponding document entry in Firestore with the `status`, `aiFeedback`, and `extractedData` from the AI's response. If the AI call fails, the status is set to `needs_correction` with an error message.

## 3. Core Features and Implementation

### 3.1. Role-Based Authentication and Routing
As described in the architecture, the `main.dart` file implements a robust two-step auth flow that correctly routes users based on their Firestore role, ensuring admins are not accidentally sent to the user homepage on app resume.

### 3.2. Document Checklist and Upload
*   The `user_documents_checklist.dart` page displays the required documents for a selected country.
*   The image upload pattern is standardized across the app:
    1.  Use `image_picker` to select an image from the camera or gallery.
    2.  Upload the file to the correct path in Firebase Storage.
    3.  On success, get the `downloadUrl`.
    4.  Update the Firestore document using **dot notation** (`checklists.japan.flight_ticket.status`) to trigger the AI analysis Cloud Function and avoid overwriting other data.

### 3.3. Admin/Master Document Verification
*   The `admin_document_verification.dart` and `master_document_verification.dart` pages are functionally identical, differing only in their class names and imported drawer widgets.
*   They fetch a list of all documents that require review.
*   Admins/Masters can view the uploaded document image (`document['url']`), see the AI's feedback, and manually override the document's `status` using a dropdown. The dropdown is populated with the database-format status values (`['pending', 'verifying', 'verified', 'needs_correction']`).

## 4. Development and Deployment

### 4.1. Local Development Setup
1.  Install Flutter SDK and configure an editor.
2.  Create a Firebase project and place the `google-services.json` file in `android/app/`.
3.  Set up the Firebase CLI.
4.  For local AI testing, create a `.env` file in the `functions/` directory with the `OPENAI_API_KEY`.
5.  Run `firebase emulators:start` to launch local emulators for Firestore, Storage, and Functions.
6.  Run the Flutter app, which will automatically connect to the local emulators.

### 4.2. Production Deployment
Deployment is managed via the Firebase CLI.

1.  **Set OpenAI API Key:**
    ```powershell
    firebase functions:secrets:set OPENAI_API_KEY
    ```
2.  **Deploy Security Rules:**
    ```powershell
    firebase deploy --only firestore:rules,storage
    ```
3.  **Deploy Cloud Functions:**
    ```powershell
    firebase deploy --only functions
    ```
4.  **Build the App:**
    ```powershell
    flutter build apk --release
    ```

### 4.3. Critical Dependencies
*   `firebase_core`: For Firebase initialization.
*   `firebase_auth`: For authentication.
*   `cloud_firestore`: For database access.
*   `firebase_storage`: For file storage.
*   `image_picker`: For accessing the device camera and gallery.
*   `axios` (in Cloud Function): For making HTTP requests to the OpenAI API.
