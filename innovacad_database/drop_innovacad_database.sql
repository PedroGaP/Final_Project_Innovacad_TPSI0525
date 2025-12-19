use innovacad_tpsi0525;

-- Comment this to not delete Better Auth API Tables
Delete from user where 1;
-- Delete from session where 1;
-- Delete from account where 1;
-- Delete from jwks where 1;
-- Delete from verification where 1;

delete from classes_modules where 1;
delete from schedules where 1;
delete from availabilities where 1;
delete from enrollments where 1;
delete from rooms where 1;
delete from classes where 1;
delete from courses where 1;

-- Disable foreign key checks temporarily so we avoid the issue where it can't be removed because it references itself on `sequence_module_id` column
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM modules;
SET FOREIGN_KEY_CHECKS = 1;

delete from trainers where 1;
delete from trainees where 1;

drop table classes_modules;
drop table schedules;
drop table availabilities;
drop table enrollments;
drop table rooms;
drop table classes;
drop table courses;
drop table modules;
drop table trainers;
drop table trainees;

-- Executing this command will also remove Better Auth API tables.
-- drop database innovacad_tpsi0525;