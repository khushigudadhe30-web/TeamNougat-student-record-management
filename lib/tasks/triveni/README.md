<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Firestore-FF6F00?style=for-the-badge&logo=firebase&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
<img src="https://img.shields.io/badge/AI_Assisted-6E40C9?style=for-the-badge&logo=anthropic&logoColor=white" />

<br /><br />

# Student Record Management App

### Flutter × Firebase CRUD Application
**NIT Patna — Flutter Development Club | TeamNougat Task**

**Built by [Triveni Narayan Priy](https://github.com/triveninarayanpriy)**
`lib/tasks/triveni/`

<br />

</div>

---

## Overview

A production-quality **Student Record Management System** built with Flutter and **Firebase Firestore**, implementing complete CRUD operations across 7 student data fields. Features a golden-yellow Material Design 3 UI with real-time list sync via `StreamBuilder`, live search, and comprehensive form validation — powered entirely by Flutter's native `setState()` with zero external state management packages.

---

## Design — Figma First

Wireframes were completed in **Figma before writing any code**, following industry-standard design-first workflow.

<table>
  <tr>
    <td align="center" colspan="2"><strong>All Screens — Figma Reference</strong></td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <img src="screenshots/Allscreenfigmaref.png" width="520"/>
    </td>
  </tr>
</table>

**Color System**

| Token | Hex | Usage |
|---|---|---|
| Primary | `#F5C518` | AppBar, FAB, focused borders, avatars |
| Edit | `#2196F3` | Edit action icon |
| Danger | `#DC3545` | Delete icon, delete snackbar |
| Success | `#28A745` | Add / update confirmation snackbar |
| Surface | `#FFFFFF` | Cards |
| Background | `#FAFAFA` | Screen background |

---

## App Screenshots

<table>
  <tr>
    <td align="center"><strong>Home Screen</strong></td>
    <td align="center"><strong>Add Student</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Homescreen.png" width="230"/></td>
    <td align="center"><img src="screenshots/addstudent.png" width="230"/></td>
  </tr>
  <tr>
    <td align="center"><strong>Edit Student</strong></td>
    <td align="center"><strong>Delete Confirmation</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/editstudent.png" width="230"/></td>
    <td align="center"><img src="screenshots/deletescreenn.png" width="230"/></td>
  </tr>
  <tr>
    <td align="center" colspan="2"><strong>Live Search</strong></td>
  </tr>
  <tr>
    <td align="center" colspan="2"><img src="screenshots/searchstudent.png" width="230"/></td>
  </tr>
</table>

---

## Features

**Home Screen**
- Real-time student list powered by Firestore `snapshots()` — UI rebuilds automatically on every DB change
- Live search by Name or Roll Number via `setState()`, with inline clear button
- Student cards show golden avatar, name, roll number, department, semester, and CGPA
- Blue edit and red delete action icons per card; yellow Extended FAB to add a student

**Add / Edit Student**
- Single `AddEditStudentScreen` widget handles both modes — null parameter = Add, Student object = Edit
- 7-field validated form: Name, Roll Number, Department, Semester, CGPA, Phone, Email
- Edit mode pre-fills all fields via `TextEditingController` initialization in `initState()`
- Validation: empty fields blocked · Semester 1–8 · CGPA 0.0–10.0 · Phone exactly 10 digits · Email format
- Loading spinner on submit; green snackbar on success; auto-navigate back to Home

**Delete Confirmation**
- `AlertDialog` with red warning icon and the student's name in the message body
- Cancel safely dismisses; Delete closes the dialog → calls Firestore → shows red snackbar

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Database | Firebase Firestore (Cloud NoSQL, real-time) |
| State Management | Native `setState()` — no Provider, Bloc, or Riverpod |
| Architecture | Service-layer pattern — all Firestore logic isolated from UI |
| Design | Figma (wireframes before code) |
| IDE | VS Code + Flutter & Dart extensions |
| Version Control | Git + GitHub |

---

## Architecture & Data Flow

```
Firebase Firestore (Cloud Database)
        ↑↓   stream / add / update / delete
firestore_service.dart      ← all DB logic lives here
        ↑↓   Student objects
home_screen.dart  +  add_edit_student_screen.dart   ← UI only
        ↑↓   toMap() / fromMap()
student.dart                ← data model
```

---

## Folder Structure

```
lib/tasks/triveni/
├── models/
│   └── student.dart                  # Student data class — toMap() / fromMap()
├── services/
│   └── firestore_service.dart        # CRUD service — add, stream, update, delete
└── screens/
    ├── home_screen.dart              # StreamBuilder list · live search · FAB
    └── add_edit_student_screen.dart  # Dual-mode validated form (Add & Edit)
```

---

## CRUD Reference

| Operation | Screen | Firestore Call |
|---|---|---|
| **Create** | Add Student → Submit | `collection.add(student.toMap())` |
| **Read** | Home Screen list | `collection.orderBy('name').snapshots()` via `StreamBuilder` |
| **Update** | Edit Student → Update | `collection.doc(id).update(student.toMap())` |
| **Delete** | Delete Dialog → Confirm | `collection.doc(id).delete()` |
| **Search** | Home Screen search bar | Client-side filter on stream snapshot via `setState()` |

---

## Firestore Data Structure

```
students  (Collection)
└── {auto-generated-id}  (Document)
    ├── name:         "Triveni Narayan Priy"
    ├── rollNumber:   "2301EC042"
    ├── department:   "Electronics Engineering"
    ├── semester:     "3"
    ├── cgpa:         "8.5"
    ├── phone:        "9876543210"
    └── email:        "triveni@nitp.ac.in"
```

---

## AI-Assisted Development

**Claude (Anthropic)** was used as a pair-programming tool throughout this project — primarily to accelerate debugging and improve test coverage.

| Area | How AI Helped |
|---|---|
| **Debugging** | Identified root causes of `PlatformException (firebase_core/no-app)`, Gradle plugin ordering errors, and Firestore `PERMISSION_DENIED` — with exact line-level fixes |
| **Testing** | Suggested boundary-value test cases for form validation (e.g. CGPA = 10.0, 10.01; Semester = 0, 9; empty vs whitespace inputs) |
| **Code Review** | Flagged missing `mounted` guards before `setState` calls post-async; flagged controller disposal omissions |
| **Architecture** | Confirmed service-layer separation and `StreamBuilder` stream lifecycle correctness |
| **Firebase Setup** | Guided `google-services.json` placement, Gradle classpath ordering, and Firestore security rules |
| **UI CODE generation** | Used Figma for UI generation of the app and connected with backend


<div align="center">

**Made with ❤️ by Triveni Narayan Priy**

</div>
