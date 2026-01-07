-- Get current unix_timestamp
Select UNIX_TIMESTAMP();

-- Get current unix_timestamp and add one year to it
Select UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- Get all users
Select *
from user;

-- Get all from account
Select *
from account;

-- Get all trainers
Select *
from trainers;

-- Get all trainees
Select *
from trainees;

-- Get all from courses
Select *
from courses;

-- Get all from modules
Select *
from modules;

-- Get all from classes
Select *
from classes;

-- Get all from rooms
Select *
from rooms;

-- Get all from classes_modules
Select *
from classes_modules;

-- Get all from schedules
Select *
from schedules;

-- Get all from availabilities
Select *
from availabilities;

-- Get all from enrollments
Select *
from enrollments;

-- Get trainer schedules
Select * from schedules where trainer_id = '60dcc0e4-7935-4472-8c9d-0f739b1ce68e';