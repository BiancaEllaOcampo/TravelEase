/**
 * TravelEase AI Document Verification Cloud Function
 * Analyzes uploaded travel documents using OpenAI GPT-4 Vision
 */

const {onObjectFinalized} = require("firebase-functions/v2/storage");
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
    const analysisResult = await analyzeWithOpenAI(url, docType);

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
 * Analyze document using OpenAI GPT-4 Vision
 */
async function analyzeWithOpenAI(imageUrl, docType) {
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
            "Authorization": `Bearer ${OPENAI_API_KEY}`,
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
