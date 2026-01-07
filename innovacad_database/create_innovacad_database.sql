CREATE DATABASE IF NOT EXISTS innovacad_tpsi0525;
USE innovacad_tpsi0525;

create table IF NOT EXISTS trainers
(
    trainer_id    varchar(36) default UUID() primary key,
    user_id       varchar(36)         not null,
    first_name    varchar(24)         not null,
    last_name     varchar(24)         not null,
    email         varchar(256) unique not null,
    username      varchar(32) unique  not null,
    birthday_date int(11),
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

create table IF NOT EXISTS trainees
(
    trainee_id    varchar(36) default UUID() primary key,
    user_id       varchar(36)         not null,
    first_name    varchar(24)         not null,
    last_name     varchar(24)         not null,
    email         varchar(256) unique not null,
    username      varchar(32) unique  not null,
    birthday_date int(11),
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

create table IF NOT EXISTS courses
(
    course_id  varchar(36) default UUID() primary key,
    identifier varchar(8)  not null, -- TPSI, CISEG, GRSI...
    name       varchar(64) not null
);

create table IF NOT EXISTS classes
(
    class_id             varchar(36)                              default UUID() primary key,
    course_id            varchar(36)       not null,
    location             varchar(6)        not null, -- PAL, CAS...
    identifier           varchar(4) unique not null, -- 0525
    status               ENUM ('ongoing', 'finished', 'starting') default 'starting',
    start_date_timestamp int(11)           not null,
    end_date_timestamp   int(11)           not null,
    FOREIGN KEY (course_id) REFERENCES courses (course_id)
);

create table IF NOT EXISTS modules
(
    module_id          varchar(36) default UUID() primary key,
    name               varchar(64) unique not null,
    duration           int(3)             not null,
    sequence_module_id varchar(36)        null,
    FOREIGN KEY (sequence_module_id) REFERENCES modules (module_id)
);

create table IF NOT EXISTS rooms
(
    room_id  varchar(6) default '0.00-A' primary key,
    capacity int not null
);

create table IF NOT EXISTS schedules
(
    schedule_id          varchar(36) default UUID() primary key,
    class_id             varchar(36) not null,
    module_id            varchar(36) not null,
    trainer_id           varchar(36) not null,
    room_id              varchar(6),
    online               boolean     default false,
    start_date_timestamp int(11)     not null,
    end_date_timestamp   int(11)     not null,
    FOREIGN KEY (class_id) REFERENCES classes (class_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id),
    FOREIGN KEY (room_id) REFERENCES rooms (room_id)
);

create table IF NOT EXISTS availabilities
(
    availability_id      varchar(36) default UUID() primary key,
    trainer_id           varchar(36) not null,
    start_date_timestamp int(11)     not null,
    end_date_timestamp   int(11)     not null
);

create table IF NOT EXISTS enrollments
(
    enrollment_id varchar(36)   default UUID() primary key,
    class_id      varchar(36) not null,
    trainee_id    varchar(36) not null,
    final_grade   decimal(4, 2) default 00.00,
    FOREIGN KEY (class_id) REFERENCES classes (class_id),
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id)
);

create table IF NOT EXISTS classes_modules
(
    class_id         varchar(36) not null,
    module_id        varchar(36) not null,
    current_duration int(3) default 0,
    FOREIGN KEY (class_id) REFERENCES classes (class_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id)
);

create table IF NOT EXISTS grades
(
    grade_id varchar(36) default UUID() primary key,
    trainee_id varchar(36) not null,
    class_id varchar(36) not null,
    module_id varchar(36) not null,
    final_grade decimal(4,2) default 00.00,
    FOREIGN KEY (trainee_id) REFERENCES trainees(trainee_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (module_id) REFERENCES modules(module_id)
);
