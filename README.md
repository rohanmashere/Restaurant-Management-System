## Restaurant Management App
## Overview
Delight Corner is a comprehensive restaurant management application built using Flutter. It facilitates efficient management of restaurant operations, providing distinct functionalities for both managers and waiters. The app is designed to streamline tasks, from managing tables and menus to tracking orders and generating invoices, ensuring a seamless dining experience. By integrating Firebase, the app can leverage various Firebase services to manage data, authenticate users, and monitor app performance. Firebase plays a crucial role in enhancing the app's functionality and user experience.


## Features
User Authentication: Users can sign up and log in using email/password authentication, allowing them to securely access their accounts and manage orders.

Menu Management: The app allows users to view and interact with a dynamic menu of items. They can add and remove items to their cart, view prices, and place orders.

Bill Tracking: Users can view their current and past bills, which are stored securely in the Firebase real-time database. The app handles bill expiration and auto-removal of old bills using Firebase Cloud Functions.

Real-time Database: Firebase Real-Time Database is used to store user-related data (e.g., bills, menu items) and updates are reflected instantly across devices.

Cloud Storage Integration: The app allows users to upload and view images related to their profile or other documents via Firebase Cloud Storage.

State Management: The app uses Flutter Riverpod for efficient state management, ensuring smooth and responsive UI updates.

Custom Splash Screen: A custom splash screen appears when the app starts, providing a branded experience.

PDF and Printing Support: The app allows users to print their bills or other documents via the PDF and Printing packages.


## Project Structure
lib/: Contains the Dart files for the app's functionality.
  main.dart: The entry point of the app, responsible for initializing Firebase and launching the main app UI.
  models/: Contains data models for MenuItem, Waiter, AppTable, etc.
  services/: Contains services like Firebase authentication, database management, etc.
  screens/: Contains the UI of the app's different screens.
  widgets/: Contains reusable widget components.
  assets/: Contains images and fonts used in the app. This includes custom fonts like Lato and various images for the splash screen and branding.
