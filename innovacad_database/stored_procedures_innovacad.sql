-- Check if room is available for reservation.
-- Receives a room_id, start_timestamp and end_timestamp for querying

DELIMITER //
CREATE PROCEDURE IsRoomAvailable(IN p_room_id VARCHAR(36), IN p_start_timestamp TIMESTAMP, IN p_end_timestamp TIMESTAMP,
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
CREATE PROCEDURE IsTrainerAvailable(IN p_trainer_id VARCHAR(36), IN p_start_timestamp TIMESTAMP,
                                    IN p_end_timestamp TIMESTAMP, OUT p_available BOOLEAN)
BEGIN
    DECLARE v_has_availability INT DEFAULT 0;
    DECLARE v_has_conflict INT DEFAULT 0;

    -- 1. Cabe na janela de trabalho? (Contenção total)
    SELECT COUNT(*)
    INTO v_has_availability
    FROM availabilities
    WHERE trainer_id = p_trainer_id
      AND start_date_timestamp <= p_start_timestamp
      AND end_date_timestamp >= p_end_timestamp;

    -- 2. Choca com outra aula? (Qualquer intersecção)
    SELECT COUNT(*)
    INTO v_has_conflict
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

-- Check if a class is available for a set start and end date
-- Receives a p_class_id, p_start_timestamp and p_end_timestamp for querying
DELIMITER //
CREATE PROCEDURE IsClassAvailable(
    IN p_class_id VARCHAR(36),
    IN p_start_timestamp INT,
    IN p_end_timestamp INT,
    OUT p_available BOOLEAN
)
BEGIN
    DECLARE v_conflict_count INT;

    SELECT COUNT(*)
    INTO v_conflict_count
    FROM schedules
    WHERE class_id = p_class_id
      AND (p_start_timestamp < end_date_timestamp AND p_end_timestamp > start_date_timestamp);

    IF v_conflict_count = 0 THEN
        SET p_available = TRUE;
    ELSE
        SET p_available = FALSE;
    END IF;
END //
DELIMITER ;

CALL IsClassAvailable('74a05d40-8e0d-4b52-9537-eb41dcb61100', UNIX_TIMESTAMP(NOW()),
                      UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)), @available);
SELECT @available;

-- Check if module has finished
-- Receives a p_courses_modules_id, p_module_id, p_class_id, p_current_duration for querying

DELIMITER //
CREATE PROCEDURE HasModuleFinished(IN p_courses_modules_id VARCHAR(36), IN p_class_id VARCHAR(36),
                                   OUT p_finished BOOLEAN)
BEGIN
    SET p_finished = FALSE;

    SELECT (cm.current_duration >= m.duration)
    INTO p_finished
    FROM classes_modules cm
             JOIN modules m ON m.module_id = cm.courses_modules_id
    WHERE cm.class_id = p_class_id
      AND cm.courses_modules_id = p_courses_modules_id;

    IF p_finished IS NULL THEN SET p_finished = FALSE; END IF;

    IF p_finished IS NULL THEN
        SET p_finished = FALSE;
    END IF;
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
-- Receives a p_room_id, p_class_id, p_trainer_id, p_module_id, p_start_timestamp, p_end_timestamp for querying
DELIMITER //
CREATE PROCEDURE CanCreateSchedule(
    IN p_room_id VARCHAR(6),
    IN p_trainer_id VARCHAR(36),
    IN p_module_id VARCHAR(36),
    IN p_class_id VARCHAR(36),
    IN p_start_timestamp INT(11),
    IN p_end_timestamp INT(11),
    OUT p_can_create BOOLEAN,
    OUT p_reason VARCHAR(100)
)
BEGIN
    DECLARE v_trainer_aval BOOLEAN DEFAULT FALSE;
    DECLARE v_room_aval BOOLEAN DEFAULT FALSE;
    DECLARE v_class_aval BOOLEAN DEFAULT FALSE;
    DECLARE v_module_finished BOOLEAN DEFAULT TRUE;
    DECLARE v_class_finished BOOLEAN DEFAULT TRUE;
    DECLARE v_has_capacity BOOLEAN DEFAULT FALSE;

    CALL IsTrainerAvailable(p_trainer_id, p_start_timestamp, p_end_timestamp, v_trainer_aval);
    CALL IsRoomAvailable(p_room_id, p_start_timestamp, p_end_timestamp, v_room_aval);
    CALL IsClassAvailable(p_class_id, p_start_timestamp, p_end_timestamp, v_class_aval);

    CALL HasModuleFinished(p_module_id, p_class_id, v_module_finished);
    CALL HasClassFinished(p_class_id, v_class_finished);
    CALL IsRoomAvailable(p_room_id, p_start_timestamp, p_end_timestamp, v_has_capacity);

    IF NOT v_trainer_aval THEN
        SET p_reason = 'Formador indisponível ou fora do horário.';
    ELSEIF NOT v_room_aval THEN
        SET p_reason = 'Sala já ocupada neste horário.';
    ELSEIF NOT v_class_aval THEN
        SET p_reason = 'A Turma já tem outra aula neste horário.';
    ELSEIF NOT v_has_capacity THEN
        SET p_reason = 'Sala pequena demais para o número de alunos matriculados.';
    ELSEIF v_module_finished THEN
        SET p_reason = 'Este módulo já completou a carga horária total.';
    ELSEIF v_class_finished THEN
        SET p_reason = 'A turma já encerrou o curso.';
    ELSE
        SET p_can_create = TRUE;
        SET p_reason = 'OK';
    END IF;

    IF p_can_create IS NULL THEN SET p_can_create = FALSE; END IF;

END //
DELIMITER ;

