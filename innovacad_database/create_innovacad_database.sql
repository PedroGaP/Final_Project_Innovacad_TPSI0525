CREATE DATABASE IF NOT EXISTS innovacad_tpsi0525;

USE innovacad_tpsi0525;

CREATE TABLE IF NOT EXISTS trainers
(
    trainer_id     VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    user_id        VARCHAR(36) NOT NULL,
    birthday_date  TIMESTAMP,
    specialization TEXT,
    INDEX idx_trainer_user (user_id),
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trainees
(
    trainee_id    VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    user_id       VARCHAR(36) NOT NULL,
    birthday_date TIMESTAMP,
    INDEX idx_trainee_user (user_id), -- Faster lookups
    FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
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
    location             VARCHAR(6)        NOT NULL,
    identifier           VARCHAR(4) UNIQUE NOT NULL,
    status               ENUM ('ongoing', 'finished', 'starting') DEFAULT 'starting',
    start_date_timestamp TIMESTAMP         NOT NULL,
    end_date_timestamp   TIMESTAMP         NOT NULL,
    INDEX idx_class_course (course_id), -- Optimization for course listings
    FOREIGN KEY (course_id) REFERENCES courses (course_id)
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

CREATE TABLE IF NOT EXISTS rooms
(
    room_id        INT PRIMARY KEY AUTO_INCREMENT,
    room_name      VARCHAR(10) UNIQUE NOT NULL,
    capacity       INT                NOT NULL,
    has_computers  BOOL               NOT NULL DEFAULT FALSE,
    has_projector  BOOL               NOT NULL DEFAULT FALSE,
    has_whiteboard BOOL               NOT NULL DEFAULT FALSE,
    has_smartboard BOOL               NOT NULL DEFAULT FALSE
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
    INDEX idx_grade_trainee (trainee_id), -- Crucial for "get my grades" queries
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON DELETE CASCADE,
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON DELETE CASCADE
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
    INDEX idx_avail_date (date_day), -- Speeds up finding free trainers for a day
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_number) REFERENCES ref_slots (slot_number),
    UNIQUE KEY unique_trainer_slot (trainer_id, date_day, slot_number)
);

CREATE TABLE IF NOT EXISTS schedules
(
    schedule_id     VARCHAR(36)   DEFAULT (UUID()) PRIMARY KEY,
    class_module_id VARCHAR(36) NOT NULL,
    trainer_id      VARCHAR(36) NOT NULL,
    room_id         INT,
    is_online       BOOLEAN       DEFAULT FALSE,
    regime_type     TINYINT(1)    DEFAULT 0,
    total_hours     DECIMAL(4, 2) DEFAULT 6.0,
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sched_trainer (trainer_id),
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON UPDATE CASCADE ON DELETE CASCADE,
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
    FOREIGN KEY (schedule_id) REFERENCES schedules (schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (availability_id) REFERENCES availabilities (availability_id)
);

CREATE TABLE IF NOT EXISTS enrollments
(
    enrollment_id VARCHAR(36)   DEFAULT (UUID()) PRIMARY KEY,
    class_id      VARCHAR(36) NOT NULL,
    trainee_id    VARCHAR(36) NOT NULL,
    final_grade   DECIMAL(4, 2) DEFAULT 0.00,
    UNIQUE (class_id, trainee_id),
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE,
    FOREIGN KEY (trainee_id) REFERENCES trainees (trainee_id) ON DELETE CASCADE
);

-- Create indexes
-- Optimizes searching for lessons by date
-- CREATE INDEX idx_schedules_period ON schedules (start_date_timestamp, end_date_timestamp);

-- Optimizes searching for trainer availability by date
-- CREATE INDEX idx_availabilities_period ON availabilities (start_date_timestamp, end_date_timestamp);

-- Optimizes availability filtering by status
-- CREATE INDEX idx_availabilities_status ON availabilities (status);

-- Optimizes listing a course's modules
-- CREATE INDEX idx_courses_modules_course ON courses_modules (course_id);

-- Optimizes listing a class's trainees
-- CREATE INDEX idx_enrollments_class ON enrollments (class_id);