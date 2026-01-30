USE innovacad_tpsi0525;

SET FOREIGN_KEY_CHECKS = 0;

-- =======================================================
-- BETTER AUTH TABLES (DO NOT TOUCH)
-- =======================================================
/*
DELETE FROM user WHERE 1;
DELETE FROM session WHERE 1;
DELETE FROM account WHERE 1;
DELETE FROM verification WHERE 1;

DROP TABLE user;
DROP TABLE session;
DROP TABLE account;
DROP TABLE verification;
*/

-- =======================================================
-- INNOVACAD TABLES (DROP ALL)
-- =======================================================

DROP TABLE IF EXISTS
    documents,
    trainer_skills,
    grades,
    enrollments,
    schedules,
    schedule_slots,
    availabilities,
    ref_slots,
    classes_modules,
    courses_modules,
    rooms,
    classes,
    courses,
    modules,
    trainers,
    trainees,
    document_types;

SET FOREIGN_KEY_CHECKS = 1;