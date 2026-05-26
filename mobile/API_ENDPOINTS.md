# AlzheimerApp - API & Integration Guide for AI Agents

## ⚠️ GLOBAL RULES FOR AGENTS
1. **Authentication:** ALL endpoints (except `/api/Auth/register` and `/api/Auth/login`) require a JWT Token. You MUST attach it via `Authorization: Bearer <token>` in the Dio Interceptor.
2. **Date Format:** All `DateTime` objects must be serialized to/from UTC ISO 8601 format.
3. **Error Handling:** Backend returns standard RFC 7807 `ProblemDetails` on errors (400, 401, 403, 404). Data sources must parse this and throw custom exceptions (e.g., `ServerException(message: problem.detail)`).
4. **Roles:** `0 = Patient`, `1 = Follower`, `2 = Admin`. 

---

## 1. Authentication (`/api/Auth`)

### Register
* **POST** `/api/Auth/register`
* **Description:** Registers a new user.
* **Request Body:** `email`, `password`, `fullName`, `phone` (optional), `role` (0, 1, or 2).
* **Response (200):** User details.

### Login
* **POST** `/api/Auth/login`
* **Description:** Authenticates user and retrieves JWT.
* **Request Body:** `email`, `password`.
* **Response (200):** JWT Token and User Info. Store token securely.

---

## 2. Follower & Care Team Management (`/api/Follower`)

### Generate Invite
* **POST** `/api/Follower/invite/generate`
* **Description:** Generates a 6-character code and Deep Link (`alzheimerapp://invite?code=...`).
* **Request Body:** `patientId` (UUID), `isPrimaryInvite` (bool - true for Master Admin).
* **Response (200):** `inviteCode`, `deepLinkUrl`, `expiresAt`.

### Accept Invite
* **POST** `/api/Follower/invite/accept`
* **Description:** Consumes invite code. User ID is auto-extracted from JWT.
* **Request Body:** `inviteCode`, `relationship` (e.g., "Son", "Nurse").
* **Response (200):** Linked Follower details.

### Check Admin Status
* **GET** `/api/Follower/patient/{patientId}/has-admin`
* **Description:** Checks if patient has a Primary Admin. Used for UX routing on app startup.
* **Response (200):** `boolean`.

### Transfer Admin
* **PUT** `/api/Follower/patient/{patientId}/transfer-admin/{newAdminId}`
* **Description:** Transfers master rights to another care team member.
* **Response (204):** No Content.

### 🌟 God Endpoint: Dashboard
* **GET** `/api/Follower/patient/{patientId}/dashboard`
* **Description:** Aggregated data for Caregiver Home Screen. Prevents multiple HTTP calls.
* **Response (200):** Contains `patientId`, `lastLatitude`, `lastLongitude`, `isCurrentlyOutside`, `unreadAlertCount`, `medsTakenToday`, `totalMedsToday`, and arrays for latest alerts/meds.

---

## 3. Location & WebSockets (`/api/Location`)

### Log Location & Broadcast
* **POST** `/api/Location/log`
* **Description:** Saves GPS and instantly fires SignalR WebSocket event. 
* **Request Body:** `patientId`, `latitude`, `longitude`, `accuracyMeters`.
* **Response (200):** Saved log.
* **[AGENT INSTRUCTION - SIGNALR]:** * Hub URL: `/hubs/location`
    * Group: Join `PatientTracker_{patientId}` on connect.
    * Listen to: `ReceiveLocationUpdate` to trigger map UI redraw.

---

## 4. Medication Master Schedule (`/api/Medicine`)
*Follower/Admin ONLY.*

* **GET** `/api/Medicine/patient/{patientId}`: Retrieves active schedules.
* **POST** `/api/Medicine`: Create schedule. Payload requires `DaysOfWeek` (e.g., "1,3,5" for Mon,Wed,Fri) and `ScheduleTime` (HH:MM:SS).
* **PUT** `/api/Medicine/{id}`: Update or Soft Delete (`isActive: false`).
* **DELETE** `/api/Medicine/{id}`: Hard delete.

---

## 5. Daily Medicine Logs (`/api/MedicineLogs`)
*Tracks actual daily intake.*

### Get Daily Logs
* **GET** `/api/MedicineLogs/patient/{patientId}/date/{date}`
* **Description:** Retrieves logs for a specific day. Format `{date}` as `YYYY-MM-DD`. Backend auto-generates `Pending` logs if they don't exist.
* **Response (200):** Array of logs containing `status` (0=Pending, 1=Taken, 2=Missed).

### Update Log Status
* **PUT** `/api/MedicineLogs/{id}/status`
* **Description:** Called when Patient taps "I took my pill".
* **Request Body:** `status` (int), `note` (string, optional).
* **Response (204):** No Content.

---

## 6. Memory Content (`/api/MemoryContent`)

* **GET** `/api/MemoryContent/patient/{patientId}`: Retrieves patient memories.
* **POST** `/api/MemoryContent`: Creates a memory.
    * **[AGENT INSTRUCTION - FILE UPLOAD]:** Do NOT send raw bytes to this API. Upload file to Firebase Storage first, then send the Firebase Download URL in the `fileUrl` property.
    * **Types:** `contentType` (0=Photo, 1=Voice, 2=IdentityCard).
* **PUT** `/api/MemoryContent/{id}`: Update metadata or hide (`isActive: false`).
* **DELETE** `/api/MemoryContent/{id}`: Hard delete.

---

## 7. Safe Zones / Geofencing (`/api/SafeZone`)
*Follower/Admin ONLY.*

* **POST** `/api/SafeZone`: Creates zone. Requires `centerLat`, `centerLng`, and `radiusMeters`.
* **PUT** `/api/SafeZone/{id}`: Updates zone (or `isActive: false` to disable temporarily).
* **DELETE** `/api/SafeZone/{id}`: Hard delete.

---

## 8. Alerts & Notifications (`/api/Alerts` & `/api/Users`)

### Get Alerts
* **GET** `/api/Alerts/patient/{patientId}`
* **Response (200):** History of alerts. Check `isRead` for UI highlighting.

### Mark Alert Read
* **PUT** `/api/Alerts/{id}/read`
* **Description:** Clears the unread badge in UI.
* **Response (204):** No Content.

### Update FCM Token
* **PUT** `/api/Users/fcm-token`
* **Description:** Registers device for Firebase Push Notifications. Call this immediately after login and on app startup. UserId is inferred from JWT.
* **Request Body:** `fcmToken`.
* **Response (204):** No Content.