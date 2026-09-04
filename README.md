# DutyFlow — Campus Facility Management System

> A full-stack, role-based assignment and verification engine built for enterprise campus management.

[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Spring Boot](https://img.shields.io/badge/Backend-Spring%20Boot-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB%20Atlas-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![Deployed](https://img.shields.io/badge/Backend-Render-46E3B7)](https://render.com/)

---

## 📱 Previews
<p align="center">
  <img src="https://github.com/user-attachments/assets/9b9c10bf-5dc4-4b88-937e-849bd07e0e0d" width="250" />
  <img src="https://github.com/user-attachments/assets/980633fe-e8ac-40f2-b88c-fd111514ce41" width="250" />
  <img src="https://github.com/user-attachments/assets/454a5628-2f52-4f3b-b913-3667ac455e2f" width="250" />
</p>

## ⚡ Core Features
* **Real-Time Role Assignment:** Dynamic allocation of rooms to sweepers and invigilators.
* **State Management:** Live status tracking (`Pending` ➔ `Cleaned` ➔ `Verified` or `Rejected`).
* **Algorithmic Safeguards:** Custom duplicate room-blocking engine to prevent overlapping active assignments.
* **Automated Reporting:** PDF report generation for daily campus cleaning logs.

## 💡 Workflow & Architecture
DutyFlow digitizes the daily cleaning workflow to provide a centralized record of activities from assignment through verification:

* **Administrator:** Creates and manages cleaning duties, assigns sweepers/faculty, and monitors campus-wide status.
* **Sweeper:** Views assigned rooms and updates cleaning completion status.
* **Invigilator / Faculty:** Verifies completed cleaning duties or rejects them with a mandatory reason.

## 🔌 Backend API Overview
The backend exposes a RESTful API built with Java Spring Boot, connecting to MongoDB Atlas.

* `GET /api/duties` — Fetch all duties
* `GET /api/duties/department/{department}` — Filter by department
* `POST /api/duties` — Create new assignment (includes overlap protection)
* `PATCH /api/duties/{id}/status` — Update workflow state
* `PATCH /api/duties/{id}/faculty` — Assign/update faculty
* `DELETE /api/duties/{id}` — Remove duty

## 🚀 Future Roadmap
* **Targeted Push Notifications:** Implementing Firebase Cloud Messaging (FCM) via topic subscriptions (e.g., `sweeper_ramesh`) to eliminate complex token-based user databases and route specific room assignment alerts directly to lock screens.

<br>

<details>
<summary><b>📸 Click to expand remaining app screens</b></summary>
<br>
<p align="center">
  <img src="https://github.com/user-attachments/assets/de54aa72-bfe0-43e4-85d6-daa4b331c7e5" width="250" />
  <img src="https://github.com/user-attachments/assets/79d33423-786e-41ab-9477-d6c131ab5484" width="250" />
  <img src="https://github.com/user-attachments/assets/218b83a9-a0c2-41b7-b679-f103645af14a" width="250" />
  <img src="https://github.com/user-attachments/assets/99159fd8-c817-42ad-9207-d1854b7f3876" width="250" />
  <img src="https://github.com/user-attachments/assets/6b9aad19-8f4b-46c3-a81e-b65919de8a5b" width="250" />
  <img src="https://github.com/user-attachments/assets/5458d281-5a62-4aa2-8af6-f7b4375ab325" width="250" />
  <img src="https://github.com/user-attachments/assets/57b96f00-ac01-49fa-9ec7-3c5503774a95" width="250" />
  <img src="https://github.com/user-attachments/assets/8502419d-a4a7-444b-945e-ab56e2d8e21b" width="250" />
  <img src="https://github.com/user-attachments/assets/b36a7958-f0c6-46ca-8aa7-2ac077b768a0" width="250" />
  <img src="https://github.com/user-attachments/assets/8d7be66f-47dd-4d24-86e1-8572d63c8c7e" width="250" />
  <img src="https://github.com/user-attachments/assets/171e2369-7ffd-413c-8278-12b08bf13f9f" width="250" />
  <img src="https://github.com/user-attachments/assets/be295b00-8002-4025-b90f-e88607c36209" width="250" />
  <img src="https://github.com/user-attachments/assets/aa509212-eb25-4204-ad0f-46424abdd626" width="250" />
  <img src="https://github.com/user-attachments/assets/b7fd8b17-75e7-4352-b511-d42fb1a75efc" width="250" />
  <img src="https://github.com/user-attachments/assets/70c5e23f-ce0e-4399-b71e-0f88f7b51a42" width="250" />
  <img src="https://github.com/user-attachments/assets/8b5d2cb6-38bd-47bc-b9f7-a5ef2e51a0d7" width="250" />
</p>
</details>
