# Mindify

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/a/a7/React-icon.svg" alt="React.js" width="80" height="80" />
  <img src="https://vitejs.dev/logo.svg" alt="Vite" width="80" height="80" />
  <img src="https://storage.googleapis.com/cms-storage-bucket/4fd5520fe28ebf839174.svg" alt="Flutter" width="80" height="80" />
  <img src="https://nodejs.org/static/images/logo.svg" alt="Node.js" width="80" height="80" />
  <img src="https://firebase.google.com/images/brand-guidelines/logo-logomark.png" alt="Firebase" width="80" height="80" />
  <img src="https://cloud.google.com/images/social-icon-google-cloud-1200-630.png" alt="Google Cloud Storage" width="160" height="80" />
</div>

Mindify is a cross-platform online learning and teaching application designed to provide a personalized and efficient learning experience. The project leverages modern technologies to build a robust system catering to students, educators, and administrators.

## Table of Contents

- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
  - [Frontend](#frontend)
  - [Backend](#backend)
  - [Database](#database)
  - [Authentication](#authentication)
  - [Storage](#storage)
- [System Architecture](#system-architecture)
- [Installation and Setup](#installation-and-setup)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)

## Key Features

- **Personalized Learning**: Users can customize their learning path based on preferences and skill levels.
- **Comprehensive Learning Tools**: Includes video lectures, quizzes, study materials, and forums for discussions.
- **Cross-Platform Support**: Available on mobile (iOS, Android) and web platforms for seamless access anywhere.
- **Admin Management**: Admin dashboard to manage users, courses, and requests.

## Tech Stack

### **Frontend**
- **React.js (Vite)**: Used for developing the admin interface, offering fast performance and a modern development experience.
- **Flutter**: Powers the mobile application, ensuring a consistent user experience across Android and iOS.

### **Backend**
- **Node.js**: Serves as the backend runtime environment, enabling efficient handling of API requests.
- **Express.js**: Framework used for building RESTful APIs for the system.

### **Database**
- **Firebase Firestore**: NoSQL database for storing user data, course information, and other essential details.

### **Authentication**
- **Firebase Authentication**: Secures user authentication using Google OAuth2 and email/password methods.

### **Storage**
- **Google Cloud Storage**: Stores video lectures, course materials, and user avatars.

## System Architecture

Mindify employs a RESTful API architecture to ensure scalability and maintainability. Key components include:
- **User Interaction**: Mobile and web interfaces for students, instructors, and administrators.
- **API Gateway**: Handles all incoming requests and routes them to the appropriate services.
- **Database Integration**: Firebase Firestore for real-time updates and secure data management.

## Installation and Setup

### Prerequisites
- Node.js and npm installed
- Flutter SDK installed
- Firebase project configured

### Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/HoangPhu0705/Mindify.git
   cd Mindify
2. **Backend setup**
- Navigate to the backend folder:
   ```bash
   cd backend
- Install dependencies:
  ```bash
  npm install
- Configure environment variables: Create a .env file based on .env.example and add your Firebase credentials.
- Start the server:
  ```bash
  npm start
3. **Admin setup**
- Navigate to the admin frontend folder:
   ```bash
   cd admin
- Install dependencies:
  ```bash
  npm install
- Start the server:
  ```bash
  npm run dev
4. **Mobile App Setup**
- Navigate to the mobile folder:
   ```bash
   cd frontend
- Install dependencies:
  ```bash
  flutter pub get
- Run the app on an emulator or physical device
  ```bash
  flutter run

### Highlights
- **Table of Contents** helps navigate different sections quickly.
