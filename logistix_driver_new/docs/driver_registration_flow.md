# Driver Registration & Verification Flow

## Overview
This document outlines the complete flow for driver registration, verification, and onboarding based on the API schema.

---

## Flow 1: Already Registered & Verified Driver

### Steps:
1. **User Login**
   - User enters phone number → `POST /api/users/login/`
   - User enters OTP → `POST /api/users/verify-otp/`
   - Returns: `{ is_new_user: false, tokens: {...}, user: {...} }`

2. **Check Driver Profile**
   - `GET /api/users/driver/profile/`
   - Response: `Driver { id, is_verified: true, ... }`

3. **Check Vehicle Documents**
   - `GET /api/users/driver/documents/?document_type=VEHICLE_RC`
   - At least one document has `is_verified: true`

4. **Navigation**
   - ✅ Navigate to **Main Navigation Screen** (Home Screen)
   - Driver can start accepting trips

### API Sequence:
```
POST /api/users/login/              → OTP sent
POST /api/users/verify-otp/         → Auth tokens received
GET  /api/users/driver/profile/     → Driver profile (is_verified: true)
GET  /api/users/driver/documents/   → Verified vehicle documents
→ Navigate to Home Screen
```

---

## Flow 2: New Driver Registration

### Steps:
1. **User Login/Registration**
   - User enters phone number → `POST /api/users/login/`
   - User enters OTP → `POST /api/users/verify-otp/`
   - Returns: `{ is_new_user: true, tokens: {...}, user: {...} }`

2. **Check Driver Profile**
   - `GET /api/users/driver/profile/`
   - Response: `404 Not Found` or `500 Internal Server Error`

3. **Create Driver Profile**
   - Show **Create Driver Profile Screen**
   - User fills:
     - License Number (required)
     - Vehicle Type (optional)
     - Is Available (default: false)
   - `POST /api/users/driver/`
   - Response: `Driver { id, is_verified: false, ... }`

4. **Check Vehicle Documents**
   - `GET /api/users/driver/documents/?document_type=VEHICLE_RC`
   - Response: Empty array `[]` or no verified documents

5. **Show Vehicle Verification Screen**
   - Navigate to **My Vehicles Screen**
   - User must:
     - Add vehicle details
     - Upload Vehicle RC document
     - Upload Driver License document
     - Wait for admin verification

6. **Navigation**
   - ⏳ Navigate to **My Vehicles Screen** (Vehicle Management)
   - Driver cannot start trips until verified

### API Sequence:
```
POST /api/users/login/              → OTP sent
POST /api/users/verify-otp/        → Auth tokens, is_new_user: true
GET  /api/users/driver/profile/    → 404 Not Found
→ Show Create Driver Profile Screen
POST /api/users/driver/            → Driver profile created (is_verified: false)
GET  /api/users/driver/documents/   → No documents or unverified
→ Navigate to My Vehicles Screen
```

