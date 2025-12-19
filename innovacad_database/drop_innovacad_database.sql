use innovacad_tpsi0525;

-- Comment this to not DELETE Better Auth API Tables

/*
DELETE FROM user WHERE 1;
DELETE FROM session WHERE 1;
DELETE FROM account WHERE 1;
DELETE FROM verification WHERE 1;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE user;
DROP TABLE session;
DROP TABLE account;
DROP TABLE verification;
SET FOREIGN_KEY_CHECKS = 1;
*/

DELETE FROM classes_modules WHERE 1;
DELETE FROM schedules WHERE 1;
DELETE FROM availabilities WHERE 1;
DELETE FROM enrollments WHERE 1;
DELETE FROM rooms WHERE 1;
DELETE FROM classes where 1;
DELETE FROM courses WHERE 1;

-- Disable foreign key checks temporarily so we avoid the issue where it can't be removed because it references itself on `sequence_module_id` column
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM modules WHERE 1;
SET FOREIGN_KEY_CHECKS = 1;

DELETE FROM trainers where 1;
DELETE FROM trainees where 1;

DROP TABLE classes_modules;
DROP TABLE schedules;
DROP TABLE availabilities;
DROP TABLE enrollments;
DROP TABLE rooms;
DROP TABLE classes;
DROP TABLE courses;
DROP TABLE modules;
DROP TABLE trainers;
DROP TABLE trainees;

-- Executing this command will also remove Better Auth API tables.
-- drop database innovacad_tpsi0525;