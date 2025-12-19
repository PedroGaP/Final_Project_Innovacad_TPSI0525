-- Check if room is available for reservation.
-- Receives a room_id, start_timestamp and end_timestamp for querying
CREATE PROCEDURE IsRoomAvailable(room_id VARCHAR(36), start_timestamp int(11), end_timestamp int(11))
BEGIN

    SELECT count(s2.room_id) > 0 as available
    from (SELECT *
    from schedules s
    where s.room_id = room_id
      and not (end_timestamp <= s.end_date_timestamp and start_timestamp >= s.start_date_timestamp)) as s2;

END;

CALL IsRoomAvailable('0.22-A', 1766158718, 1766169518);

-- Check if trainer is available for schedule reservation
CREATE PROCEDURE IsTrainerAvailable(trainer_id VARCHAR(36))
BEGIN

END;

CALL IsTrainerAvailable();