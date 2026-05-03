# Database Schema & Mobile DTO Mapping

This document defines the database schema and how it translates to the Flutter mobile application's Dart models (Entities/DTOs).

## 1. users
This table holds both Patient (Hasta) and Caregiver (Takipçi) accounts.

| DB Column | DB Type | Flutter Dart Type | Notes / Nullability |
| :--- | :--- | :--- | :--- |
| `id` | uuid (PK) | `String` | Non-null |
| `email` | varchar | `String` | Non-null |
| `password_hash` | varchar | **DO NOT INCLUDE** | Never sent to the client app. |
| `role` | varchar | `String` (or Enum) | Non-null ('patient', 'caregiver', 'admin') |
| `full_name` | varchar | `String` | Non-null |
| `phone` | varchar | `String?` | Nullable |
| `avatar_url` | text | `String?` | Nullable |
| `fcm_token` | text | `String?` | Nullable (Usually sent to backend, occasionally read) |
| `is_active` | boolean | `bool` | Non-null, default true |
| `created_at` | timestamp | `DateTime` | Non-null |

## 2. patient_follower
Maps the many-to-many relationship between patients and caregivers.
Columns: `id`, `caregiver_id`, `patient_id`, `relationship`, `is_primary`, `created_at`.

## 3. safe_zones (Geofencing)
Columns: `id`, `patient_id`, `name`, `center_lat`, `center_lng`, `radius_meters`, `is_active`, `created_at`.

## 4. location_logs
Columns: `id`, `patient_id`, `latitude`, `longitude`, `accuracy_meters`, `recorded_at`, `is_outside_zone`, `alert_sent`, `is_anomaly`, `anomaly_score`.

## 5. medications
Columns: `id`, `patient_id`, `created_by`, `name`, `dosage`, `instructions`, `schedule_time`, `days_of_week`, `start_date`, `end_date`, `is_active`, `created_at`.

## 6. medication_logs
Columns: `id`, `medication_id`, `patient_id`, `status`, `scheduled_at`, `taken_at`, `note`.

## 7. memory_content
Columns: `id`, `patient_id`, `uploaded_by`, `content_type`, `title`, `description`, `file_url`, `person_name`, `relationship`, `is_active`, `created_at`.