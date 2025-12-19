-- Check if room is available for reservation.
-- Receives a room_id, start_timestamp and end_timestamp for querying

DELIMITER //
CREATE PROCEDURE IsRoomAvailable(IN p_room_id VARCHAR(36), IN p_start_timestamp INT(11), IN p_end_timestamp INT(11),
                                 OUT p_available BOOLEAN)
BEGIN

    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM schedules
    WHERE room_id = p_room_id
      AND start_date_timestamp < p_end_timestamp
      AND end_date_timestamp > p_start_timestamp;

    IF v_count = 0 THEN
        SET p_available = TRUE;
    ELSE
        SET p_available = FALSE;
    END IF;

END//
DELIMITER ;

CALL IsRoomAvailable('0.22-A', UNIX_TIMESTAMP(NOW()), UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)), @available);
SELECT @available AS available;

-- Check if trainer is available for schedule reservation
-- Receives a trainer_id, start_timestamp and end_timestamp for querying

DELIMITER //
CREATE PROCEDURE IsTrainerAvailable(IN p_trainer_id VARCHAR(36), IN p_start_timestamp INT(11),
                                    IN p_end_timestamp INT(11), OUT p_available BOOLEAN)
BEGIN
    DECLARE v_has_availability INT DEFAULT 0;
    DECLARE v_has_conflict INT DEFAULT 0;

    -- 1. Cabe na janela de trabalho? (Contenção total)
    SELECT COUNT(*) INTO v_has_availability
    FROM availabilities
    WHERE trainer_id = p_trainer_id
      AND start_date_timestamp <= p_start_timestamp
      AND end_date_timestamp >= p_end_timestamp;

    -- 2. Choca com outra aula? (Qualquer intersecção)
    SELECT COUNT(*) INTO v_has_conflict
    FROM schedules
    WHERE trainer_id = p_trainer_id
      AND (p_start_timestamp < end_date_timestamp AND p_end_timestamp > start_date_timestamp);

    IF v_has_availability > 0 AND v_has_conflict = 0 THEN
        SET p_available = TRUE;
    ELSE
        SET p_available = FALSE;
    END IF;
END //
DELIMITER ;

CALL IsTrainerAvailable('28793aef-c6db-413d-9adc-3d1375897cfa', UNIX_TIMESTAMP(NOW()),
                        UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)), @available);
SELECT @available AS available;

-- Check if module has finished
-- Receives a p_module_id, p_class_id, p_current_duration for querying

DELIMITER //
CREATE PROCEDURE HasModuleFinished(IN p_module_id VARCHAR(36), IN p_class_id VARCHAR(36),
                                   OUT p_finished BOOLEAN)
BEGIN

    SELECT (cm.current_duration > 0 AND cm.current_duration < m.duration) = 0 as finished
    INTO p_finished
    FROM classes_modules as cm
             JOIN modules m ON m.module_id = p_module_id
    WHERE cm.class_id = p_class_id
      AND cm.module_id = p_module_id;

END //
DELIMITER ;

CALL HasModuleFinished('87969f59-1016-44ae-903f-a5593530cedb', '74a05d40-8e0d-4b52-9537-eb41dcb61100', @finished);
SELECT @finished AS finished;

-- Check if class has finished
-- Received a p_class_id for querying

DELIMITER //

CREATE PROCEDURE HasClassFinished(IN p_class_id VARCHAR(36), OUT p_finished BOOLEAN)
BEGIN

    SET p_finished = TRUE;

    SELECT (status IN ('finished', 'starting'))
    INTO p_finished
    FROM classes
    WHERE class_id = p_class_id;

END //

DELIMITER ;

CALL HasClassFinished('74a05d40-8e0d-4b52-9537-eb41dcb61100', @finished);
SELECT @finished AS finished;

-- Check if a schedule can be created
-- Receives a p_room_id, p_class_id, p_trainer_id, p_module_id, p_room_id, p_start_timestamp, p_end_timestamp for querying
DELIMITER //
CREATE PROCEDURE CanCreateSchedule(IN p_room_id VARCHAR(6), IN p_trainer_id varchar(36), IN p_module_id varchar(36),
                                   IN p_class_id varchar(36), IN p_start_timestamp int(11), IN p_end_timestamp int(11))
BEGIN

    DECLARE trainer_aval BOOLEAN DEFAULT FALSE;
    DECLARE room_aval BOOLEAN DEFAULT FALSE;
    DECLARE class_finished BOOLEAN DEFAULT TRUE;
    DECLARE module_finished BOOLEAN DEFAULT TRUE;

    SET @can_create = FALSE;

    CALL IsTrainerAvailable(p_trainer_id, p_start_timestamp, p_end_timestamp, trainer_aval);
    CALL IsRoomAvailable(p_room_id, p_start_timestamp, p_end_timestamp, room_aval);
    CALL HasModuleFinished(p_module_id, p_class_id, module_finished);
    CALL HasClassFinished(p_class_id, class_finished);

    IF (trainer_aval = TRUE) AND
       (room_aval = TRUE) AND
       (module_finished = FALSE) AND
       (class_finished = FALSE)
    THEN
        SET @can_create = TRUE;

    END IF;

END //
DELIMITER ;

CALL CanCreateSchedule('0.22-A', '60dcc0e4-7935-4472-8c9d-0f739b1ce68e', 'aae85310-2af2-42b8-8dfb-17f3e0073f2b',
                       '14100964-b06f-4423-b57f-0b545e3dc802', UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)),
                       UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 6 HOUR)));
SELECT @can_create;
