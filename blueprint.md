# Okoaloan Blueprint

## Overview

Okoaloan is a mobile loan application built with Flutter. It allows users to apply for and manage loans.

## Style, Design, and Features

### Implemented

*   **Theme:** Light and dark themes with a consistent color scheme and typography using Google Fonts.
*   **Navigation:** `go_router` for declarative routing.
*   **State Management:** `provider` for managing application state.
*   **Firebase Integration:**
    *   Firebase Core
    *   Firebase Authentication
    *   Cloud Firestore
    *   Firebase Database
*   **UI Components:**
    *   Custom-styled buttons and text fields.
    *   Lottie animations for visual feedback.

### Current Task: Fix Build Error

**Plan:**

1.  **DONE:** Attempt to downgrade the `firebase_app_distribution` plugin to a known stable version.
2.  **DONE:** Override the Material Components library version in `android/build.gradle.kts` to resolve dependency conflicts.
3.  **DONE:** Remove the `firebase_app_distribution` plugin entirely to isolate the build error.
4.  **DONE:** Set the `minSdkVersion` to 21 in `android/app/build.gradle.kts` to support Android 5.0 and higher.
5.  **DONE:** Clean up the Gradle files by reverting unnecessary changes.
6.  **DONE:** Re-run the build to confirm the fix.

