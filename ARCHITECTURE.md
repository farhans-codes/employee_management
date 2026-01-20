# Employee Management System

Clean Architecture এর layer structure অনুযায়ী তৈরি Flutter application।

## 📁 Folder Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core layer (shared resources)
│   ├── constants/
│   │   └── app_colors.dart            # Color constants
│   └── theme/
│       └── app_theme.dart             # App theme configuration
├── presentation/                      # Presentation layer (UI)
│   ├── pages/
│   │   └── home/
│   │       └── home_page.dart         # Home page
│   └── widgets/                       # Reusable widgets
├── domain/                            # Domain layer (business logic)
│   ├── entities/                      # Business entities
│   ├── repositories/                  # Repository interfaces
│   └── usecases/                      # Use cases
└── data/                              # Data layer
    ├── models/                        # Data models
    ├── repositories/                  # Repository implementations
    └── datasources/                   # Data sources (API, local DB)
```

## 🎨 Color Theme

- **Primary Color**: `#0D4F9D` (নীল)
- **Secondary Color**: `#FFFFFF` (সাদা)
- **Text Colors**: Black & White

## 🏗️ Clean Architecture Layers

### 1. **Core Layer**
   - Theme configuration
   - Constants (colors, strings, etc.)
   - Utilities

### 2. **Presentation Layer**
   - UI pages
   - Widgets
   - State management (future)

### 3. **Domain Layer**
   - Business entities
   - Use cases
   - Repository interfaces

### 4. **Data Layer**
   - Models
   - Repository implementations
   - Data sources

## 🚀 Run করার নিয়ম

```bash
flutter run
```
