USE innovacad_tpsi0525;


INSERT INTO ref_slots (slot_number, start_time, end_time) VALUES
(1, '08:00:00', '09:00:00'),
(2, '09:00:00', '10:00:00'),
(3, '10:00:00', '11:00:00'),
(4, '12:00:00', '13:00:00'),
(5, '13:00:00', '14:00:00'),
(6, '14:00:00', '15:00:00'),
(7, '16:00:00', '17:00:00'),
(8, '17:00:00', '18:00:00'),
(9, '18:00:00', '19:00:00'),
(10, '20:00:00', '21:00:00'),
(11, '21:00:00', '22:00:00'),
(12, '22:00:00', '23:00:00');

INSERT INTO document_types (code, label) VALUES
('CV', 'Curriculum Vitae'),
('DIPLOMA', 'Certificate/Diploma'),
('ID_CARD', 'Identification Document'),
('OTHER', 'Other Attachment');


INSERT INTO user (id, name, email, emailVerified, username, role) VALUES
('77ab8510-dc5c-11f0-bdbd-98eecb87bc27', 'Pedro Guerra', 'pedroga@trainers.innovacad.pt', true, 'pedroga2', 'trainer'),
('b7b1dc75-838d-476b-a4d0-28e5771f9f15', 'Filipe Junqueiro', 'filipej@trainers.innovacad.pt', true, 'filipej2', 'trainer'),
('68c8681a-ac3e-4e15-a590-0592cfc832b0', 'Beatriz Rodrigues', 'beatriz@trainees.innovacad.pt', false, 'beatrizr2', 'trainee');


INSERT INTO trainers (trainer_id, user_id, birthday_date) VALUES
('60dcc0e4-7935-4472-8c9d-0f739b1ce68e', '77ab8510-dc5c-11f0-bdbd-98eecb87bc27', '1985-05-15 00:00:00'),
('28793aef-c6db-413d-9adc-3d1375897cfa', 'b7b1dc75-838d-476b-a4d0-28e5771f9f15', '1990-08-20 00:00:00');

INSERT INTO trainees (trainee_id, user_id, birthday_date) VALUES
('b332fc2c-832a-4d33-8f2f-139d733be9f7', '68c8681a-ac3e-4e15-a590-0592cfc832b0', '2000-01-01 00:00:00');


INSERT INTO courses (course_id, identifier, name) VALUES
('f51d8cb3-a446-4b24-912e-504b9bcf0a61', 'TPSI', 'Técnico/a Programador de Sistemas Informáticos'),
('2d2bf12c-2955-4cb8-8cac-1fdd4f464839', 'CISEG', 'Técnico/a Especialista de Cibersegurança');

INSERT INTO modules (module_id, name, duration, has_computers) VALUES
('137a62bd-9a47-4b79-ae1a-419d6e16db0c', 'Análise de vulnerabilidades – desenvolvimento', 50, true),
('87969f59-1016-44ae-903f-a5593530cedb', 'Programação em SQL', 25, true),
('4b9150b0-b2b2-4358-9fcd-4667a7599f71', 'Programação para a WEB - servidor (server-side)', 50, true),
('8a1df6c2-a8d0-47c8-833f-ce121471c9be', 'Programação para a WEB - cliente (client-side)', 50, true);

INSERT INTO trainer_skills (trainer_id, module_id, competence_level) VALUES
('60dcc0e4-7935-4472-8c9d-0f739b1ce68e', '87969f59-1016-44ae-903f-a5593530cedb', 2),
('28793aef-c6db-413d-9adc-3d1375897cfa', '137a62bd-9a47-4b79-ae1a-419d6e16db0c', 2);

INSERT INTO courses_modules (courses_modules_id, course_id, module_id, sequence_course_module_id) VALUES
('58cbf337-ee44-4c3e-90c9-25b3638b8436', 'f51d8cb3-a446-4b24-912e-504b9bcf0a61', '87969f59-1016-44ae-903f-a5593530cedb', null),
('3c9b576c-37b9-4874-be3d-ae67aee195f8', 'f51d8cb3-a446-4b24-912e-504b9bcf0a61', '8a1df6c2-a8d0-47c8-833f-ce121471c9be', null),
('18c3c8af-bf40-4263-ac4c-dca733e59512', 'f51d8cb3-a446-4b24-912e-504b9bcf0a61', '4b9150b0-b2b2-4358-9fcd-4667a7599f71', '3c9b576c-37b9-4874-be3d-ae67aee195f8');

INSERT INTO classes (class_id, course_id, location, identifier, status, start_date_timestamp, end_date_timestamp) VALUES
('74a05d40-8e0d-4b52-9537-eb41dcb61100', 'f51d8cb3-a446-4b24-912e-504b9bcf0a61', 'PAL', '0525', 'ongoing', NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- A Turma 0525 está a ter o módulo de SQL agora
INSERT INTO classes_modules (classes_modules_id, class_id, courses_modules_id, current_duration) VALUES
('ef1fa2f8-e32c-4f6d-8e8f-20efd5710b34', '74a05d40-8e0d-4b52-9537-eb41dcb61100', '58cbf337-ee44-4c3e-90c9-25b3638b8436', 25);

INSERT INTO rooms (room_name, capacity, has_computers) VALUES
('0.22-A', 21, true),
('0.21-A', 21, true);

INSERT INTO enrollments (enrollment_id, class_id, trainee_id, final_grade) VALUES
('dc610ae2-0edb-4fae-a15c-de7a4324a850', '74a05d40-8e0d-4b52-9537-eb41dcb61100', 'b332fc2c-832a-4d33-8f2f-139d733be9f7', 0.00);


INSERT INTO availabilities (availability_id, trainer_id, date_day, slot_number, is_booked) VALUES
('c997addf-169b-4832-8219-c1d114c55c3f', '60dcc0e4-7935-4472-8c9d-0f739b1ce68e', CURDATE(), 1, 1);

INSERT INTO schedules (schedule_id, class_module_id, trainer_id, room_id, is_online) VALUES
('057e65f7-81ba-4964-8420-593e16a59bac', 'ef1fa2f8-e32c-4f6d-8e8f-20efd5710b34', '60dcc0e4-7935-4472-8c9d-0f739b1ce68e', 1, false);

INSERT INTO grades (class_module_id, trainee_id, grade, grade_type) VALUES
('ef1fa2f8-e32c-4f6d-8e8f-20efd5710b34', 'b332fc2c-832a-4d33-8f2f-139d733be9f7', 14.50, 'assessment'),
('ef1fa2f8-e32c-4f6d-8e8f-20efd5710b34', 'b332fc2c-832a-4d33-8f2f-139d733be9f7', 15.00, 'final');