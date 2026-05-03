# AI Agent Development Rules

## General Rules

- Follow Clean Architecture strictly
- Follow feature-based folder structure
- Keep layers isolated
- Never bypass repositories
- Never place business logic inside widgets

---

# Flutter Rules

Mandatory packages:

- flutter_bloc
- dio
- get_it
- injectable
- go_router
- flutter_secure_storage

---

# State Management Rules

- Use Bloc for feature state management
- Keep Bloc responsibilities focused
- Avoid giant Blocs
- Use immutable states
- Use Equatable

Forbidden:

- setState for complex features
- shared mutable global state

---

# Widget Rules

Mandatory:

- Keep widgets small
- Prefer reusable widgets
- Use const constructors
- Separate UI from logic

Forbidden:

- API calls inside widgets
- Long widget files
- Deep nesting

---

# Network Rules

Mandatory:

- Use Dio only
- Use interceptors
- Handle all error states
- Handle timeouts
- Handle token refresh

Forbidden:

- Raw HTTP requests
- Direct API usage from presentation layer

---

# Secure Storage Rules

Mandatory:

- Store tokens using flutter_secure_storage
- Clear session on logout
- Handle expired sessions

Forbidden:

- Store passwords locally
- Store tokens in SharedPreferences

---

# Routing Rules

Mandatory:

- Use go_router
- Use role-based routing
- Protect authenticated routes

Forbidden:

- Manual route stacks everywhere
- Duplicated navigation logic

---

# Folder Structure Rules

Every feature must contain:

- data
- domain
- presentation

Presentation must contain:

- bloc
- pages
- widgets

---

# Accessibility Rules

Mandatory:

- Large buttons
- High contrast
- Readable text
- Clear emergency actions
- Simple UX

Forbidden:

- Tiny tap areas
- Overcomplicated flows
- Excessive animations

---

# Code Quality Rules

Mandatory:

- Single responsibility principle
- Reusable components
- Typed models
- DTO → Entity mapping
- Proper error handling

Forbidden:

- Massive files
- Duplicate code
- Tight coupling

---

# Performance Rules

Mandatory:

- Pagination when needed
- Lazy loading
- Minimize rebuilds
- Cache images efficiently

Forbidden:

- Rebuilding large trees unnecessarily
- Heavy synchronous operations on UI thread

---

# Logging Rules

Allowed:

- Development logging
- Error tracking

Forbidden:

- Logging JWT tokens
- Logging passwords
- Logging sensitive medical data

---

# Git Rules

Branch naming:

- feature/*
- bugfix/*
- refactor/*

Commit format:

- feat:
- fix:
- refactor:
- docs:
- chore:

---

# AI Agent Restrictions

Forbidden:

- Changing architecture without reason
- Creating new patterns inconsistently
- Introducing another state management solution
- Mixing multiple architectures
- Bypassing dependency injection

Mandatory:

- Respect existing architecture
- Reuse existing components
- Search for existing implementations before creating new ones