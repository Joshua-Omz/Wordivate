# Wordivate

A Flutter vocabulary learning application that helps users discover, save, and organize new words with AI-powered definitions.

## 🏗️ Project Structure

This project follows a clean, organized structure to maintain code quality and readability:

```
lib/
├── core/                 # Core functionality
│   ├── constants/        # App-wide constants
│   ├── services/         # Business logic services
│   └── utils/           # Utility functions
├── models/              # Data models
├── providers/           # State management (Riverpod)
├── views/               # UI components
│   ├── auth/           # Authentication screens
│   ├── categories/     # Category management
│   ├── components/     # Reusable UI components
│   │   └── shared/     # Shared widgets
│   ├── home/           # Main application screens
│   ├── profile/        # User profile
│   ├── settings/       # App settings
│   ├── splash/         # Onboarding/splash
│   └── startup/        # App initialization
└── main.dart           # App entry point
```

## 🎯 Recent Improvements

### Code Quality & Organization
- ✅ **File Naming**: Consistent snake_case naming convention
- ✅ **Import Organization**: Clean, organized imports throughout
- ✅ **Logging**: Centralized logging utility replacing print statements
- ✅ **Error Handling**: Improved error handling with proper logging
- ✅ **Constants**: Centralized app constants for better maintainability

### Architecture Improvements
- ✅ **State Management**: Well-documented Riverpod providers
- ✅ **Shared Components**: Reusable UI widgets (SearchField, EmptyStateWidget, ErrorWidget)
- ✅ **Service Layer**: Clean separation of business logic
- ✅ **Documentation**: Comprehensive code documentation

### Configuration
- ✅ **Linting**: Enhanced analysis_options.yaml with custom rules
- ✅ **Dependencies**: Cleaned up unused dependencies
- ✅ **Assets**: Fixed asset path inconsistencies

## 🔧 Development Guidelines

### Adding New Features
1. Create models in `lib/models/`
2. Add business logic to `lib/core/services/`
3. Create providers in `lib/providers/`
4. Build UI components in `lib/views/`
5. Use shared components from `lib/views/components/shared/`

### Code Standards
- Use **snake_case** for file names
- Add **comprehensive documentation** for public APIs
- Use **AppLogger** instead of print statements
- Follow **Dart/Flutter naming conventions**
- Use **constants** from `app_constants.dart`

### State Management
- Use **Riverpod** for state management
- Keep providers focused and single-responsibility
- Document state classes thoroughly
- Handle errors gracefully with proper logging

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.7.2
- Dart SDK
- Firebase project (for authentication and cloud storage)

### Setup
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase (see firebase_options.dart)
4. Create a `.env` file with your API keys
5. Run the app: `flutter run`

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📝 Contributing

When contributing to this project:
1. Follow the established code structure
2. Add proper documentation
3. Use the shared components when possible
4. Follow the linting rules
5. Test your changes thoroughly

## 📚 Key Features

- **AI-Powered Definitions**: Get word definitions using Google's Generative AI
- **Category Organization**: Organize words into custom categories
- **Offline Storage**: Local storage with Hive for offline access
- **Firebase Integration**: Cloud sync and user authentication
- **Clean UI**: Material Design with custom theming
- **Search & Filter**: Find words quickly with search functionality

---

For more information about the architecture and implementation details, see the code documentation within each module.
