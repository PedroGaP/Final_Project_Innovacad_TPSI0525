# Innovacad API Endpoints Documentation

This document describes all available endpoints in the Innovacad API.

---

## Authentication & Sign

**Base Path:** `/sign`  
**Tag:** Sign  
**Description:** Authentication endpoints

| Method | Endpoint            | Description                            |
| ------ | ------------------- | -------------------------------------- |
| GET    | `/sign/session`     | Get current session (requires cookie)  |
| POST   | `/sign/in`          | Sign in with credentials               |
| POST   | `/sign/social/in`   | Sign in with social provider           |
| POST   | `/sign/send/verify` | Send verification email                |
| POST   | `/sign/verify`      | Verify email address                   |
| POST   | `/sign/validity`    | Check email validity                   |
| POST   | `/sign/link-social` | Link social account                    |
| GET    | `/sign/accounts`    | List linked accounts (requires cookie) |
| POST   | `/sign/send-otp`    | Send OTP for 2FA                       |
| POST   | `/sign/verify-otp`  | Verify OTP code                        |
| POST   | `/sign/enable-otp`  | Enable 2FA                             |
| POST   | `/sign/disable-otp` | Disable 2FA                            |

---

## Users

**Base Path:** `/user`  
**Tag:** User

| Method                                   | Endpoint | Description |
| ---------------------------------------- | -------- | ----------- |
| _Currently empty - no endpoints defined_ |          |             |

---

## Trainees

**Base Path:** `/trainees`  
**Tag:** Trainees  
**Description:** CRUD for trainees

| Method | Endpoint         | Description        |
| ------ | ---------------- | ------------------ |
| GET    | `/trainees/`     | Get all trainees   |
| GET    | `/trainees/<id>` | Get trainee by ID  |
| POST   | `/trainees/`     | Create new trainee |
| PUT    | `/trainees/<id>` | Update trainee     |
| DELETE | `/trainees/<id>` | Delete trainee     |

---

## Trainers

**Base Path:** `/trainers`  
**Tag:** Trainers  
**Description:** CRUD endpoint documentation for trainers

| Method | Endpoint         | Description        |
| ------ | ---------------- | ------------------ |
| GET    | `/trainers/`     | Get all trainers   |
| GET    | `/trainers/<id>` | Get trainer by ID  |
| POST   | `/trainers/`     | Create new trainer |
| PUT    | `/trainers/<id>` | Update trainer     |
| DELETE | `/trainers/<id>` | Delete trainer     |

---

## Courses

**Base Path:** `/courses`  
**Tag:** Courses  
**Description:** CRUD endpoint documentation for courses

| Method | Endpoint        | Description       |
| ------ | --------------- | ----------------- |
| GET    | `/courses/`     | Get all courses   |
| GET    | `/courses/<id>` | Get course by ID  |
| POST   | `/courses/`     | Create new course |
| PUT    | `/courses/<id>` | Update course     |
| DELETE | `/courses/<id>` | Delete course     |

---

## Course Modules

**Base Path:** `/courses-modules`  
**Tag:** Course Modules  
**Description:** CRUD for Course-Module Associations

| Method | Endpoint                | Description                          |
| ------ | ----------------------- | ------------------------------------ |
| GET    | `/courses-modules/`     | Get all course-module associations   |
| GET    | `/courses-modules/<id>` | Get course-module association by ID  |
| POST   | `/courses-modules/`     | Create new course-module association |
| PUT    | `/courses-modules/<id>` | Update course-module association     |
| DELETE | `/courses-modules/<id>` | Delete course-module association     |

---

## Classes

**Base Path:** `/classes`  
**Tag:** Classes  
**Description:** CRUD endpoint documentation for classes

| Method | Endpoint        | Description      |
| ------ | --------------- | ---------------- |
| GET    | `/classes/`     | Get all classes  |
| GET    | `/classes/<id>` | Get class by ID  |
| POST   | `/classes/`     | Create new class |
| PUT    | `/classes/<id>` | Update class     |
| DELETE | `/classes/<id>` | Delete class     |

---

## Class Modules

**Base Path:** `/classes-modules`  
**Tag:** ClassModules  
**Description:** CRUD for class modules

| Method | Endpoint                | Description             |
| ------ | ----------------------- | ----------------------- |
| GET    | `/classes-modules/`     | Get all class modules   |
| GET    | `/classes-modules/<id>` | Get class module by ID  |
| POST   | `/classes-modules/`     | Create new class module |
| PUT    | `/classes-modules/<id>` | Update class module     |
| DELETE | `/classes-modules/<id>` | Delete class module     |

---

## Modules

**Base Path:** `/modules`  
**Tag:** Modules  
**Description:** CRUD endpoint documentation for modules

