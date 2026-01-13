CREATE DATABASE IF NOT EXISTS innovacad_tpsi0525;
USE innovacad_tpsi0525;

create table IF NOT EXISTS trainers
(
    trainer_id     varchar(36) default UUID() primary key,
    user_id        varchar(36) not null,
    -- first_name    varchar(24)         not null,
    -- last_name     varchar(24)         not null,
    -- email         varchar(256) unique not null,
    -- username      varchar(32) unique  not null,
    birthday_date  timestamp,
    specialization TEXT,
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

create table IF NOT EXISTS trainees
(
    trainee_id    varchar(36) default UUID() primary key,
    user_id       varchar(36) not null,
    -- first_name    varchar(24)         not null,
    -- last_name     varchar(24)         not null,
    -- email         varchar(256) unique not null,
    -- username      varchar(32) unique  not null,
    birthday_date timestamp,
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
    start_date_timestamp timestamp         not null,
    end_date_timestamp   timestamp         not null,
    FOREIGN KEY (course_id) REFERENCES courses (course_id)
);

create table IF NOT EXISTS modules
(
    module_id          varchar(36) default UUID() primary key,
    name               varchar(64) unique not null,
    duration           int(3)             not null
);

create table IF NOT EXISTS rooms
(
    room_id   int primary key auto_increment,
    room_name varchar(10) unique not null,
    capacity  int                not null
);

create table IF NOT EXISTS courses_modules
(
    courses_modules_id        varchar(36) default UUID() primary key,
    course_id                 varchar(36) not null,
    module_id                 varchar(36) not null,
    sequence_course_module_id varchar(36),
    UNIQUE (course_id, module_id),
    FOREIGN KEY (course_id) REFERENCES courses (course_id),
    FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (sequence_course_module_id) REFERENCES courses_modules(courses_modules_id)
);

create table IF NOT EXISTS classes_modules
(
    classes_modules_id varchar(36) not null primary key,
    class_id           varchar(36) not null,
    courses_modules_id varchar(36) not null,
    current_duration   int(3) default 0,
    UNIQUE (class_id, courses_modules_id),
    FOREIGN KEY (class_id) REFERENCES classes (class_id),
    FOREIGN KEY (courses_modules_id) REFERENCES courses_modules (courses_modules_id)
);

create table IF NOT EXISTS grades
(
    grade_id        varchar(36)                           default UUID() primary key,
    class_module_id varchar(36)                  not null,
    trainee_id      varchar(36)                  not null,
    grade           decimal(4, 2)                not null,
    grade_type      enum ('final', 'assessment') not null default 'assessment',
    created_at      TIMESTAMP                             DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP                             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (trainee_id, class_module_id, grade_type),
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON DELETE CASCADE,
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON DELETE CASCADE
);

create table IF NOT EXISTS availabilities
(
    availability_id      varchar(36)                             default UUID() primary key,
    trainer_id           varchar(36)                    not null,
    status               ENUM ('free','partial','full') not null default 'free',
    start_date_timestamp timestamp                      not null,
    end_date_timestamp   timestamp                      not null,
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE CASCADE
);

create table IF NOT EXISTS schedules
(
    schedule_id          varchar(36) default UUID() primary key,
    -- class_id             varchar(36) not null,
    -- module_id            varchar(36) not null,
    class_module_id      varchar(36) not null,
    trainer_id           varchar(36) not null,
    availability_id      varchar(36) not null,
    room_id              int,
    online               boolean     default false,
    start_date_timestamp timestamp   not null,
    end_date_timestamp   timestamp   not null,
    -- FOREIGN KEY (class_id) REFERENCES classes (class_id),
    -- FOREIGN KEY (module_id) REFERENCES modules (module_id),
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms (room_id),
    FOREIGN KEY (availability_id) REFERENCES availabilities (availability_id)
);

create table IF NOT EXISTS enrollments
(
    enrollment_id varchar(36)   default UUID() primary key,
    class_id      varchar(36) not null,
    trainee_id    varchar(36) not null,
    final_grade   decimal(4, 2) default 00.00,
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON DELETE CASCADE
);

-- Create indexes
-- Optimizes searching for lessons by date
CREATE INDEX idx_schedules_period ON schedules (start_date_timestamp, end_date_timestamp);

-- Optimizes searching for trainer availability by date
CREATE INDEX idx_availabilities_period ON availabilities (start_date_timestamp, end_date_timestamp);

-- Optimizes availability filtering by status
CREATE INDEX idx_availabilities_status ON availabilities (status);

-- Optimizes listing a course's modules
CREATE INDEX idx_courses_modules_course ON courses_modules (course_id);

-- Optimizes listing a class's trainees
CREATE INDEX idx_enrollments_class ON enrollments (class_id);
