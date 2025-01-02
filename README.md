## Restaurant Management App
## Overview
This is a comprehensive restaurant management application built using Flutter. Designed for seamless offline order management in restaurants, it ensures efficient handling of orders, tables, and menus without requiring constant internet connectivity. By integrating Firebase, the app leverages various services to manage data, authenticate users, and monitor app performance, enhancing overall functionality and user experience.

The app facilitates efficient management of restaurant operations, providing distinct functionalities for both managers and waiters. Delight Corner is designed to streamline tasks, from managing tables and menus to tracking orders and generating invoices, ensuring a seamless dining experience even in offline mode.

## Features
* User Authentication: Users can sign up and log in using email/password authentication, allowing them to securely access their accounts and manage orders.    

* Menu Management: The app allows users to view and interact with a dynamic menu of items. They can add and remove items to their cart, view prices, and place orders.

* Bill Tracking: Users can view their current and past bills, which are stored securely in the Firebase real-time database. The app handles bill expiration and auto-removal of old bills using Firebase Cloud Functions.

* Real-time Database: Firebase Real-Time Database is used to store user-related data (e.g., bills, menu items) and updates are reflected instantly across devices.

* Cloud Storage Integration: The app allows users to upload and view images related to their profile or other documents via Firebase Cloud Storage.

* State Management: The app uses Flutter Riverpod for efficient state management, ensuring smooth and responsive UI updates.

* Custom Splash Screen: A custom splash screen appears when the app starts, providing a branded experience.

* PDF and Printing Support: The app allows users to print their bills or other documents via the PDF and Printing packages.


## Screenshots

<img src="file:///C:/Users/rohan/CrossDevice/Rohan%20Vivo%201938/storage/DCIM/Screenshots/Screenshot_20241231_202021.jpg" width="150" height="280">
![Screenshot_20241231_202021](https://github.com/user-attachments/assets/ff14efdb-3110-4fc1-98df-9b7ea2b23a11)   ![Screenshot_20241231_202030](https://github.com/user-attachments/assets/acda39c8-27c5-407a-abb4-921256f1bd2e)
![Screenshot_20241231_202034](https://github.com/user-attachments/assets/be14d0a1-6829-44a2-bb48-0c8273bae766)  ![Screenshot_20241231_202139](https://github.com/user-attachments/assets/a2a064cb-8918-4b4f-bdae-163880c6fc60)


## Project Structure
> lib/: Contains the Dart files for the app's functionality.                                                                                    
    -main.dart: The entry point of the app, responsible for initializing Firebase and launching the main app UI.             
    -models/: Contains data models for MenuItem, Waiter, AppTable, etc.                             
    -services/: Contains services like Firebase authentication, database management, etc.                                
    -screens/: Contains the UI of the app's different screens.      

## Technologies Used
* Flutter: Framework for building natively compiled applications across mobile, web, and desktop.                                       
* Firebase Firestore: NoSQL cloud database with real-time data sync, ensuring instant updates across devices.                               
* Firebase Authentication: Secure authentication service for managing user logins.                                                     
* Google Fonts: Custom fonts for enhancing UI design.                                                                                             
* Material Design: UI design system for a modern, intuitive interface.                                                         
* Firebase Real-Time Data Sync: Automatic real-time updates across devices, ensuring data consistency.

## Contributing
* Fork the repository.                                                                                             
* Create a new branch (git checkout -b feature-xyz).                                                              
* Make changes and commit (git commit -am 'Add feature xyz').                                                     
* Push to the branch (git push origin feature-xyz).                                                                  
* Open a pull request.                                                                                                           


## Prerequisites
Flutter: Make sure you have Flutter SDK installed. You can follow the official installation guide.
Firebase Project: Create a Firebase project and set up Firebase Authentication, Firestore, and Firebase Storage.


## License
This project is licensed under the MIT License. See the LICENSE file for more details.

