# Driver Registration & Verification Flows - Simple Summary

## 🎯 Three Main Scenarios

### 1️⃣ Already Registered & Verified Driver ✅

**What happens:**
- Driver logs in with phone + OTP
- App checks: Driver profile exists ✅
- App checks: Driver `is_verified: true` ✅
- App checks: Has verified vehicle documents ✅
- **Result:** Navigate to **Home Screen** → Can start accepting trips

**API Calls:**
```
Login → Verify OTP → Get Driver Profile → Get Documents → Home Screen
```

---

### 2️⃣ New Driver Registration 🆕

**What happens:**
- Driver logs in with phone + OTP (first time)
- App checks: Driver profile doesn't exist ❌
- **Result:** Navigate to **Create Driver Profile Screen**
- Driver fills: License Number, Vehicle Type
- App creates driver profile → `POST /api/users/driver/`
- App checks: No vehicle documents ❌
- **Result:** Navigate to **My Vehicles Screen**
- Driver adds vehicle → Uploads RC document → Uploads License
- **Status:** Documents pending verification (waiting for admin)

**API Calls:**
```
Login → Verify OTP → Create Driver Profile → My Vehicles Screen
```

---

### 3️⃣ Registered but Not Verified Driver ⏳

**What happens:**
- Driver logs in with phone + OTP
- App checks: Driver profile exists ✅
- App checks: Driver `is_verified: false` ❌
- App checks: Vehicle documents status

**Scenario A: No Documents**
- **Result:** Navigate to **My Vehicles Screen**
- Message: "Add your first vehicle to get started"

**Scenario B: Documents Exist but Not Verified**
- **Result:** Navigate to **My Vehicles Screen**
- Message: "Documents under review. This may take up to 4 days."
- Shows pending vehicles with status

**Scenario C: Some Documents Verified**
- **Result:** Navigate to **Home Screen**
- Verified vehicles can be used for trips
- Unverified vehicles shown separately

**API Calls:**
```
Login → Verify OTP → Get Driver Profile → Get Documents → Navigate based on status
```

---

## 📊 Decision Flow

```
                    Login Successful
                           │
                           ▼
                Driver Profile Exists?
                    │              │
                  YES              NO
                    │              │
                    ▼              ▼
        Check is_verified    Create Driver Profile
                    │              │
           ┌────────┴────────┐     │
           │                  │     │
         true              false    │
           │                  │     │
           ▼                  ▼     │
    Check Documents    Check Documents
           │                  │     │
      ┌────┴────┐        ┌────┴────┐
      │         │        │         │
    Has      None      Has      None
  Verified            Pending
      │         │        │         │
      ▼         ▼        ▼         ▼
   Home    Vehicles  Vehicles  Vehicles
```

---

## 🔑 Key Points

1. **Driver Profile** (`driver.is_verified`)
   - Overall driver account verification
   - Set by admin after reviewing all documents
   - Can be `true` or `false`

2. **Vehicle Documents** (`document.is_verified`)
   - Individual document verification
   - Each Vehicle RC document has its own status
   - Driver can have multiple vehicles with different statuses

3. **Navigation Rules**
   - **Home Screen:** Driver has at least one verified vehicle OR driver fully verified
   - **My Vehicles Screen:** No verified vehicles OR documents pending
   - **Create Profile:** Driver profile doesn't exist

4. **Verification Timeline**
   - Documents typically verified in 1-4 days
   - Admin reviews and updates status
   - Driver receives notifications

---

## 📱 User Experience Flow

### New Driver Journey:
1. Language Selection
2. Login Screen
3. OTP Verification
4. **Create Driver Profile** (if first time)
5. **My Vehicles Screen** (add vehicle)
6. **Vehicle Number Screen** (fill details)
7. **Add Driver Details** (upload documents)
8. **Wait for Verification** (1-4 days)
9. **Home Screen** (start accepting trips)

### Returning Driver Journey:
1. Language Selection
2. Login Screen
3. OTP Verification
4. **Check Status**
   - If verified → **Home Screen**
   - If pending → **My Vehicles Screen** (check status)

---

## ✅ Implementation Status

- ✅ Driver verification service created
- ✅ Vehicle verification wrapper updated
- ✅ Document-based API integration
- ✅ Flow documentation created
- ✅ Navigation logic implemented

