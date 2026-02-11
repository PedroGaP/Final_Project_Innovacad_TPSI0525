CREATE DATABASE IF NOT EXISTS innovacad_tpsi0525;

USE innovacad_tpsi0525;

CREATE TABLE IF NOT EXISTS user
(
    id                   VARCHAR(36)  NOT NULL PRIMARY KEY,
    name                 VARCHAR(255) NOT NULL,
    email                VARCHAR(255) NOT NULL UNIQUE,
    emailVerified        BOOLEAN      NOT NULL DEFAULT FALSE,
    image                VARCHAR(255),
    createdAt            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    role                 VARCHAR(50),
    banned               BOOLEAN      NOT NULL DEFAULT FALSE,
    banReason            TEXT,
    banExpires           TIMESTAMP,
    username             VARCHAR(50) UNIQUE,
    displayUsername      VARCHAR(50),
    twoFactorEnabled     BOOLEAN      NOT NULL DEFAULT FALSE,
    twoFactorSecret      TEXT,
    twoFactorBackupCodes TEXT,
    twoFactorRedirect    BOOLEAN               DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS session
(
    id             VARCHAR(36)  NOT NULL PRIMARY KEY,
    expiresAt      TIMESTAMP    NOT NULL,
    token          VARCHAR(255) NOT NULL UNIQUE,
    createdAt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ipAddress      VARCHAR(45),
    userAgent      TEXT,
    userId         VARCHAR(36)  NOT NULL,
    impersonatedBy VARCHAR(36),
    FOREIGN KEY (userId) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS account
(
    id                    VARCHAR(36)  NOT NULL PRIMARY KEY,
    accountId             VARCHAR(255) NOT NULL,
    providerId            VARCHAR(255) NOT NULL,
    userId                VARCHAR(36)  NOT NULL,
    accessToken           TEXT,
    refreshToken          TEXT,
    idToken               TEXT,
    accessTokenExpiresAt  TIMESTAMP,
    refreshTokenExpiresAt TIMESTAMP,
    scope                 TEXT,
    password              TEXT,
    createdAt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS verification
(
    id         VARCHAR(36) NOT NULL PRIMARY KEY,
    identifier TEXT        NOT NULL,
    value      TEXT        NOT NULL,
    expiresAt  TIMESTAMP   NOT NULL,
    createdAt  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS trainers
(
    trainer_id     VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    user_id        VARCHAR(36) NOT NULL,
    birthday_date  TIMESTAMP,
    is_coordinator TINYINT(1)  DEFAULT 0,
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
    identifier VARCHAR(8)   NOT NULL,
    name       VARCHAR(128) NOT NULL,
    area       varchar(64)  not null,
    UNIQUE (identifier, name)
);

CREATE TABLE IF NOT EXISTS classes
(
    class_id             VARCHAR(36)                              DEFAULT (UUID()) PRIMARY KEY,
    course_id            VARCHAR(36)        NOT NULL,
    location             VARCHAR(6)         NOT NULL,
    identifier           VARCHAR(20) UNIQUE NOT NULL,
    status               ENUM ('ongoing', 'finished', 'starting') DEFAULT 'starting',
    start_date_timestamp TIMESTAMP          NOT NULL,
    end_date_timestamp   TIMESTAMP          NOT NULL,
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
    competence_level TINYINT DEFAULT 1,
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
    trainer_id         CHAR(36)    NULL,
    UNIQUE (class_id, courses_modules_id),
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (courses_modules_id) REFERENCES courses_modules (courses_modules_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS grades
(
    grade_id        VARCHAR(36)                                                       DEFAULT (UUID()) PRIMARY KEY,
    class_module_id VARCHAR(36)                                              NOT NULL,
    trainee_id      VARCHAR(36)                                              NOT NULL,
    grade           DECIMAL(4, 2)                                            NOT NULL,
    grade_type      ENUM ('attendance', 'behavior', 'work', 'test', 'final') NOT NULL DEFAULT 'work',
    status          ENUM ('draft', 'finalized')                              NOT NULL DEFAULT 'draft',
    created_at      TIMESTAMP                                                         DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP                                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
    schedule_id          VARCHAR(36)   DEFAULT (UUID()) PRIMARY KEY,
    class_module_id      VARCHAR(36) NOT NULL,
    trainer_id           VARCHAR(36) NOT NULL,
    room_id              INT,
    is_online            BOOLEAN       DEFAULT FALSE,
    regime_type          TINYINT(1)    DEFAULT 0,
    total_hours          DECIMAL(4, 2) DEFAULT 6.0,
    created_at           TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    start_date_timestamp TIMESTAMP   NOT NULL,
    end_date_timestamp   TIMESTAMP   NOT NULL,
    FOREIGN KEY (class_module_id) REFERENCES classes_modules (classes_modules_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (room_id) REFERENCES rooms (room_id) ON UPDATE CASCADE ON DELETE SET NULL
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

CREATE TABLE IF NOT EXISTS trainers_classes_coordinator
(
    trainers_classes_coordinator_id VARCHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    trainer_id                      VARCHAR(36) NOT NULL,
    class_id                        VARCHAR(36) NOT NULL,
    UNIQUE (trainer_id, class_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers (trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes (class_id) ON DELETE CASCADE
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

CREATE TABLE IF NOT EXISTS summaries
(
    summary_id  VARCHAR(36) NOT NULL PRIMARY KEY,
    schedule_id VARCHAR(36) NOT NULL,
    contents    TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_schedule_summary (schedule_id),

    CONSTRAINT fk_summary_schedule
        FOREIGN KEY (schedule_id)
            REFERENCES schedules (schedule_id)
            ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attendances
(
    attendance_id VARCHAR(36) NOT NULL PRIMARY KEY,
    summary_id    VARCHAR(36) NOT NULL,
    trainee_id    VARCHAR(36) NOT NULL,
    is_absent     TINYINT(1) DEFAULT 0,
    notes         TEXT        NULL,

    CONSTRAINT fk_attendance_summary
        FOREIGN KEY (summary_id)
            REFERENCES summaries (summary_id)
            ON DELETE CASCADE,

    CONSTRAINT fk_attendance_trainee
        FOREIGN KEY (trainee_id)
            REFERENCES trainees (trainee_id)
            ON DELETE CASCADE,

    UNIQUE KEY unique_summary_trainee (summary_id, trainee_id)
);

CREATE INDEX idx_trainers_user_id ON trainers (user_id);
CREATE INDEX idx_trainees_user_id ON trainees (user_id);
CREATE INDEX idx_classes_course_id ON classes (course_id);
CREATE INDEX idx_classes_modules_class_id ON classes_modules (class_id);
CREATE INDEX idx_classes_modules_trainer_id ON classes_modules (trainer_id);
CREATE INDEX idx_grades_trainee_id ON grades (trainee_id);
CREATE INDEX idx_grades_class_module_id ON grades (class_module_id);
CREATE INDEX idx_grades_status ON grades (status);
CREATE INDEX idx_availabilities_trainer_id ON availabilities (trainer_id);
CREATE INDEX idx_schedules_class_module_id ON schedules (class_module_id);
CREATE INDEX idx_schedules_trainer_id ON schedules (trainer_id);
CREATE INDEX idx_enrollments_class_id ON enrollments (class_id);
CREATE INDEX idx_enrollments_trainee_id ON enrollments (trainee_id);
CREATE INDEX idx_documents_user_id ON documents (user_id);
CREATE INDEX idx_coordinator_trainer_id ON trainers_classes_coordinator (trainer_id);
CREATE INDEX idx_coordinator_class_id ON trainers_classes_coordinator (class_id);
CREATE INDEX idx_schedule_slots_schedule_id ON schedule_slots (schedule_id);
CREATE INDEX idx_availabilities_lookup ON availabilities (trainer_id, date_day, is_booked);
CREATE INDEX idx_schedules_conflict ON schedules (trainer_id, start_date_timestamp, end_date_timestamp);
CREATE INDEX idx_slots_lookup ON schedule_slots (schedule_id, availability_id);
CREATE INDEX idx_classes_modules_lookup ON classes_modules (class_id, courses_modules_id);

DELIMITER //

CREATE PROCEDURE sp_refresh_attendance_grades(IN p_class_module_id VARCHAR(36))
BEGIN

    INSERT INTO grades (grade_id, class_module_id, trainee_id, grade, grade_type, status, created_at, updated_at)
    SELECT
        UUID() as grade_id,
        p_class_module_id,
        stats.trainee_id,
        IF(stats.total_hours > 0, (stats.attended_hours / stats.total_hours) * 20, 20) as calculated_grade,
        'attendance' as grade_type,
        'draft' as status,
        NOW() as created_at,
        NOW() as updated_at
    FROM (
        SELECT
            a.trainee_id,
            SUM(CASE WHEN a.is_absent = 0 THEN sch.total_hours ELSE 0 END) as attended_hours,
            SUM(sch.total_hours) as total_hours
        FROM attendances a
        JOIN summaries s ON a.summary_id = s.summary_id
        JOIN schedules sch ON s.schedule_id = sch.schedule_id
        WHERE sch.class_module_id = p_class_module_id
        GROUP BY a.trainee_id
    ) AS stats
    ON DUPLICATE KEY UPDATE
        grade = VALUES(grade),
        updated_at = NOW();
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER tr_after_attendance_update
AFTER INSERT ON attendances
FOR EACH ROW
BEGIN
    SET @cm_id = (
        SELECT sch.class_module_id
        FROM summaries s
        JOIN schedules sch ON s.schedule_id = sch.schedule_id
        WHERE s.summary_id = NEW.summary_id
        LIMIT 1
    );

    CALL sp_refresh_attendance_grades(@cm_id);
END //

CREATE TRIGGER tr_after_attendance_change
AFTER UPDATE ON attendances
FOR EACH ROW
BEGIN
    SET @cm_id = (
        SELECT sch.class_module_id
        FROM summaries s
        JOIN schedules sch ON s.schedule_id = sch.schedule_id
        WHERE s.summary_id = NEW.summary_id
        LIMIT 1
    );
    CALL sp_refresh_attendance_grades(@cm_id);
END //

DELIMITER ;