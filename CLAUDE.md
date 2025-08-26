# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for Celltrion NPDA (Non-Pharmaceutical Drug Application) system. It's a warehouse management UI for handling inbound, outbound, and 1st floor outbound operations.

## Development Commands

### Core Flutter Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the application in development mode
- `flutter build windows` - Build for Windows platform
- `flutter build android` - Build for Android platform
- `flutter analyze` - Run static analysis (uses flutter_lints package)
- `flutter test` - Run unit tests

### Platform-specific Build Commands
- **Windows**: `flutter build windows --release`
- **Android**: `flutter build apk --release` or `flutter build appbundle --release`

## Architecture Overview

### State Management
- Uses **flutter_riverpod** for state management
- ViewModels follow the MVVM pattern (located in `presentation/` folders)

### Routing
- Uses **go_router** for declarative routing
- Main router configuration in `lib/core/routes/router.dart`
- App starts with `/splash` route, then navigates to `/login` or main shell
- Main shell uses `StatefulShellRoute` with tab navigation for:
  - `/inbound` - Inbound operations
  - `/outbound` - Outbound operations  
  - `/outbound_1f` - 1st floor outbound operations

### Network Layer
- **Dio** for HTTP requests
- Abstract `ApiService` interface in `lib/core/network/http/api_service.dart`
- Implementation in `ApiServiceImpl` using Dio
- Mock implementation available for testing
- API configuration in `lib/core/config/api_config.dart`
- MQTT support planned (structure exists but not implemented)

### Project Structure
```
lib/
├── core/
│   ├── config/          # API configuration
│   ├── constants/       # App constants (colors, sizes)
│   ├── network/         # HTTP and MQTT services
│   ├── routes/          # Routing configuration
│   ├── services/        # Core app services
│   └── themes/          # App theming
├── features/            # Feature-based modules
│   ├── splash/          # App initialization
│   ├── login/           # Authentication
│   ├── inbound/         # Inbound operations
│   ├── outbound/        # Outbound operations
│   └── outbound_1f/     # 1st floor outbound
└── presentation/        # Shared UI components
```

### Feature Architecture
Each feature follows Clean Architecture principles:
- `domain/` - Business logic and use cases
- `presentation/` - UI screens and ViewModels
- ViewModels use Riverpod providers for state management

## Key Implementation Notes

### Current State
- Project is in early development with many TODO items
- Splash screen and basic navigation implemented
- Most feature screens are placeholder implementations
- Network layer structure defined but needs configuration
- Login screen exists but authentication logic incomplete

### Dependencies
- `flutter_riverpod`: State management
- `go_router`: Navigation and routing
- `dio`: HTTP client for API communication
- `flutter_lints`: Code analysis and linting

### Platform Support
- Primary target: Windows (see `windows/` folder structure)
- Secondary target: Android (see `android/` folder structure)
- Uses Material Design

## Development Patterns

### File Naming
- Use snake_case for file names
- Screen files: `*_screen.dart`
- ViewModel files: `*_viewmodel.dart`
- Service files: `*_service.dart`

### Code Organization
- Features are self-contained in their own directories
- Core functionality is shared across features
- Presentation layer separated from business logic
- Abstract interfaces defined before implementations

### Navigation Flow
1. App starts with `/splash` (SplashScreen)
2. Initializes app using InitializeAppUseCase
3. Navigates to `/login` (LoginScreen)
4. After login, navigates to main shell with tabs
5. Main shell provides tab navigation between main features