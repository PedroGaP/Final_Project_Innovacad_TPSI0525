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

select *
from trainers_classes_coordinator;

-- Queries estatisticas

SELECT status,
       COUNT(*) AS total
FROM classes
WHERE status IN ('finished', 'ongoing')
GROUP BY status;

SELECT COUNT(DISTINCT e.trainee_id) AS trainees_currently_active
FROM enrollments e
         JOIN classes c ON e.class_id = c.class_id
WHERE c.status = 'ongoing';

SELECT area,
       COUNT(course_id) AS courses_count
FROM courses
GROUP BY area
ORDER BY courses_count DESC;

SELECT t.trainer_id,
       u.name,
       SUM(s.total_hours) AS total_hours_taught
FROM trainers t
         JOIN user u ON t.user_id = u.id
         JOIN schedules s ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, u.name
ORDER BY total_hours_taught DESC
LIMIT 10;

ALTER TABLE courses_modules ADD INDEX idx_courses_modules_id (courses_modules_id);

INSERT INTO availabilities (availability_id, trainer_id, date_day, slot_number, is_booked)
VALUES
(UUID(), 'bd4f8ba4-9b4a-4803-abc6-1033caee7708', '2026-02-09 00:00:00', 7, 0),
(UUID(), 'bd4f8ba4-9b4a-4803-abc6-1033caee7708', '2026-02-09 00:00:00', 8, 0);

SELECT
            s.schedule_id,
            IF(s.regime_type = 0, 'daytime', 'post-work') AS regime_type,
            m.name AS module_name,
            u.name AS trainer_name,
            t.trainer_id as trainer_id,
            u.email as trainer_email,
            s.start_date_timestamp,
            s.end_date_timestamp,
            IF(s.is_online, 'online', r.room_name) AS room_name,
            s.class_module_id, s.trainer_id, s.room_id, s.is_online, s.regime_type, s.total_hours,
            CONCAT(co.identifier, ' ', c.location, ' ', c.identifier) AS class_name,
            classm.current_duration AS current_duration,
            m.duration AS total_duration
          FROM schedules s
          JOIN classes_modules classm ON s.class_module_id = classm.classes_modules_id
          JOIN courses_modules coursem ON classm.courses_modules_id = coursem.courses_modules_id
          JOIN modules m ON coursem.module_id = m.module_id
          JOIN trainers t ON s.trainer_id = t.trainer_id
          JOIN user u ON t.user_id = u.id
          JOIN classes c ON classm.class_id = c.class_id
          JOIN courses co ON c.course_id = co.course_id
          LEFT JOIN rooms r ON s.room_id = r.room_id
          WHERE
            -- CONDIÇÃO A: O utilizador logado é o formador desta aula
            t.user_id = 's5NX2s4KT2jtapx63krAm7JsQKi9W7vZ'
            OR
            -- CONDIÇÃO B: O utilizador logado está inscrito nesta turma como aluno
            classm.class_id IN (
              SELECT e.class_id
              FROM enrollments e
              JOIN trainees tr ON e.trainee_id = tr.trainee_id
              WHERE tr.user_id = 's5NX2s4KT2jtapx63krAm7JsQKi9W7vZ'
            )
          ORDER BY s.start_date_timestamp ASC