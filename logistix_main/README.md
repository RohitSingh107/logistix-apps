# Logistix Flutter App

A professional Flutter application with clean architecture and best practices.

## Project Structure

```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── di/            # Dependency injection
│   ├── models/        # Base models
│   ├── network/       # API client and interceptors
│   └── repositories/  # Base repository interfaces
├── features/          # Feature-based modules
│   └── auth/         # Example feature module
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
└── shared/           # Shared widgets and utilities
    ├── widgets/
    └── utils/
```

## Setup Instructions

1. Create a `.env` file in the root directory with the following content:
```
API_BASE_URL=http://your-django-backend-url
API_KEY=your-api-key
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Features

- Clean Architecture
- BLoC Pattern for State Management
- Dependency Injection with GetIt
- API Integration with Dio
- Local Storage with Hive
- Responsive UI with ScreenUtil
- Environment Configuration
- Error Handling
- Logging

## Best Practices

1. **Code Organization**
   - Feature-first architecture
   - Separation of concerns
   - Clean architecture principles

2. **State Management**
   - BLoC pattern for complex state
   - Provider for simple state
   - Repository pattern for data

3. **API Integration**
   - Centralized API client
   - Interceptors for logging and error handling
   - Repository pattern for data access

4. **Error Handling**
   - Global error handling
   - Custom exceptions
   - User-friendly error messages

5. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
