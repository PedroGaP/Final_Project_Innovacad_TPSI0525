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
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_trainer_id VARCHAR(36);
    DECLARE v_room_id INT;
    DECLARE v_availability_id VARCHAR(36);
    DECLARE v_schedule_id VARCHAR(36);
    
    DECLARE v_required_seats INT;
    DECLARE v_need_pc BOOLEAN;
    DECLARE v_need_proj BOOLEAN;

    SET p_success = FALSE;

    SELECT 
        (SELECT COUNT(*) FROM enrollments WHERE class_id = p_class_id),
        m.has_computers, m.has_projector
    INTO v_required_seats, v_need_pc, v_need_proj
    FROM modules m WHERE m.module_id = p_module_id;

    SELECT 
        t.trainer_id,
        r.room_id,
        a.availability_id
    INTO v_trainer_id, v_room_id, v_availability_id
    FROM trainers t
    JOIN trainer_skills ts ON t.trainer_id = ts.trainer_id 
        AND ts.module_id = p_module_id
    JOIN availabilities a ON t.trainer_id = a.trainer_id 
        AND a.date_day = p_target_date 
        AND a.slot_number = p_slot_number 
        AND a.is_booked = 0
    LEFT JOIN rooms r ON p_is_online = FALSE
    WHERE 
        (p_is_online = TRUE 
         OR (
            r.capacity >= v_required_seats
            AND r.has_computers >= v_need_pc
            AND r.has_projector >= v_need_proj
            AND NOT EXISTS (
                SELECT 1 
                FROM schedules s
                JOIN schedule_slots ss ON s.schedule_id = ss.schedule_id
                JOIN availabilities av_linked ON ss.availability_id = av_linked.availability_id
                WHERE s.room_id = r.room_id
                AND av_linked.date_day = p_target_date
                AND av_linked.slot_number = p_slot_number
            )
         )
        )
    ORDER BY 
        IF(p_is_online, 0, r.capacity),
        RAND()
    LIMIT 1;

    IF v_trainer_id IS NOT NULL THEN
        SET v_schedule_id = UUID();

        INSERT INTO schedules (schedule_id, class_module_id, trainer_id, room_id, is_online, created_at)
        VALUES (v_schedule_id, p_class_module_id, v_trainer_id, v_room_id, p_is_online, NOW());

        INSERT INTO schedule_slots (schedule_id, availability_id, slot_status)
        VALUES (v_schedule_id, v_availability_id, 1);

        UPDATE availabilities 
        SET is_booked = 1 
        WHERE availability_id = v_availability_id;

        SET p_success = TRUE;
    END IF;

END $$

DELIMITER ;