### UI Screens:
1. **Language Selection** → **Login Screen** → **OTP Screen**
2. **Create Driver Profile Screen** (if profile doesn't exist)
3. **My Vehicles Screen** (if no verified vehicles)
4. **Vehicle Number Screen** → **Add Driver Details Screen**

---

## Flow 3: Registered but Not Verified Driver

### Steps:
1. **User Login**
   - User enters phone number → `POST /api/users/login/`
   - User enters OTP → `POST /api/users/verify-otp/`
   - Returns: `{ is_new_user: false, tokens: {...}, user: {...} }`

2. **Check Driver Profile**
   - `GET /api/users/driver/profile/`
   - Response: `Driver { id, is_verified: false, ... }`

3. **Check Vehicle Documents**
   - `GET /api/users/driver/documents/?document_type=VEHICLE_RC`
   - Options:
     - **No documents**: Empty array `[]`
     - **Documents exist but not verified**: Documents with `is_verified: false`
     - **Some documents verified**: At least one with `is_verified: true`

4. **Navigation Logic**

   **Scenario A: No Documents**
   - Navigate to **My Vehicles Screen**
   - Show: "Add your first vehicle to get started"
   - User must add vehicle and upload documents

   **Scenario B: Documents Exist but Not Verified**
   - Navigate to **My Vehicles Screen**
   - Show: "Documents under review" or "Pending verification"
   - Display pending vehicles with status
   - User can add more vehicles or wait for verification

   **Scenario C: Some Documents Verified**
   - Navigate to **Main Navigation Screen** (Home Screen)
   - Verified vehicles can be used for trips
   - Unverified vehicles shown in "My Vehicles" section

5. **Verification Status Check**
   - Driver `is_verified: false` means:
     - Driver profile not fully verified by admin
     - OR documents not verified
   - Check individual document `is_verified` status
   - Driver can still use verified vehicles even if `driver.is_verified = false`

### API Sequence:
```
POST /api/users/login/              → OTP sent
POST /api/users/verify-otp/        → Auth tokens received
GET  /api/users/driver/profile/    → Driver (is_verified: false)
GET  /api/users/driver/documents/  → Documents with is_verified status
→ Navigate based on document verification status
```

### UI Screens:
1. **Language Selection** → **Login Screen** → **OTP Screen**
2. **My Vehicles Screen** (if no verified documents)
3. **Home Screen** (if has verified documents)

---

## Complete Decision Tree

```
┌─────────────────────────────────┐
│      User Login/OTP Verify      │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Check Driver Profile Exists   │
└──────────────┬──────────────────┘
               │
       ┌───────┴───────┐
       │               │
       ▼               ▼
   NOT FOUND       EXISTS
       │               │
       ▼               ▼
┌──────────────┐  ┌──────────────────┐
│ Create       │  │ Check is_verified│
│ Driver       │  └────────┬─────────┘
│ Profile      │           │
└──────┬───────┘           │
       │            ┌───────┴───────┐
       │            │               │
       │            ▼               ▼
       │        VERIFIED      NOT VERIFIED
       │            │               │
       │            │               │
       └────────────┴───────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ Check Vehicle Docs    │
        │ (VEHICLE_RC)          │
        └───────────┬────────────┘
                    │
        ┌───────────┴───────────┐
        │                        │
        ▼                        ▼
    HAS VERIFIED            NO VERIFIED
    DOCUMENTS               DOCUMENTS
        │                        │
        ▼                        ▼
┌───────────────┐        ┌───────────────┐
│ Home Screen   │        │ My Vehicles  │
│ (Start Trips)  │        │ Screen        │
└───────────────┘        └───────────────┘
```

---

## Verification Status Logic

### Driver Verification (`driver.is_verified`)
- **Purpose**: Overall driver account verification status
- **Set by**: Admin after reviewing all documents
- **When `true`**: Driver fully verified, all documents reviewed
- **When `false`**: Driver pending verification or rejected

### Document Verification (`document.is_verified`)
- **Purpose**: Individual document verification status
- **Set by**: Admin after reviewing specific document
- **When `true`**: Document verified, can be used
- **When `false`**: Document pending review or rejected

### Vehicle Verification Logic
- **Vehicle is "verified"** if:
  - Vehicle RC document exists (`document_type: VEHICLE_RC`)
  - Document `is_verified: true`
  - Document `verified_at` is not null

- **Driver can start trips** if:
  - At least one Vehicle RC document is verified
  - OR driver profile is verified (admin approval)

---

## API Endpoints Summary

### Authentication
- `POST /api/users/login/` - Request OTP
- `POST /api/users/verify-otp/` - Verify OTP and login/register

### Driver Profile
- `GET /api/users/driver/profile/` - Get driver profile
- `POST /api/users/driver/` - Create driver profile
- `PUT /api/users/driver/profile/` - Update driver profile
- `PATCH /api/users/driver/profile/` - Partial update

### Documents
- `GET /api/users/driver/documents/` - List all documents
- `GET /api/users/driver/documents/?document_type=VEHICLE_RC` - Filter by type
- `POST /api/users/driver/documents/upload/` - Upload single document
- `POST /api/users/driver/documents/bulk-upload/` - Upload multiple documents
- `GET /api/users/driver/documents/stats/` - Get document statistics
- `PUT /api/users/driver/documents/{id}/` - Update document
- `DELETE /api/users/driver/documents/{id}/` - Delete document

### File Upload
- `POST /api/users/upload/` - Upload file and get URL

---

## Implementation Checklist

### After OTP Verification
- [ ] Check if driver profile exists
- [ ] If not, navigate to Create Driver Profile
- [ ] If exists, check `driver.is_verified`
- [ ] Check vehicle documents verification status

### Vehicle Verification Check
- [ ] Fetch Vehicle RC documents
- [ ] Check if any document has `is_verified: true`
- [ ] Navigate to Home if verified vehicles exist
- [ ] Navigate to My Vehicles if no verified vehicles

### UI States
- [ ] Loading state while checking verification
- [ ] Error handling for API failures
- [ ] Offline fallback to local storage
- [ ] Clear messaging about verification status

---

## Status Messages

### For User Communication

**New Driver:**
- "Complete your driver profile to get started"
- "Add your vehicle to start accepting trips"

**Unverified Driver:**
- "Your documents are under review. This may take up to 4 days."
- "You'll be notified when your verification is complete."

**Verified Driver:**
- "You're all set! Start accepting trips now."
- "X verified vehicles ready for trips"

---

## Notes

1. **Driver Profile vs Document Verification**
   - `driver.is_verified` is a separate flag from document verification
   - A driver can have verified documents but `is_verified: false` if admin hasn't approved the account
   - A driver can have `is_verified: true` but no documents if verification was done differently

2. **Multiple Vehicles**
   - Each vehicle is represented by a VEHICLE_RC document
   - Each document can have independent verification status
   - Driver can use any verified vehicle for trips

3. **Verification Timeline**
   - Document verification typically takes 1-4 days
   - Admin reviews documents and updates `is_verified` status
   - Driver receives notifications when status changes

4. **Error Handling**
   - If API fails, fall back to local storage
   - Show appropriate error messages
   - Allow retry for failed operations

