# Alzheimer Patient Tracking System

# Mobile Application Architecture

## Core Architecture Principles

The Flutter application MUST follow:

- Clean Architecture
- Feature-based folder structure
- Bloc state management
- Repository pattern
- SOLID principles
- Dependency Injection

---

# Layer Structure

presentation
↓
domain
↓
data

---

# Presentation Layer

Contains:

- Pages
- Widgets
- Bloc/Cubit
- UI States
- UI Events
- Navigation

Responsibilities:

- Render UI
- Handle interactions
- Dispatch Bloc events
- React to states

Forbidden:

- Direct API calls
- Business logic
- Database logic
- Token handling

---

# Domain Layer

Contains:

- Entities
- Repository contracts
- UseCases
- Business rules

Responsibilities:

- Application logic
- Validation
- Workflow orchestration

Rules:

- Must remain pure Dart
- Must not depend on Flutter
- Must not depend on Dio
- Must not depend on Firebase

---

# Data Layer

Contains:

- DTOs
- Models
- Repository implementations
- Remote data sources
- Local data sources
- API services

Responsibilities:

- HTTP communication
- Serialization
- Secure storage access
- Error mapping
- SignalR communication

---

# Feature-Based Folder Structure

```text
lib/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── services/
│   ├── router/
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── di/
│
├── features/
│   ├── auth/
│   ├── patient/
│   ├── caregiver/
│   ├── medication/
│   ├── memory/
│   ├── geofence/
│   ├── notifications/
│   ├── location_tracking/
│   └── settings/
│
└── main.dart
```

---

# State Management

Mandatory:

- flutter_bloc
- Equatable

Architecture:

- One Bloc per major responsibility
- UI reacts only to states
- Business logic belongs inside UseCases or Bloc

---

# Dependency Injection

Mandatory:

- get_it
- injectable

All dependencies MUST be registered:

- Repositories
- UseCases
- Data sources
- Services
- Dio clients
- Blocs

---

# Network Layer

Mandatory:

- Dio

Responsibilities:

- JWT injection
- Error mapping
- Logging
- Refresh token workflow
- Retry handling

Forbidden:

- Using http package
- Direct networking inside widgets

---

# Routing

Mandatory:

- go_router

Route categories:

Public:
- Splash
- Login
- Register

Protected:
- Patient Dashboard
- Caregiver Dashboard
- Medication
- Memory
- Tracking
- Settings

---

# Secure Storage

Mandatory:

- flutter_secure_storage

Allowed:

- access token
- refresh token
- session metadata
- user role

Forbidden:

- passwords
- raw medical files

---

# Realtime Communication

Technology:

- SignalR

Used for:

- live tracking
- geofence alerts
- SOS events
- realtime updates

---

# Accessibility Requirements

The application targets elderly Alzheimer patients.

Mandatory:

- large touch targets
- high contrast
- readable typography
- simple navigation
- minimal cognitive load

Forbidden:

- complex navigation
- tiny buttons
- overloaded screens
- hidden interactions

---

# Security Rules

Mandatory:

- HTTPS only
- Secure token storage
- Validate all backend responses
- Handle expired sessions safely
- Avoid logging sensitive information

Forbidden:

- Hardcoded secrets
- Plain text tokens
- Exposed Firebase keys

---