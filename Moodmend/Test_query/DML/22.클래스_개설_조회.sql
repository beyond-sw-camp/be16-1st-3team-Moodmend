-- 클래스 개설 프로시저
DELIMITER $$

CREATE PROCEDURE 민형_08_클래스_개설_및_상태설정 (
    IN p_members_id BIGINT,
    IN p_title VARCHAR(50),
    IN p_category VARCHAR(20),
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_limit INT
)
BEGIN
    DECLARE v_now DATETIME;
    DECLARE v_status ENUM('개강전','모집중','정원초과','모집완료');

    SET v_now = NOW();

    IF p_start_time > v_now THEN
        SET v_status = '모집중';
    ELSE
        SET v_status = '개강전';
    END IF;

    INSERT INTO meditation_class (
        members_id, title, category,
        start_time, end_time, `limit`, status
    ) VALUES (
        p_members_id, p_title, p_category,
        p_start_time, p_end_time, p_limit, v_status
    );
END $$

DELIMITER ;

-- 클래스 개설 명령어
call moodmend.민형_08_클래스_개설_및_상태설정(2, 'Meditation 101', '기본 명상', '2025-06-09 09:00:00', '2025-06-19 18:00:00', 30);

select * from meditation_class;