-- ==========================================================
-- TIME & DATE UTILS
-- ==========================================================
-- Get current Unix Timestamp
SELECT UNIX_TIMESTAMP();

-- Get Unix Timestamp for 1 year from now (useful for setting class end dates)
SELECT UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- ==========================================================
-- CORE TABLE LISTING
-- ==========================================================
SELECT *
FROM user;

SELECT t.*, u.name, u.image, u.role, u.username, u.email, u.createdAt
from trainees t,
     user u
where t.user_id = u.id;

SELECT *
FROM account;
SELECT *
FROM trainers;
SELECT *
FROM trainees;
SELECT *
FROM courses;
SELECT *
FROM modules;
SELECT *
FROM classes;
SELECT *
FROM rooms;
SELECT *
FROM courses_modules; -- Course curriculum/structure
SELECT *
FROM classes_modules; -- Active modules assigned to specific classes
SELECT *
FROM schedules; -- Individual lesson calendar
SELECT *
FROM availabilities; -- Trainer time slots
SELECT *
FROM enrollments; -- Trainee-Class relationship
SELECT *
FROM grades;
-- Academic performance

-- ==========================================================
-- OPERATIONAL & LOGIC QUERIES
-- ==========================================================

-- Get a course curriculum (List all modules belonging to a specific course identifier)
SELECT c.identifier AS course, m.name AS module, m.duration
FROM courses_modules cm
         JOIN courses c ON cm.course_id = c.course_id
         JOIN modules m ON cm.module_id = m.module_id
WHERE c.identifier = 'TPSI';

-- Get a specific trainer's lesson schedule
SELECT *
FROM schedules
WHERE trainer_id = '60dcc0e4-7935-4472-8c9d-0f739b1ce68e';

-- Get a full class schedule (Lessons for all modules assigned to a specific class)
SELECT s.*
FROM schedules s
         JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
WHERE cm.class_id = '74a05d40-8e0d-4b52-9537-eb41dcb61100';

-- Get academic report (Grades per trainee and module with student names)
SELECT u.name AS trainee_name, g.grade, g.grade_type, m.name AS module_name
FROM grades g
         JOIN trainees t ON g.trainee_id = t.trainee_id
         JOIN user u ON t.user_id = u.id
         JOIN classes_modules cm ON g.class_module_id = cm.classes_modules_id
         JOIN courses_modules com ON cm.courses_modules_id = com.courses_modules_id
         JOIN modules m ON com.module_id = m.module_id;

-- List all "Free" time slots from trainers (Availability not yet fully booked)
SELECT u.name AS trainer_name, a.start_date_timestamp, a.end_date_timestamp
FROM availabilities a
         JOIN trainers t ON a.trainer_id = t.trainer_id
         JOIN user u ON t.user_id = u.id
WHERE a.status = 'free';

-- Check room occupancy (Active or upcoming lessons for a specific room)
SELECT s.*, r.room_name
FROM schedules s
         JOIN rooms r ON s.room_id = r.room_id
WHERE s.room_id = 1
  AND s.end_date_timestamp > NOW();

select *
from verification;
select *
from user;

describe innovacad_tpsi0525.classes_modules;

INSERT INTO `classes` (`course_id`, `location`, `identifier`, `status`, `start_date_timestamp`, `end_date_timestamp`)
VALUES ('834f65af-f8a1-11f0-adbc-e6c93dd26891', 'PAL', '0525', 'starting',' 2026-01-23T00:00:00.000', '2026-02-07T00:00:00.000');


 SELECT
          cm.courses_modules_id,
          cm.course_id,
          cm.module_id,
          cm.sequence_course_module_id,
          m.name AS module_name,
          m.duration
        FROM courses_modules cm
        INNER JOIN modules m ON cm.module_id = m.module_id;

select * from courses_modules;