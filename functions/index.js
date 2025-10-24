/**
 * TravelEase AI Document Verification Cloud Function
 * Analyzes uploaded travel documents using OpenAI GPT-4 Vision
 */

const {onObjectFinalized} = require("firebase-functions/v2/storage");
const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// Set global options
setGlobalOptions({
  timeoutSeconds: 300,
  memory: "1GiB",
});

// Define OpenAI API key as a secret
const openaiApiKey = defineSecret("OPENAI_API_KEY");

// Trigger when a file is uploaded to Firebase Storage (default bucket)
exports.analyzeDocument = onObjectFinalized(
    {
      secrets: [openaiApiKey], // Grant access to the secret
    },
    async (event) => {
      const OPENAI_API_KEY = openaiApiKey.value();

      if (!OPENAI_API_KEY) {
        console.error("❌ OPENAI_API_KEY not configured!");
        return null;
      }
      const object = event.data;
      const filePath = object.name;

      // Only process files in user_documents folder
      if (!filePath || !filePath.startsWith("user_documents/")) {
        console.log("Skipping non-document file:", filePath);
        return null;
      }

      // Parse path: user_documents/{userId}/{country}/{docType}/{fileName}
      const pathParts = filePath.split("/");
      if (pathParts.length < 5) {
        console.log("Invalid path structure:", filePath);
        return null;
      }

      const [, userId, country, docType] = pathParts;

      // Construct public download URL (no signed URL needed)
      const encodedPath = encodeURIComponent(filePath);
      const url = `https://firebasestorage.googleapis.com/v0/b/${object.bucket}/o/${encodedPath}?alt=media`;

      console.log(`🔍 Analyzing ${docType} for user ${userId} (${country})`);

      try {
        // Update status to 'verifying'
        const userDocRef = admin.firestore().collection("users").doc(userId);

        await userDocRef.update({
          [`checklists.${country}.${docType}.status`]: "verifying",
          [`checklists.${country}.${docType}.url`]: url,
          [`checklists.${country}.${docType}.updatedAt`]: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Call OpenAI to analyze the document
        const analysisResult = await analyzeWithOpenAI(url, docType, OPENAI_API_KEY);

        // Update Firestore with results
        await userDocRef.update({
          [`checklists.${country}.${docType}.extractedData`]: analysisResult.extractedData,
          [`checklists.${country}.${docType}.aiFeedback`]: analysisResult.feedback,
          [`checklists.${country}.${docType}.status`]: analysisResult.isValid ? "verified" : "needs_correction",
          [`checklists.${country}.${docType}.url`]: url,
          [`checklists.${country}.${docType}.analyzedAt`]: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`✅ Analysis complete: ${analysisResult.isValid ? "VALID" : "INVALID"}`);
      } catch (error) {
        console.error("❌ Error analyzing document:", error);

        // Mark as needs correction on error
        const errorData = error.message || "Unknown error";
        await admin.firestore().collection("users").doc(userId).update({
          [`checklists.${country}.${docType}.status`]: "needs_correction",
          [`checklists.${country}.${docType}.aiFeedback`]: `Error: ${errorData}. Please try again.`,
        });
      }

      return null;
    }, // Close the async event handler
); // Close onObjectFinalized

/**
 * Helper function to call OpenAI API for document analysis
 */
async function analyzeWithOpenAI(imageUrl, docType, apiKey) {
  const prompt = getPromptForDocType(docType);

  try {
    const response = await axios.post(
        "https://api.openai.com/v1/chat/completions",
        {
          model: "gpt-4o", // Latest model with vision capabilities
          messages: [
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: prompt,
                },
                {
                  type: "image_url",
                  image_url: {
                    url: imageUrl,
                    detail: "high", // High detail for better OCR
                  },
                },
              ],
            },
          ],
          max_tokens: 1500,
          temperature: 0.2, // Lower temperature for consistent results
        },
        {
          headers: {
            "Authorization": `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
        },
    );

    const aiResponse = response.data.choices[0].message.content;
    console.log("OpenAI response:", aiResponse);

    return parseAIResponse(aiResponse, docType);
  } catch (error) {
    const errorData = error.response && error.response.data ? error.response.data : error.message;
    console.error("OpenAI API error:", errorData);
    throw new Error("Failed to analyze document with AI");
  }
}

/**
 * Cloud Function: Create User or Admin Account
 * Creates both Firebase Auth account and Firestore document
 * Can only be called by authenticated Master users
 */
exports.createAccount = onCall(async (request) => {
  const {auth, data} = request;

  // Check if caller is authenticated
  if (!auth) {
    throw new Error("Authentication required");
  }

  // Get caller's role from Firestore
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerData = callerDoc.data();

  if (!callerData) {
    throw new Error("User profile not found");
  }

  const callerRole = callerData.role;

  // Verify caller has permission (master or admin)
  if (callerRole !== "master" && callerRole !== "admin") {
    throw new Error("Permission denied: Admin or Master role required");
  }

  // Validate input data
  const {email, password, fullName, phoneNumber, address, role} = data;

  if (!email || !password || !fullName || !role) {
    throw new Error("Missing required fields: email, password, fullName, role");
  }

  if (role !== "user" && role !== "admin") {
    throw new Error("Invalid role: must be 'user' or 'admin'");
  }

  // Admins can only create users, not other admins
  if (callerRole === "admin" && role === "admin") {
    throw new Error("Permission denied: Only Masters can create Admin accounts");
  }

  if (password.length < 6) {
    throw new Error("Password must be at least 6 characters");
  }

  try {
    console.log(`Creating ${role} account for ${email}`);

    // Step 1: Create Firebase Auth account
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: fullName,
      emailVerified: false,
    });

    console.log(`✅ Firebase Auth account created: ${userRecord.uid}`);

    // Step 2: Create Firestore document
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber || null,
      address: address || null,
      role: role,
      profileImageUrl: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      checklists: {},
    });

    console.log(`✅ Firestore document created for ${role}: ${fullName}`);

    return {
      success: true,
      userId: userRecord.uid,
      message: `${role.charAt(0).toUpperCase() + role.slice(1)} account created successfully`,
    };
  } catch (error) {
    console.error(`❌ Error creating ${role} account:`, error);

    // Return user-friendly error messages
    if (error.code === "auth/email-already-exists") {
      throw new Error("Email already registered");
    } else if (error.code === "auth/invalid-email") {
      throw new Error("Invalid email format");
    } else if (error.code === "auth/invalid-password") {
      throw new Error("Password must be at least 6 characters");
    } else {
      throw new Error(`Failed to create account: ${error.message}`);
    }
  }
});

/**
 * Get document-specific prompts for OpenAI
 */
function getPromptForDocType(docType) {
  const prompts = {
    "flight_ticket": `You are a document verification AI. Analyze this flight ticket image carefully.

Extract the following information:
- passenger: Full name of the passenger
- airline: Airline name
- flightNumber: Flight number
- departure: Departure city/airport
- departureDate: Departure date
- arrival: Arrival city/airport
- arrivalDate: Arrival date
- bookingCode: Booking/confirmation code

Validation checks:
1. Is this a legitimate flight ticket?
2. Is the image clear and readable?
3. Are all required fields present?

Respond ONLY with valid JSON:
{
  "isValid": true or false,
  "extractedData": {
    "passenger": "...",
    "airline": "...",
    "flightNumber": "...",
    "departure": "...",
    "departureDate": "...",
    "arrival": "...",
    "arrivalDate": "...",
    "bookingCode": "..."
  },
  "feedback": "Detailed explanation or 'No issues detected'"
}`,

    "valid_passport": `You are a travel document verification assistant. Analyze this identification document image.

This is for a travel booking system to verify document validity. Extract the following visible information:
- fullName: Full name shown
- passportNumber: Document number
- nationality: Country of issue
- dateOfBirth: Date of birth
- expiryDate: Expiration date

Check if:
1. The document appears authentic and unaltered
2. It's valid for at least 6 months from today
3. The image quality is sufficient for verification

Respond ONLY with this JSON format:
{
  "isValid": true or false,
  "extractedData": {
    "fullName": "...",
    "passportNumber": "...",
    "nationality": "...",
    "dateOfBirth": "...",
    "expiryDate": "..."
  },
  "feedback": "Brief explanation"
}`,

    "visa": `You are a document verification AI. Analyze this visa document carefully.

Extract the following information:
- visaType: Type of visa
- visaNumber: Visa number
- fullName: Name of visa holder
- validFrom: Start date
- validUntil: End date

Validation checks:
1. Is this a legitimate visa?
2. Is it currently valid?
3. Is the image clear?

Respond ONLY with valid JSON:
{
  "isValid": true or false,
  "extractedData": {
    "visaType": "...",
    "visaNumber": "...",
    "fullName": "...",
    "validFrom": "...",
    "validUntil": "..."
  },
  "feedback": "Detailed explanation or 'No issues detected'"
}`,

    "proof_of_accommodation": `You are a document verification AI. Analyze this accommodation booking.

Extract the following information:
- hotelName: Name of hotel/property
- bookingRef: Booking reference
- guestName: Guest name
- checkIn: Check-in date
- checkOut: Check-out date

Validation checks:
1. Is this a legitimate booking confirmation?
2. Is it confirmed (not pending)?
3. Is the image clear?

Respond ONLY with valid JSON:
{
  "isValid": true or false,
  "extractedData": {
    "hotelName": "...",
    "bookingRef": "...",
    "guestName": "...",
    "checkIn": "...",
    "checkOut": "..."
  },
  "feedback": "Detailed explanation or 'No issues detected'"
}`,
  };

  return prompts[docType] || prompts["flight_ticket"];
}

/**
 * Parse AI response into structured format
 */
function parseAIResponse(aiResponse, docType) {
  try {
    // Extract JSON from response
    const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
    const jsonString = jsonMatch ? jsonMatch[0] : aiResponse;

    const parsed = JSON.parse(jsonString);

    return {
      isValid: parsed.isValid === true,
      extractedData: parsed.extractedData || {},
      feedback: parsed.feedback || "Analysis completed",
    };
  } catch (error) {
    console.error("Failed to parse AI response:", error);
    console.log("Raw response:", aiResponse);

    return {
      isValid: false,
      extractedData: {},
      feedback: "Failed to analyze document. Please ensure the image is clear.",
    };
  }
}

/**
 * Cloud Function: Delete Account
 * Deletes both Firebase Auth account and Firestore document
 * Callable by Master (can delete anyone) or Admin (can delete users only)
 */
exports.deleteAccount = onCall(async (request) => {
  const {auth, data} = request;

  // Check if caller is authenticated
  if (!auth) {
    throw new Error("Authentication required");
  }

  // Get caller's role from Firestore
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerData = callerDoc.data();

  if (!callerData) {
    throw new Error("User profile not found");
  }

  const callerRole = callerData.role;

  // Verify caller has permission (master or admin)
  if (callerRole !== "master" && callerRole !== "admin") {
    throw new Error("Permission denied: Admin or Master role required");
  }

  // Validate input data
  const {userId} = data;

  if (!userId) {
    throw new Error("Missing required field: userId");
  }

  // Get target user's role to check permissions
  const targetDoc = await admin.firestore().collection("users").doc(userId).get();
  if (!targetDoc.exists) {
    throw new Error("User not found");
  }

  const targetRole = targetDoc.data().role;

  // Admins can only delete users, not other admins or masters
  if (callerRole === "admin" && (targetRole === "admin" || targetRole === "master")) {
    throw new Error("Permission denied: Only Masters can delete Admin or Master accounts");
  }

  // Masters cannot delete themselves
  if (userId === auth.uid) {
    throw new Error("Cannot delete your own account");
  }

  try {
    console.log(`Deleting account: ${userId} (role: ${targetRole})`);

    // Step 1: Delete Firebase Auth account
    await admin.auth().deleteUser(userId);
    console.log(`✅ Firebase Auth account deleted: ${userId}`);

    // Step 2: Delete Firestore document
    await admin.firestore().collection("users").doc(userId).delete();
    console.log(`✅ Firestore document deleted: ${userId}`);

    return {
      success: true,
      message: "Account deleted successfully",
    };
  } catch (error) {
    console.error(`❌ Error deleting account ${userId}:`, error);

    // Return user-friendly error messages
    if (error.code === "auth/user-not-found") {
      // Auth account doesn't exist, but Firestore doc might - delete it anyway
      try {
        await admin.firestore().collection("users").doc(userId).delete();
        return {
          success: true,
          message: "Account deleted successfully (Auth account was already deleted)",
        };
      } catch (firestoreError) {
        throw new Error("Failed to delete user data");
      }
    } else {
      throw new Error(error.message || "Failed to delete account");
    }
  }
});

