<p align="center">
  <img src="assets/banner/github_banner.png" alt="AKS MediCare Pro Banner" width="100%">
</p>

<p align="center">
  <img src="assets/logo/aks_medicare_pro_logo.png" alt="AKS MediCare Pro Logo" width="180">
</p>

<h1 align="center">🏥 AKS MediCare Pro</h1>

<p align="center">
Enterprise Offline-First Hospital & Clinic Management System
</p>

<p align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-Enabled-6750A4?style=for-the-badge)
![SQLite](https://img.shields.io/badge/SQLite-Database-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-00A8E8?style=for-the-badge)
![GoRouter](https://img.shields.io/badge/GoRouter-Navigation-blue?style=for-the-badge)
![Android](https://img.shields.io/badge/Android-Supported-3DDC84?style=for-the-badge&logo=android)
![Windows](https://img.shields.io/badge/Windows-Supported-0078D4?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-success?style=for-the-badge)

</p>

---

# 📖 Overview

AKS MediCare Pro is a modern Hospital & Clinic Management System built with Flutter.

The application follows an **Offline-First** architecture, allowing hospitals and clinics to continue working even without an internet connection.

It is designed for:

- 🏥 Hospitals
- 🏥 Multi-Speciality Clinics
- 👨‍⚕️ Doctors
- 🩺 Diagnostic Centers
- 💊 Pharmacies

---

# ✨ Key Features

### 👥 Patient Management

- Patient Registration
- Patient Search
- Patient History
- Emergency Registration

### 👨‍⚕️ Doctor Management

- Doctor Profiles
- Department Allocation
- Consultation Schedule

### 🩺 OPD

- Token System
- Consultation
- Prescription

### 🛏 IPD

- Bed Management
- Admission
- Discharge
- Ward Allocation

### 🧪 Laboratory

- Test Requests
- Test Reports
- Lab History

### 🩻 Radiology

- X-Ray
- CT Scan
- MRI
- Ultrasound

### 💊 Pharmacy

- Medicine Inventory
- Billing
- Stock Tracking
- Purchase Records

### 💳 Billing

- OPD Billing
- IPD Billing
- Laboratory Billing
- Pharmacy Billing

### 📦 Inventory

- Stock Management
- Purchase Management
- Vendor Management

### 👨‍💼 HR

- Staff Management
- Attendance
- Payroll (Planned)

### 📊 Reports

- Daily Reports
- Monthly Reports
- Revenue Reports
- Department Reports

### 🔐 Security

- Secure Login
- Role Based Access
- Offline Database

### ☁ Future Roadmap

- LAN Synchronization
- Cloud Synchronization
- AI Assistant
- Patient Portal
- Doctor Portal

---

# 🛠 Technology Stack

| Technology | Usage |
|------------|-------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Material 3 | Design System |
| Riverpod | State Management |
| GoRouter | Navigation |
| SQLite | Local Database |
| Clean Architecture | Project Structure |
| Repository Pattern | Data Layer |
SQLite
Offline First Architecture
TCP Socket Networking
JSON Serialization

---

# 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ |
| Windows | ✅ |
| Linux | 🚧 |
| Web | 🚧 |
| macOS | 🚧 |
| iOS | 🚧 |

---

# 📂 Project Structure

```text
lib/
│
├── app/
├── core/
├── database/
├── features/
│
│   ├── auth/
│   ├── dashboard/
│   ├── patients/
│   ├── doctors/
│   ├── opd/
│   ├── ipd/
│   ├── laboratory/
│   ├── radiology/
│   ├── pharmacy/
│   ├── billing/
│   ├── inventory/
│   ├── hr/
│   └── reports/
│
├── shared/
└── main.dart
```

---

# 📸 Application Preview

| Dashboard | Patient | OPD |
|-----------|---------|-----|
| ![](assets/screenshots/dashboard.png) | ![](assets/screenshots/patient.png) | ![](assets/screenshots/opd.png) |

| Pharmacy | Reports | Billing |
|----------|---------|----------|
| ![](assets/screenshots/pharmacy.png) | ![](assets/screenshots/reports.png) | ![](assets/screenshots/billing.png) |

> Add screenshots later as the application develops.

---

## 🏗 System Architecture

<p align="center">
  <img src="assets/diagrams/architecture.png"
       alt="System Architecture"
       width="100%">
</p>

---

## 🗄 Database ER Diagram

<p align="center">
  <img src="assets/diagrams/er_diagram.png"
       alt="Database ER Diagram"
       width="100%">
</p>

---

# 🚀 Getting Started

Clone the repository:

```bash
git clone https://github.com/abhishek027aks/AKS-MediCare-Pro.git
```

Go inside project:

```bash
cd AKS-MediCare-Pro
```

Install packages:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

---

# 📌 Development Progress

| Module                     | Status                             |
| -------------------------- | ---------------------------------- |
| Foundation                 | ✅ Complete                         |
| Authentication & Security  | ✅ Complete                         |
| User Management            | ✅ Complete                         |
| Dashboard                  | 🚧 Enterprise Redesign In Progress |
| Patients                   | ✅ Complete                         |
| Doctor & Nursing           | ✅ Complete                         |
| OPD                        | ✅ Complete                         |
| IPD                        | ✅ Complete                         |
| Laboratory                 | ✅ Complete                         |
| Radiology                  | ⏳ Planned                          |
| Pharmacy                   | ✅ Complete                         |
| Billing                    | ✅ Complete                         |
| Inventory                  | ✅ Complete                         |
| HR & Attendance            | ✅ Complete                         |
| Appointment Scheduling     | ✅ Complete                         |
| Audit Logs                 | ✅ Complete                         |
| Backup & Restore           | ✅ Complete                         |
| Hospital Settings          | ✅ Complete                         |
| LAN Synchronization        | 🟡 Beta (Testing Pending)          |
| Reports & Analytics        | 🚧 In Progress                     |
| Notification Center        | ⏳ Planned                          |
| Approval Workflow          | ⏳ Planned                          |
| Cloud Synchronization      | ⏳ Planned                          |
| Printing System            | ⏳ Planned                          |
| Barcode / QR Support       | ⏳ Planned                          |
| Premium UI/UX              | 🚧 In Progress                     |
| Testing & Optimization     | 🚧 In Progress                     |
| Windows Installer          | ⏳ Planned                          |
| Android Production Release | 🚧 In Progress                     |


---

### 📊 Overall Project Status

| Area | Progress |
|------|----------|
| Core Infrastructure | ✅ 100% |
| Authentication & Security | ✅ 100% |
| User Management | ✅ 100% |
| Core Hospital Modules | ✅ ~90% |
| Reports & Analytics | 🚧 In Progress |
| Enterprise Features | ⏳ Planned |
| LAN Synchronization | ⏳ Planned |
| Cloud Synchronization | ⏳ Planned |
| Premium UI/UX | ⏳ Planned |
| Testing & Production | ⏳ Planned |

> **Estimated Overall Completion:** **90%**
Core Features: ✅ 98%
Enterprise Features: 🚧 70%
Professional UI/UX: 🚧 45%
Testing & Production: 🚧 40%

# 🗺 Roadmap

## ✅ Phase 1 – Foundation
- ✅ Flutter Project Setup
- ✅ Clean Architecture
- ✅ Riverpod State Management
- ✅ GoRouter Navigation
- ✅ SQLite Database
- ✅ Repository Pattern
- ✅ Shared Components

---

## ✅ Phase 2 – Core Hospital Management System
- ✅ Authentication & Security
- ✅ User Management
- ✅ Dashboard
- ✅ Patient Management
- ✅ Doctor & Nursing Module
- ✅ OPD Management
- ✅ IPD Management
- ✅ Laboratory Module
- 🚧 Radiology Module
- ✅ Pharmacy Management
- ✅ Billing Management
- ✅ Inventory Management
- ✅ HR & Attendance
- ✅ Audit Logging

---

## 🚧 Phase 3 – Business Intelligence
- 🚧 Reports & Analytics
- 🚧 Dashboard Statistics
- 🚧 Advanced Search & Filters
- 🚧 Revenue & Performance Reports

---

## ⏳ Phase 4 – Enterprise Features
- ⏳ Role-Based Permission Management (RBAC)
- ⏳ Delete Approval Workflow
- ⏳ Notification Center
- ⏳ Hospital Configuration
- ⏳ Backup & Restore
- ⏳ Printing System
- ⏳ Barcode / QR Code Support
- ⏳ PDF & Excel Export
- ⏳ Appointment Scheduling

---

## ⏳ Phase 5 – Network & Synchronization
- ⏳ LAN Synchronization
- ⏳ Multi-Computer Support
- ⏳ Real-Time Data Synchronization
- ⏳ Conflict Resolution
- ⏳ Cloud Synchronization
- ⏳ Multi-Branch Hospital Support

---

## ⏳ Phase 6 – Production Release
- ⏳ Premium UI/UX Redesign
- ⏳ Performance Optimization
- ⏳ Security Hardening
- ⏳ Unit & Integration Testing
- ⏳ Windows Installer
- ⏳ Android Production Build
- ⏳ Documentation
- ⏳ AI Integration
- ⏳ Patient Portal
- ⏳ Doctor Portal

---
### 📅 Appointment Management

- Appointment Booking
- Doctor Schedule
- Patient Scheduling
- Appointment Status
- OPD Check-in

  ### 📝 Audit Logs

- Login History
- User Activity Tracking
- Create / Update / Delete Logs
- Secure Audit Trail

  ### 💾 Backup & Restore

- Database Backup
- Database Restore
- Offline Backup

  ### 🌐 LAN Synchronization

- Device to Device Sync
- Offline Data Sharing
- Patient Sync
- Billing Sync
- Inventory Sync

  ### ⚙ Hospital Settings

- Application Settings
- Backup Management
- Sync Settings
- Database Tools

  
### 🚀 Future Vision

- 🌐 Enterprise Offline-First Hospital Management System
- 🏥 Multi-Hospital & Multi-Branch Support
- 🔄 Real-Time LAN Synchronization
- ☁ Secure Cloud Synchronization
- 🤖 AI-Powered Healthcare Assistant
- 📱 Patient & Doctor Self-Service Portals
- 📊 Enterprise Analytics & Decision Support
- 🇮🇳 Proudly Designed & Developed in India

---

# 🤝 Contributing

Contributions are welcome.

1. Fork the repository.
2. Create a new branch.
3. Commit your changes.
4. Push the branch.
5. Create a Pull Request.

Please read **CONTRIBUTING.md** before contributing.

---

# 🔒 Security

If you discover a security issue, please report it responsibly.

See **SECURITY.md** for details.

---

# 📜 License

This project is licensed under the MIT License.

See **LICENSE** for more information.

---

# 👨‍💻 Developer

**Abhishek Kumar Singh**

GitHub: https://github.com/abhishek027aks

---

<p align="center">

⭐ If you like this project, don't forget to give it a **Star**.

Made with ❤️ using Flutter.

</p>
