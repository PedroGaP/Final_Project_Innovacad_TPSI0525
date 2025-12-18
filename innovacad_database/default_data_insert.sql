insert into user(id, name, email, emailVerified)
values ('77ab8510-dc5c-11f0-bdbd-98eecb87bc27', 'pedroga', 'pedroga@trainers.innovacad.pt', true),
       ('77ab88c7-dc5c-11f0-bdbd-98eecb87bc27', 'filipej', 'filipej@trainers.innovacad.pt', true),
       ('77ab8a26-dc5c-11f0-bdbd-98eecb87bc27', 'beatrizr', 'beatriz@trainees.innovacad.pt', false);

insert into trainers(trainer_id, user_id, first_name, last_name, email, username, birthday_date)
values ('60dcc0e4-7935-4472-8c9d-0f739b1ce68e', '77ab8510-dc5c-11f0-bdbd-98eecb87bc27', 'Pedro', 'Guerra',
        'pedroga@trainers.innovacad.pt', 'pedroga', NOW()),
       ('28793aef-c6db-413d-9adc-3d1375897cfa', '77ab88c7-dc5c-11f0-bdbd-98eecb87bc27', 'Filipe', 'Junqueiro',
        'filipej@trainers.innovacad.pt', 'filipej', NOW());

insert into trainees(trainee_id, user_id, first_name, last_name, email, username, birthday_date)
values ('b332fc2c-832a-4d33-8f2f-139d733be9f7', '77ab8a26-dc5c-11f0-bdbd-98eecb87bc27', 'Beatriz', 'Rodrigues',
        'beatrizr@trainees.innovacad.pt', 'beatrizr', NOW());

insert into courses(course_id, identifier, name, status)
values ('f51d8cb3-a446-4b24-912e-504b9bcf0a61', 'TPSI', 'Técnico/a Programador de Sistemas Informáticos', 'ongoing'),
       ('2d2bf12c-2955-4cb8-8cac-1fdd4f464839', 'CISEG', 'Técnico/a Especialista de Cibersegurança', 'starting');

insert into modules(module_id, name, duration, sequence_module_id)
values ('aae85310-2af2-42b8-8dfb-17f3e0073f2b', 'Análise de vulnerabilidades - iniciação', 50,
        '137a62bd-9a47-4b79-ae1a-419d6e16db0c'),
       ('137a62bd-9a47-4b79-ae1a-419d6e16db0c', 'Análise de vulnerabilidades – desenvolvimento', 50, null),
       ('87969f59-1016-44ae-903f-a5593530cedb', 'Programação em SQL', 25, null),
       ('4b9150b0-b2b2-4358-9fcd-4667a7599f71', ' 	Programação para a WEB - servidor (server-side)', 50, null);

insert into classes(class_id, course_id, location, identifier, start_date_timestamp, end_date_timestamp)
values ('74a05d40-8e0d-4b52-9537-eb41dcb61100', 'f51d8cb3-a446-4b24-912e-504b9bcf0a61', 'PAL', '0525', NOW(),
        NOW() + (365 * 24 * 3600)),
       ('14100964-b06f-4423-b57f-0b545e3dc802', '2d2bf12c-2955-4cb8-8cac-1fdd4f464839', 'CAS', '0926', NOW(),
        NOW() + (365 * 24 * 3600));

insert into classes_modules
values ('74a05d40-8e0d-4b52-9537-eb41dcb61100', '87969f59-1016-44ae-903f-a5593530cedb', 25),
       ('14100964-b06f-4423-b57f-0b545e3dc802', 'aae85310-2af2-42b8-8dfb-17f3e0073f2b', 27);