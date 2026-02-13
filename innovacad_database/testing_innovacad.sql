SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE schedule_slots;
TRUNCATE TABLE schedules;
TRUNCATE TABLE availabilities;
TRUNCATE TABLE enrollments;
TRUNCATE TABLE grades;
TRUNCATE TABLE trainers_classes_coordinator;
TRUNCATE TABLE classes_modules;
TRUNCATE TABLE classes;
TRUNCATE TABLE courses_modules;
TRUNCATE TABLE courses;
TRUNCATE TABLE trainer_skills;
TRUNCATE TABLE modules;
TRUNCATE TABLE trainers;
TRUNCATE TABLE trainees;
TRUNCATE TABLE user;
TRUNCATE TABLE rooms;
TRUNCATE TABLE ref_slots;

SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

INSERT INTO ref_slots (slot_number, start_time, end_time) VALUES
(1, '08:00:00', '09:00:00'), (2, '09:00:00', '10:00:00'), (3, '10:00:00', '11:00:00'),
(4, '11:00:00', '12:00:00'), (5, '12:00:00', '13:00:00'), (6, '13:00:00', '14:00:00'),
(7, '14:00:00', '15:00:00'), (8, '15:00:00', '16:00:00'), (9, '16:00:00', '17:00:00'),
(10, '17:00:00', '18:00:00'), (11, '18:00:00', '19:00:00'), (12, '19:00:00', '20:00:00'),
(13, '20:00:00', '21:00:00'), (14, '21:00:00', '22:00:00'), (15, '22:00:00', '23:00:00');

INSERT INTO rooms (room_name, capacity, has_computers, has_projector, has_whiteboard) VALUES
('Sala 1.1', 25, 1, 1, 1),
('Sala 1.2', 30, 0, 1, 1),
('Auditório', 100, 0, 1, 0);

SET @uid_t1 = UUID();
SET @uid_t2 = UUID();
SET @uid_t3 = UUID();

INSERT INTO user (id, name, email, username, role, emailVerified, twoFactorEnabled, createdAt, updatedAt) VALUES
(@uid_t1, 'Ana SQL', 'ana.sql@test.com', 'anasql', 'trainer', 1, 0, NOW(), NOW()),
(@uid_t2, 'Bruno Java', 'bruno.java@test.com', 'brunoj', 'trainer', 1, 0, NOW(), NOW()),
(@uid_t3, 'Carlos Web', 'carlos.web@test.com', 'carlosw', 'trainer', 1, 0, NOW(), NOW());

INSERT INTO trainers (trainer_id, user_id, birthday_date) VALUES
(UUID(), @uid_t1, '1980-01-01'),
(UUID(), @uid_t2, '1985-05-20'),
(UUID(), @uid_t3, '1990-10-10');

SELECT trainer_id INTO @tid1 FROM trainers WHERE user_id = @uid_t1;
SELECT trainer_id INTO @tid2 FROM trainers WHERE user_id = @uid_t2;
SELECT trainer_id INTO @tid3 FROM trainers WHERE user_id = @uid_t3;

INSERT INTO modules (name, duration, has_computers, has_projector) VALUES
('SQL', 50, 1, 1),
('Java', 60, 1, 1),
('Web', 40, 1, 1);

SELECT module_id INTO @mod_sql FROM modules WHERE name = 'SQL';
SELECT module_id INTO @mod_java FROM modules WHERE name = 'Java';
SELECT module_id INTO @mod_web FROM modules WHERE name = 'Web';

SET @course_id = UUID();
INSERT INTO courses (course_id, identifier, name, area) VALUES (@course_id, 'TPSI0525', 'Programação', 'IT');

INSERT INTO courses_modules (course_id, module_id) VALUES
(@course_id, @mod_sql),
(@course_id, @mod_java),
(@course_id, @mod_web);

SELECT courses_modules_id INTO @cm_sql FROM courses_modules WHERE course_id = @course_id AND module_id = @mod_sql;
SELECT courses_modules_id INTO @cm_java FROM courses_modules WHERE course_id = @course_id AND module_id = @mod_java;
SELECT courses_modules_id INTO @cm_web FROM courses_modules WHERE course_id = @course_id AND module_id = @mod_web;

UPDATE courses_modules SET sequence_course_module_id = @cm_sql WHERE courses_modules_id = @cm_java;
UPDATE courses_modules SET sequence_course_module_id = @cm_java WHERE courses_modules_id = @cm_web;

INSERT INTO trainer_skills (trainer_id, module_id, competence_level) VALUES
(@tid1, @mod_sql, 2),
(@tid2, @mod_java, 2),
(@tid3, @mod_web, 2);

SET @class_id = UUID();
INSERT INTO classes (class_id, course_id, location, identifier, status, start_date_timestamp, end_date_timestamp) VALUES
(@class_id, @course_id, 'LX', 'TPSI1', 'ongoing', NOW(), DATE_ADD(NOW(), INTERVAL 6 MONTH));

INSERT INTO classes_modules (class_id, courses_modules_id, current_duration)
SELECT @class_id, courses_modules_id, 0 FROM courses_modules WHERE course_id = @course_id;

INSERT INTO availabilities (trainer_id, date_day, slot_number, is_booked)
SELECT
    t.trainer_id,
    DATE_ADD(CURDATE(), INTERVAL seq.n DAY),
    s.slot_number,
    0
FROM trainers t
CROSS JOIN (
    SELECT a.N + b.N * 10 + c.N * 100 AS n
    FROM
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a,
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b,
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    WHERE (a.N + b.N * 10 + c.N * 100) <= 365
) seq
CROSS JOIN ref_slots s
WHERE WEEKDAY(DATE_ADD(CURDATE(), INTERVAL seq.n DAY)) < 5;

COMMIT;

SELECT 'Dados gerados com sucesso!' as Status;
SELECT * FROM classes;
SELECT CONCAT('ID Turma para Payload: ', @class_id) as Info;
SELECT
    m.name as Module,
    cm.sequence_course_module_id as 'Depends On ID'
FROM courses_modules cm
JOIN modules m ON cm.module_id = m.module_id
WHERE cm.course_id = @course_id;