| Method | Endpoint        | Description       |
| ------ | --------------- | ----------------- |
| GET    | `/modules/`     | Get all modules   |
| GET    | `/modules/<id>` | Get module by ID  |
| POST   | `/modules/`     | Create new module |
| PUT    | `/modules/<id>` | Update module     |
| DELETE | `/modules/<id>` | Delete module     |

---

## Enrollments

**Base Path:** `/enrollments`  
**Tag:** Enrollments  
**Description:** CRUD for enrollments

| Method | Endpoint            | Description           |
| ------ | ------------------- | --------------------- |
| GET    | `/enrollments/`     | Get all enrollments   |
| GET    | `/enrollments/<id>` | Get enrollment by ID  |
| POST   | `/enrollments/`     | Create new enrollment |
| PUT    | `/enrollments/<id>` | Update enrollment     |
| DELETE | `/enrollments/<id>` | Delete enrollment     |

---

## Grades

**Base Path:** `/grades`  
**Tag:** Grades  
**Description:** CRUD for grades

| Method | Endpoint       | Description      |
| ------ | -------------- | ---------------- |
| GET    | `/grades/`     | Get all grades   |
| GET    | `/grades/<id>` | Get grade by ID  |
| POST   | `/grades/`     | Create new grade |
| PUT    | `/grades/<id>` | Update grade     |
| DELETE | `/grades/<id>` | Delete grade     |

---

## Schedules

**Base Path:** `/schedules`  
**Tag:** Schedules  
**Description:** CRUD for schedules

| Method | Endpoint          | Description         |
| ------ | ----------------- | ------------------- |
| GET    | `/schedules/`     | Get all schedules   |
| GET    | `/schedules/<id>` | Get schedule by ID  |
| POST   | `/schedules/`     | Create new schedule |
| PUT    | `/schedules/<id>` | Update schedule     |
| DELETE | `/schedules/<id>` | Delete schedule     |

---

## Rooms

**Base Path:** `/rooms`  
**Tag:** Rooms  
**Description:** CRUD endpoint documentation for rooms

| Method | Endpoint      | Description     |
| ------ | ------------- | --------------- |
| GET    | `/rooms/`     | Get all rooms   |
| GET    | `/rooms/<id>` | Get room by ID  |
| POST   | `/rooms/`     | Create new room |
| PUT    | `/rooms/<id>` | Update room     |
| DELETE | `/rooms/<id>` | Delete room     |

---

## Availabilities

**Base Path:** `/availabilities`  
**Tag:** Availabilities  
**Description:** CRUD for availabilities

| Method | Endpoint               | Description             |
| ------ | ---------------------- | ----------------------- |
| GET    | `/availabilities/`     | Get all availabilities  |
| GET    | `/availabilities/<id>` | Get availability by ID  |
| POST   | `/availabilities/`     | Create new availability |
| PUT    | `/availabilities/<id>` | Update availability     |
| DELETE | `/availabilities/<id>` | Delete availability     |

---

## Documents

**Base Path:** `/documents`  
**Tag:** Document  
**Description:** Document management endpoints

| Method | Endpoint                                | Description                                   |
| ------ | --------------------------------------- | --------------------------------------------- |
| POST   | `/documents/upload/trainer/<trainerId>` | Upload file for trainer (multipart/form-data) |
| POST   | `/documents/upload/trainee/<traineeId>` | Upload file for trainee (multipart/form-data) |

---

## Email

**Base Path:** `/email`  
**Tag:** Email

| Method | Endpoint      | Description |
| ------ | ------------- | ----------- |
| POST   | `/email/send` | Send email  |

**Request Body:**

```json
{
  "to": "recipient@example.com",
  "subject": "Email Subject",
  "body": "Email HTML body"
}
```

---

## Chat

**Base Path:** `/chat`  
**Tag:** Chat

| Method    | Endpoint | Description                                  |
| --------- | -------- | -------------------------------------------- |
| WebSocket | `/chat/` | WebSocket connection for real-time messaging |

**Commands:**

- `@enterroom <roomName>` - Join a chat room
- `@leaveroom <roomName>` - Leave a chat room
- `@changename <newName>` - Change your display name
- Send message text - Broadcast to current rooms

---

## Standard Response Format

All endpoints return responses in the following format:

```json
{
  "success": true,
  "data": {},
  "error": null,
  "timestamp": "2026-01-30T00:00:00Z"
}
```

---

## Error Handling

Errors are returned with appropriate HTTP status codes:

- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

---

## Authentication

Some endpoints require authentication via:

- **Cookie Session:** Pass `cookie` header with session token
- **Query Parameters:** Pass `otp` as query parameter for OTP verification

---

## File Upload

Document endpoints support multipart/form-data uploads:

- **Field Name:** `file`
- **Upload Path:** Files are stored in `public/uploads/trainers/{trainerId}` or `public/uploads/trainees/{traineeId}`
- **File Naming:** Files are renamed with UUID prefix to ensure uniqueness
