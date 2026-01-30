CREATE DATABASE IF NOT EXISTS innovacad_tpsi0525;

USE innovacad_tpsi0525;

CREATE TABLE IF NOT EXISTS trainers
(
    trainer_id    VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    user_id       VARCHAR(36) NOT NULL,
    birthday_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trainees
(
    trainee_id    VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    user_id       VARCHAR(36) NOT NULL,
    birthday_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS courses
(
    course_id  VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    identifier VARCHAR(8)  NOT NULL,
    name       VARCHAR(64) NOT NULL,
    UNIQUE (identifier, name)
);

CREATE TABLE IF NOT EXISTS classes
(
    class_id             VARCHAR(36)                              DEFAULT (UUID()) PRIMARY KEY,
    course_id            VARCHAR(36)       NOT NULL,
    location             VARCHAR(6)        NOT NULL, -- PAL, CAS...
    identifier           VARCHAR(4) UNIQUE NOT NULL, -- 0525...
    status               ENUM ('ongoing', 'finished', 'starting') DEFAULT 'starting',
    start_date_timestamp TIMESTAMP         NOT NULL,
    end_date_timestamp   TIMESTAMP         NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses (course_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS modules
(
    module_id      VARCHAR(36)                 DEFAULT (UUID()) PRIMARY KEY,
    name           VARCHAR(64) UNIQUE NOT NULL,
    duration       INT(3)             NOT NULL,
    has_computers  BOOL               NOT NULL DEFAULT FALSE,
    has_projector  BOOL               NOT NULL DEFAULT FALSE,
    has_whiteboard BOOL               NOT NULL DEFAULT FALSE,
    has_smartboard BOOL               NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS trainer_skills
(
    trainer_id       VARCHAR(36),
    module_id        VARCHAR(36),
    competence_level TINYINT DEFAULT 1, -- 0: Basic, 1: Expert
    PRIMARY KEY (trainer_id, module_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules (module_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rooms
(
    room_id        INT PRIMARY KEY AUTO_INCREMENT,
    room_name      VARCHAR(10) UNIQUE NOT NULL,
    capacity       INT                NOT NULL,
    has_computers  BOOLEAN            NOT NULL DEFAULT FALSE,
    has_projector  BOOLEAN            NOT NULL DEFAULT FALSE,
    has_whiteboard BOOLEAN            NOT NULL DEFAULT FALSE,
    has_smartboard BOOLEAN            NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS courses_modules
(
    courses_modules_id        VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    course_id                 VARCHAR(36) NOT NULL,
    module_id                 VARCHAR(36) NOT NULL,
    sequence_course_module_id VARCHAR(36),
    UNIQUE (course_id, module_id),
    FOREIGN KEY (course_id) REFERENCES courses (course_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules (module_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (sequence_course_module_id) REFERENCES courses_modules (courses_modules_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS classes_modules
(
    classes_modules_id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    class_id           VARCHAR(36) NOT NULL,
    courses_modules_id VARCHAR(36) NOT NULL,
    current_duration   INT(3)      DEFAULT 0,
    UNIQUE (class_id, courses_modules_id),
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (courses_modules_id) REFERENCES courses_modules (courses_modules_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS grades
(
    grade_id        VARCHAR(36)                           DEFAULT (UUID()) PRIMARY KEY,
    class_module_id VARCHAR(36)                  NOT NULL,
    trainee_id      VARCHAR(36)                  NOT NULL,
    grade           DECIMAL(4, 2)                NOT NULL,
    grade_type      ENUM ('final', 'assessment') NOT NULL DEFAULT 'assessment',
    created_at      TIMESTAMP                             DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP                             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (trainee_id, class_module_id, grade_type),
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ref_slots
(
    slot_number TINYINT PRIMARY KEY,
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL
);

CREATE TABLE IF NOT EXISTS availabilities
(
    availability_id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    trainer_id      VARCHAR(36) NOT NULL,
    date_day        TIMESTAMP   NOT NULL,
    slot_number     TINYINT     NOT NULL,
    is_booked       TINYINT(1)  DEFAULT 0,
    UNIQUE KEY unique_trainer_slot (trainer_id, date_day, slot_number),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (slot_number) REFERENCES ref_slots (slot_number) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS schedules
(
    schedule_id     VARCHAR(36)   DEFAULT (UUID()) PRIMARY KEY,
    class_module_id VARCHAR(36) NOT NULL,
    trainer_id      VARCHAR(36) NOT NULL,
    room_id         INT,
    is_online       BOOLEAN       DEFAULT FALSE,
    regime_type     TINYINT(1)    DEFAULT 0, -- 0=daytime, 1=post-work
    total_hours     DECIMAL(4, 2) DEFAULT 6.0,
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (room_id) REFERENCES rooms (room_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS schedule_slots
(
    slot_id         VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    schedule_id     VARCHAR(36) NOT NULL,
    availability_id VARCHAR(36) NOT NULL,
    slot_status     TINYINT(1)  DEFAULT 0,
    created_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (availability_id),
    FOREIGN KEY (schedule_id) REFERENCES schedules (schedule_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (availability_id) REFERENCES availabilities (availability_id)
);

CREATE TABLE IF NOT EXISTS enrollments
(
    enrollment_id VARCHAR(36)   DEFAULT (UUID()) PRIMARY KEY,
    class_id      VARCHAR(36) NOT NULL,
    trainee_id    VARCHAR(36) NOT NULL,
    final_grade   DECIMAL(4, 2) DEFAULT 0.00,
    UNIQUE (class_id, trainee_id),
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trainer_skills
(
    trainer_id       VARCHAR(36),
    module_id        VARCHAR(36),
    competence_level TINYINT DEFAULT 1, -- 1=Básico, 2=Expert
    PRIMARY KEY (trainer_id, module_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules (module_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS document_types
(
    code  VARCHAR(20) PRIMARY KEY,
    label VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS documents
(
    document_id     VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    file_name       VARCHAR(255) NOT NULL,
    file_path       VARCHAR(512) NOT NULL,
    mime_type       VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT       NOT NULL,
    type_code       VARCHAR(20)  NOT NULL,
    user_id         VARCHAR(36)  NOT NULL,
    created_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (type_code) REFERENCES document_types (code),
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

CREATE INDEX idx_trainer_user ON trainers (user_id);

CREATE INDEX idx_trainee_user ON trainees (user_id);

CREATE INDEX idx_class_course ON classes (course_id);

CREATE INDEX idx_grade_trainee ON grades (trainee_id);

CREATE INDEX idx_sched_trainer ON schedules (trainer_id);

CREATE INDEX idx_skills_module ON trainer_skills (module_id);

CREATE INDEX idx_avail_lookup ON availabilities (date_day, slot_number, is_booked);

CREATE INDEX idx_sched_room_lookup ON schedules (room_id);

CREATE INDEX idx_slots_sched_avail ON schedule_slots (schedule_id, availability_id);