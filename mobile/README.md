# Alzheimer Patient Tracking System

A Flutter-based mobile application developed for Alzheimer patients and caregivers.

The system helps caregivers monitor patient safety, medication schedules, and realtime locations while providing memory assistance features for patients.

---

# Features

## Patient Features

- SOS emergency button
- Medication reminders
- Memory assistance cards
- Family photo and voice support
- Simplified accessible interface

## Caregiver Features

- Live patient tracking
- Safe zone management
- Medication management
- Geofence alerts
- Realtime notifications

---

# Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter |
| State Management | flutter_bloc |
| Networking | Dio |
| Dependency Injection | get_it + injectable |
| Routing | go_router |
| Secure Storage | flutter_secure_storage |
| Maps | google_maps_flutter |
| Notifications | Firebase Cloud Messaging |
| Realtime Communication | SignalR |

---

# Architecture

The application follows:

- Clean Architecture
- Feature-based modular structure
- Bloc state management
- Repository pattern

---

# Project Structure

```text
lib/
├── core/
├── features/
└── main.dart
```

Each feature contains:

```text
feature/
├── data/
├── domain/
└── presentation/
```

---

# Main Features

## Auth

- Login
- Session restore
- JWT management

## Medication

- Medication schedules
- Reminder system
- Medication logs

## Memory

- Family cards
- Voice notes
- Images

## Geofence

- Safe zone management
- Distance checks
- Boundary alerts

## Live Tracking

- Realtime patient tracking
- SignalR updates
- Caregiver monitoring

---

# Security

The application uses:

- Secure JWT storage
- HTTPS communication
- Protected routes
- Role-based navigation

---

# Accessibility

The application is designed for elderly Alzheimer patients.

Key principles:

- large buttons
- high contrast
- minimal cognitive load
- simple navigation
- clear emergency actions

---

# Development Rules

Please read:

- ARCHITECTURE.md
- RULES.md
- .aiignore

before contributing to the project.

---