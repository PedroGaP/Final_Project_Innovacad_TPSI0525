DELIMITER $$

DROP PROCEDURE IF EXISTS sp_check_course_viability $$

CREATE PROCEDURE sp_check_course_viability(IN p_course_id VARCHAR(36))
BEGIN
    DECLARE v_missing_module_name VARCHAR(64);

    SELECT m.name INTO v_missing_module_name
    FROM courses_modules cm
    JOIN modules m ON cm.module_id = m.module_id
    WHERE cm.course_id = p_course_id
    AND NOT EXISTS (
        SELECT 1 
        FROM trainer_skills ts 
        WHERE ts.module_id = cm.module_id
    )
    LIMIT 1;

    IF v_missing_module_name IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: The "%s" module does not have qualified trainers. Assign skills before scheduling!';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_book_slot_if_available $$

CREATE PROCEDURE sp_book_slot_if_available(
    IN p_class_id VARCHAR(36),
    IN p_module_id VARCHAR(36),
    IN p_class_module_id VARCHAR(36),
    IN p_target_date DATE,
    IN p_slot_number INT,
    IN p_is_online BOOLEAN,
    IN p_extend_schedule_id VARCHAR(36),
    OUT p_success BOOLEAN,
    OUT p_schedule_id VARCHAR(36)
)
BEGIN
    DECLARE v_trainer_id VARCHAR(36);
    DECLARE v_room_id INT;
    DECLARE v_availability_id VARCHAR(36);
    DECLARE v_start_time TIME;
    DECLARE v_end_time TIME;
    DECLARE v_start_timestamp DATETIME;
    DECLARE v_end_timestamp DATETIME;
    DECLARE v_forced_trainer_id VARCHAR(36) DEFAULT NULL;
    DECLARE v_forced_room_id INT DEFAULT NULL;

    SET p_success = FALSE;
    SET p_schedule_id = NULL;

    SELECT start_time, end_time INTO v_start_time, v_end_time
    FROM ref_slots WHERE slot_number = p_slot_number;

    SET v_start_timestamp = CONCAT(p_target_date, ' ', v_start_time);
    SET v_end_timestamp = CONCAT(p_target_date, ' ', v_end_time);

    -- Verificar se a TURMA já tem aula neste horário (CRÍTICO PARA EVITAR SOBREPOSIÇÃO)
    IF EXISTS (
        SELECT 1
        FROM schedules s
        JOIN schedule_slots ss ON s.schedule_id = ss.schedule_id
        JOIN availabilities av ON ss.availability_id = av.availability_id
        JOIN classes_modules cm ON s.class_module_id = cm.classes_modules_id
        WHERE cm.class_id = p_class_id -- Mesma Turma
        AND av.date_day = p_target_date
        AND av.slot_number = p_slot_number
        -- Ignora se for o próprio agendamento que estamos a estender
        AND (p_extend_schedule_id IS NULL OR s.schedule_id != p_extend_schedule_id)
    ) THEN
        SET p_success = FALSE;
    ELSE
        -- Se a turma estiver livre, prosseguir com a lógica normal

        IF p_extend_schedule_id IS NOT NULL AND p_extend_schedule_id != 'NULL' THEN
            SELECT trainer_id, room_id INTO v_forced_trainer_id, v_forced_room_id
            FROM schedules WHERE schedule_id = p_extend_schedule_id;
        END IF;

        SELECT
            t.trainer_id, r.room_id, a.availability_id
        INTO v_trainer_id, v_room_id, v_availability_id
        FROM trainers t
        JOIN trainer_skills ts ON t.trainer_id = ts.trainer_id AND ts.module_id = p_module_id
        JOIN availabilities a ON t.trainer_id = a.trainer_id
            AND a.date_day = p_target_date
            AND a.slot_number = p_slot_number
            AND a.is_booked = 0
        LEFT JOIN rooms r ON p_is_online = FALSE
            AND r.capacity >= (SELECT COUNT(*) FROM enrollments WHERE class_id = p_class_id)
        WHERE
            (v_forced_trainer_id IS NULL OR t.trainer_id = v_forced_trainer_id)
            AND (p_is_online = TRUE OR (v_forced_room_id IS NULL OR r.room_id = v_forced_room_id))
            AND (p_is_online = TRUE OR r.room_id IS NOT NULL)
            AND (
                p_is_online = TRUE OR NOT EXISTS (
                    SELECT 1 FROM schedules s
                    JOIN schedule_slots ss ON s.schedule_id = ss.schedule_id
                    JOIN availabilities av_linked ON ss.availability_id = av_linked.availability_id
                    WHERE s.room_id = r.room_id
                    AND av_linked.date_day = p_target_date
                    AND av_linked.slot_number = p_slot_number
                )
            )
        ORDER BY IF(p_is_online, 0, r.capacity) ASC
        LIMIT 1;

        IF v_trainer_id IS NOT NULL THEN
            IF p_extend_schedule_id IS NOT NULL AND p_extend_schedule_id != 'NULL' AND v_trainer_id = v_forced_trainer_id THEN
                UPDATE schedules
                SET end_date_timestamp = v_end_timestamp,
                    total_hours = TIMESTAMPDIFF(MINUTE, start_date_timestamp, v_end_timestamp) / 60.0
                WHERE schedule_id = p_extend_schedule_id;
                SET p_schedule_id = p_extend_schedule_id;
            ELSE
                SET p_schedule_id = UUID();
                INSERT INTO schedules (
                    schedule_id, class_module_id, trainer_id, room_id, is_online,
                    created_at, start_date_timestamp, end_date_timestamp, total_hours
                ) VALUES (
                    p_schedule_id, p_class_module_id, v_trainer_id, v_room_id, p_is_online,
                    NOW(), v_start_timestamp, v_end_timestamp, 1.0
                );
            END IF;

            INSERT INTO schedule_slots (slot_id, schedule_id, availability_id, slot_status)
            VALUES (UUID(), p_schedule_id, v_availability_id, 1);

            UPDATE availabilities SET is_booked = 1 WHERE availability_id = v_availability_id;
            SET p_success = TRUE;
        END IF;
    END IF;
END $$

DELIMITER ;