CALL CanCreateSchedule('0.22-A', '60dcc0e4-7935-4472-8c9d-0f739b1ce68e', 'aae85310-2af2-42b8-8dfb-17f3e0073f2b',
                       '14100964-b06f-4423-b57f-0b545e3dc802', UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)),
                       UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 6 HOUR)), @can_create, @reason);
SELECT @can_create, @reason;

-- Enroll a Trainee to a class
-- Receives a p_trainee_id and p_class_id for querying
DELIMITER //
CREATE PROCEDURE EnrollTraineeInClass(
    IN p_trainee_id VARCHAR(36),
    IN p_class_id VARCHAR(36),
    OUT p_success BOOLEAN
)
BEGIN
    INSERT INTO enrollments (class_id, trainee_id) VALUES (p_class_id, p_trainee_id);
    SET p_success = TRUE;
END //
DELIMITER ;

CALL EnrollTraineeInClass('b332fc2c-832a-4d33-8f2f-139d733be9f7', '74a05d40-8e0d-4b52-9537-eb41dcb61100', @success);
SELECT @success;

-- Updates a module current duration to a set number of hours, if module hasn't finished
-- Receives a p_class_id, p_module_id and p_hours_to_add for querying
DELIMITER //
CREATE PROCEDURE UpdateModuleProgress(
    IN p_class_id VARCHAR(36),
    IN p_module_id VARCHAR(36),
    IN p_hours_to_add INT,
    OUT p_is_completed BOOLEAN,
    OUT p_total_duration INT
)
BEGIN
    DECLARE v_new_duration INT;
    DECLARE v_total_duration INT;

    UPDATE classes_modules
    SET current_duration = current_duration + p_hours_to_add
    WHERE class_id = p_class_id
      AND module_id = p_module_id;

    SELECT cm.current_duration, m.duration
    INTO v_new_duration, v_total_duration
    FROM classes_modules cm
             JOIN modules m ON cm.module_id = m.module_id
    WHERE cm.class_id = p_class_id
      AND cm.module_id = p_module_id;

    IF v_new_duration >= v_total_duration THEN
        SET p_is_completed = TRUE;
    ELSE
        SET p_is_completed = FALSE;
    END IF;

    SET p_total_duration = v_total_duration;
END //
DELIMITER ;

CALL CanCreateSchedule('0.22-A', '60dcc0e4-7935-4472-8c9d-0f739b1ce68e', 'aae85310-2af2-42b8-8dfb-17f3e0073f2b',
                       '14100964-b06f-4423-b57f-0b545e3dc802', UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 3 HOUR)),
                       UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 6 HOUR)));
SELECT @can_create;

-- Schedules a lesson
-- Receives a p_class_module_id, p_trainer_id, p_room_id, p_availability_id, p_start_timestamp, p_end_timestamp, p_online
DELIMITER //

CREATE PROCEDURE ScheduleLesson(
    IN p_class_module_id VARCHAR(36),
    IN p_trainer_id VARCHAR(36),
    IN p_room_id INT,
    IN p_availability_id VARCHAR(36),
    IN p_start_timestamp TIMESTAMP,
    IN p_end_timestamp TIMESTAMP,
    IN p_online BOOLEAN
)
BEGIN
    DECLARE v_horas_aula INT;
    DECLARE v_horas_disponiveis INT;
    DECLARE v_room_ok BOOLEAN;
    DECLARE v_trainer_ok BOOLEAN;
    DECLARE v_class_id VARCHAR(36);
    DECLARE v_courses_modules_id VARCHAR(36);
    DECLARE v_mod_finished BOOLEAN;

    -- Obter IDs de contexto
    SELECT class_id, courses_modules_id
    INTO v_class_id, v_courses_modules_id
    FROM classes_modules
    WHERE classes_modules_id = p_class_module_id;

    CALL IsRoomAvailable(p_room_id, p_start_timestamp, p_end_timestamp, v_room_ok);
    CALL IsTrainerAvailable(p_trainer_id, p_start_timestamp, p_end_timestamp, v_trainer_ok);
    CALL HasModuleFinished(v_courses_modules_id, v_class_id, v_mod_finished);

    -- Cálculo de horas da disponibilidade
    SELECT (TIMESTAMPDIFF(HOUR, start_date_timestamp, end_date_timestamp) -
            (SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, start_date_timestamp, end_date_timestamp)), 0)
             FROM schedules
             WHERE availability_id = p_availability_id))
    INTO v_horas_disponiveis
    FROM availabilities
    WHERE availability_id = p_availability_id;

    SET v_horas_aula = TIMESTAMPDIFF(HOUR, p_start_timestamp, p_end_timestamp);

    -- Lógica de Decisão
    IF v_mod_finished THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Módulo já concluído para esta turma.';
    ELSEIF NOT v_trainer_ok THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Formador indisponível ou com conflito.';
    ELSEIF NOT v_room_ok AND NOT p_online THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Sala ocupada.';
    ELSEIF v_horas_aula > v_horas_disponiveis THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Horas insuficientes no bloco de disponibilidade.';
    ELSE
        INSERT INTO schedules (class_module_id, trainer_id, room_id, availability_id, online, start_date_timestamp,
                               end_date_timestamp)
        VALUES (p_class_module_id, p_trainer_id, p_room_id, p_availability_id, p_online, p_start_timestamp,
                p_end_timestamp);

        -- Atualizar status da disponibilidade
        UPDATE availabilities
        SET status = IF(v_horas_disponiveis <= v_horas_aula, 'full', 'partial')
        WHERE availability_id = p_availability_id;
    END IF;
END //

DELIMITER ;
