# DutyFlow — Campus Cleaning Management System

> A role-based campus cleaning management system for assigning, tracking, and verifying classroom and laboratory cleaning duties.

[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Spring Boot](https://img.shields.io/badge/Backend-Spring%20Boot-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB%20Atlas-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![Deployed](https://img.shields.io/badge/Backend-Render-46E3B7)](https://render.com/)

---

## 📌 Overview

DutyFlow is a mobile-based campus cleaning management system designed to digitize the daily cleaning workflow of classrooms and laboratories.

The application connects three main roles:

- **Administrator** — creates and manages cleaning duties and assignments.
- **Sweeper** — views assigned rooms and updates cleaning completion status.
- **Invigilator / Faculty** — verifies completed cleaning duties or rejects them with a reason.

The system provides a centralized record of cleaning activities from assignment through verification.

---

## 🎯 Problem Statement

Classroom and laboratory cleaning activities can be difficult to monitor when assignments and completion records are handled manually.

Administrators need to know:

- Which rooms have been assigned for cleaning
- Which sweeper is responsible for each room
- Whether cleaning has been completed
- Whether the completed work has been verified
- Which duties were rejected or are still pending

DutyFlow addresses this by providing a digital workflow for cleaning assignment, completion tracking, and faculty verification.

---

## 💡 Solution

The system follows a simple workflow:

```text
Administrator
     │
     ▼
Assign Cleaning Duty
     │
     ▼
Sweeper Cleans Room
     │
     ▼
Mark as Completed
     │
     ▼
Invigilator / Faculty
     │
     ├── Verify
     │
     └── Reject + Reason
             │
             ▼
        Re-clean if required
Duty Status Flow
PENDING
   │
   ▼
CLEANED
   │
   ├──────────────► REJECTED
   │                    │
   │                    ▼
   │                 CLEANED
   │
   ▼
VERIFIED
⚡ Key Features
👨‍💼 Administrator
Create and manage cleaning duties
Assign sweepers to rooms
Assign faculty / invigilators
View campus-wide duties
Update assignments
Delete duties
Monitor duty status
Prevent duplicate active room assignments
🧹 Sweeper
Secure login
View assigned cleaning duties
View classroom and laboratory information
Mark cleaning as completed
Track duty status
View previous records
👨‍🏫 Invigilator / Faculty
View assigned cleaning duties
Review completed cleaning
Verify cleaning completion
Reject unsatisfactory cleaning
Provide rejection reasons
📊 Management & Tracking
Centralized duty records
Status-based workflow
Assignment tracking
Verification tracking
Cleaning history
Daily PDF reporting
🛡️ Assignment Integrity

DutyFlow includes protection against overlapping active room assignments.

Before creating a new duty for a room, the backend checks whether the room already has an active duty that has not been verified.

This prevents multiple active assignments from being created for the same room.

🏗️ System Architecture
                    ┌────────────────────┐
                    │    Flutter APK     │
                    │     Mobile App     │
                    └─────────┬──────────┘
                              │
                         REST / HTTP
                              │
                              ▼
                    ┌────────────────────┐
                    │    Spring Boot     │
                    │      Backend       │
                    │                    │
                    │  REST Controllers  │
                    │  Service Layer     │
                    │  MongoDB Access    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │   MongoDB Atlas    │
                    │      Database      │
                    └────────────────────┘

                    Backend Deployment
                           │
                           ▼
                         Render
Deployment Model

The Flutter application is distributed as an Android APK.

The Spring Boot backend is deployed on Render and communicates with MongoDB Atlas.

Multiple devices can use the same backend simultaneously.

📱 Sweeper Device ─────┐
📱 Sweeper Device ─────┤
📱 Faculty Device ─────┼──► Render ───► MongoDB Atlas
📱 Admin Device ───────┘
🧰 Technology Stack
Layer	Technology
Mobile Frontend	Flutter / Dart
Backend	Spring Boot / Java
Build Tool	Maven
Database	MongoDB Atlas
API	REST
Deployment	Render
Database Access	Spring Data MongoDB
Version Control	Git / GitHub
📱 Application Screens
Login & Dashboard
<p align="center"> <img src="https://github.com/user-attachments/assets/9b9c10bf-5dc4-4b88-937e-849bd07e0e0d" width="220" /> <img src="https://github.com/user-attachments/assets/980633fe-e8ac-40f2-b88c-fd111514ce41" width="220" /> <img src="https://github.com/user-attachments/assets/454a5628-2f52-4f3b-b913-3667ac455e2f" width="220" /> </p>
Additional Screens
<details> <summary><b>View all application screens</b></summary> <br> <p align="center"> <img src="https://github.com/user-attachments/assets/de54aa72-bfe0-43e4-85d6-daa4b331c7e5" width="220" /> <img src="https://github.com/user-attachments/assets/79d33423-786e-41ab-9477-d6c131ab5484" width="220" /> <img src="https://github.com/user-attachments/assets/218b83a9-a0c2-41b7-b679-f103645af14a" width="220" /> <img src="https://github.com/user-attachments/assets/99159fd8-c817-42ad-9207-d1854b7f3876" width="220" /> <img src="https://github.com/user-attachments/assets/6b9aad19-8f4b-46c3-a81e-b65919de8a5b" width="220" /> <img src="https://github.com/user-attachments/assets/5458d281-5a62-4aa2-8af6-f7b4375ab325" width="220" /> <img src="https://github.com/user-attachments/assets/57b96f00-ac01-49fa-9ec7-3c5503774a95" width="220" /> <img src="https://github.com/user-attachments/assets/8502419d-a4a7-444b-945e-ab56e2d8e21b" width="220" /> <img src="https://github.com/user-attachments/assets/b36a7958-f0c6-46ca-8aa7-2ac077b768a0" width="220" /> <img src="https://github.com/user-attachments/assets/8d7be66f-47dd-4d24-86e1-8572d63c8c7e" width="220" /> <img src="https://github.com/user-attachments/assets/171e2369-7ffd-413c-8278-12b08bf13f9f" width="220" /> <img src="https://github.com/user-attachments/assets/be295b00-8002-4025-b90f-e88607c36209" width="220" /> <img src="https://github.com/user-attachments/assets/aa509212-eb25-4204-ad0f-46424abdd626" width="220" /> <img src="https://github.com/user-attachments/assets/b7fd8b17-75e7-4352-b511-d42fb1a75efc" width="220" /> <img src="https://github.com/user-attachments/assets/70c5e23f-ce0e-4399-b71e-0f88f7b51a42" width="220" /> <img src="https://github.com/user-attachments/assets/8b5d2cb6-38bd-47bc-b9f7-a5ef2e51a0d7" width="220" /> </p> </details>
🔌 Backend API Overview

The backend exposes REST APIs for managing cleaning duties.

Duty Management
GET    /api/duties
GET    /api/duties/department/{department}
POST   /api/duties
PATCH  /api/duties/{id}/status
PATCH  /api/duties/{id}/faculty
PATCH  /api/duties/{id}/assignment
DELETE /api/duties/{id}
Status Updates

The status endpoint is used for cleaning completion and verification workflows.

Supported workflow states include:

PENDING
CLEANED
VERIFIED
REJECTED
📁 Project Structure
campus-cleaning-system/
│
├── frontend/
│   ├── lib/
│   ├── android/
│   └── ...
│
├── backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       └── resources/
│   ├── pom.xml
│   └── Dockerfile
│
├── .gitignore
└── README.md
🚀 Deployment
Frontend

The Flutter application is built as an Android APK:

flutter build apk --release
Backend

The Spring Boot backend is deployed on Render.

Database

MongoDB Atlas provides the cloud database used by the deployed backend.

Environment-specific credentials are stored outside the source code.

⚙️ Local Development
Prerequisites
Flutter SDK
Java 17+
Maven
MongoDB / MongoDB Atlas
Android Studio or Android SDK
Git
Run Backend
cd backend
./mvnw spring-boot:run

Windows:

cd backend
.\mvnw.cmd spring-boot:run
Run Frontend
cd frontend
flutter pub get
flutter run
🔐 Environment Variables

The production database connection is supplied through an environment variable.

MONGODB_URI=<your-mongodb-connection-string>

Never commit credentials, passwords, API keys, or other secrets to GitHub.

🗺️ Future Enhancements

Planned improvements include:

Firebase Cloud Messaging (FCM) notifications
Push notifications for assigned duties
Additional reporting and analytics
Enhanced cleaning verification
QR-based room identification
👨‍💻 Project

DutyFlow — Campus Cleaning Management System

Developed to improve the assignment, tracking, and verification of classroom and laboratory cleaning activities through a centralized digital workflow.

📄 License

This project is developed as an academic/college project.
