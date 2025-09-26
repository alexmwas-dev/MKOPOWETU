# Mkopo Wetu Blueprint

## Overview

Mkopo Wetu is a Flutter application that allows users to apply for and manage loans. The application integrates with Firebase for backend services and M-Pesa for payments.

## Features

- User authentication with email and password
- Loan application and repayment
- View loan history and details
- M-Pesa integration for payments

## Design

- **Theme:** The application uses a green color scheme, with a modern and clean design.
- **Typography:** The app uses the default Flutter fonts.
- **Layout:** The layout is designed to be simple and intuitive, with a focus on user experience.

## Current Task: Standardize Payment Statuses

### Plan

1.  **Introduce `PaymentStatus` Enum:**
    *   Create a `PaymentStatus` enum in `lib/src/models/payment_model.dart` with the values `paid`, `initiated`, and `failed`.
2.  **Update `Payment` Model:**
    *   Modify the `Payment` class to use the `PaymentStatus` enum instead of a `String` for the `status` field.
    *   Update the `fromJson` and `toJson` methods to handle the new enum.
3.  **Update `PaymentListItem` Widget:**
    *   Modify the `PaymentListItem` widget in `lib/src/widgets/payment_list_item.dart` to use the `PaymentStatus` enum to determine the icon and color, representing `paid`, `initiated`, and `failed` statuses with distinct visual cues.
