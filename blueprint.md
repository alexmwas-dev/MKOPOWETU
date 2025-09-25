# Mkopo Wetu - Blueprint

## Overview

Mkopo Wetu is a Flutter-based mobile application that provides a platform for users to apply for and manage loans. The application is designed to be user-friendly and intuitive, with a focus on providing a seamless user experience.

## Style, Design, and Features

### Style

*   **Theme:** The application uses a custom Material 3 theme.
*   **Color Scheme:** A vibrant and modern color scheme has been implemented:
    *   **Primary Color:** Emerald Green (`#00C853`)
    *   **Screen Background:** Light Green (`#F0FFF4`)
    *   **Card Background:** White
*   **Typography:** The application uses the `GoogleFonts` package (`Oswald`, `Roboto`, `Open Sans`) to provide a consistent and visually appealing typography.
*   **Iconography:** The application uses Material Design icons to provide a consistent and intuitive user interface.

### Design

*   **Layout:** The application uses a combination of `ListView`, `Column`, and `Row` widgets to create a visually balanced and responsive layout.
*   **Components:** The application uses a variety of Material Design components, including `Card`, `ElevatedButton`, `TextFormField`, and a customized `BottomNavBar`.
*   **Navigation:** The application uses the `go_router` package for a declarative routing solution.

### Features

*   **Authentication:** The application provides a complete authentication solution, including sign-up, sign-in, and sign-out functionality using Firebase Authentication.
*   **Loan Application & Management:** Users can apply for loans, view their loan history, and see the status of their applications (pending, rejected, paid).
*   **Profile Management:** Users can view and edit their profile information.
*   **AdMob Integration:** The application integrates with Google AdMob to display banner and interstitial ads.
*   **Real-time Notifications:** The app displays temporary notifications for loan disbursements to create a sense of activity.

## Current Task: Theming and Homepage Layout Fix

The previous task was to implement a consistent color scheme across the application and fix a layout issue on the homepage where the main content was not displaying correctly.

### Plan & Files Updated

1.  **Define Color Scheme:** The color scheme was updated in `lib/main.dart` to use an emerald primary color, a light green screen background, and white for card backgrounds. A `cardTheme` was also defined for consistent card styling.
2.  **Fix Homepage Layout:** The `Expanded` widget that was causing the layout issue in `lib/src/pages/home/home_page.dart` was removed. The UI components were also updated to use the new color scheme.
