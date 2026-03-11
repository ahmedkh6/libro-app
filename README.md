# Libro Reading App

A premium, cross-platform Flutter mobile app for reading personal PDF and EPUB books, inspired by Apple Books interface patterns and designed using the Google Stitch UI specifications.

## 🚀 Features Implemented
- **Layered Architecture:** Features (auth, library, reader), Core, and Data logic properly separated.
- **Riverpod State Management:** Clean, testable logic for authentication and the library.
- **GoRouter Navigation:** Declarative bottom navigation shell routing.
- **Local Persistence with Hive:** Fast, lightweight storage for keeping track of imported `Book` metadata and `ReadingProgress`.
- **Material 3 Design:** A sleek, premium theme matching the provided Stitch onboarding designs.
- **PDF Rendering:** Built-in PDF reader using `syncfusion_flutter_pdfviewer`.
- **Mock Authentication:** Fake Google Sign-In loop for local rapid development.

## 📱 Getting Started
1. Ensure the Flutter SDK is installed.
2. Run `flutter pub get` in the terminal to ensure all packages are fetched.
3. Run the app locally on your choice of emulator or desktop device using `flutter run`.

## ⏭️ Next Steps for Production
*   **Firebase Setup:** The `AuthService` currently mocks login delay and saves a local boolean flag using `SharedPreferences`. To implement the real Google Sign-In, you will need to create a project in the Firebase Console, register the app package name, configure the OAuth Consent Screen, and replace the mock function in `AuthService`.
*   **EPUB Support:** A placeholder Snackbar exists for EPUB importing. You can integrate `epub_view` following the same architecture as the `PdfReaderScreen`.
*   **Permissions:** You may need to declare `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>` in `android/app/src/main/AndroidManifest.xml` if compiling for physical Android devices below Android 13 to select files.
