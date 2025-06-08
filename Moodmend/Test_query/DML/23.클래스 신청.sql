-- 클래스 신청 프로시저

DELIMITER $$

CREATE PROCEDURE 민형_10_클래스_신청 (
    IN p_members_id BIGINT,
    IN p_meditation_class_id BIGINT
)
BEGIN
    DECLARE v_count INT;

    -- 현재 예약 인원 수 확인
    SELECT COUNT(*) INTO v_count
    FROM class_reservation
    WHERE meditation_class_id = p_meditation_class_id;

    -- 중복 예약 여부 확인
    IF EXISTS (
        SELECT 1 FROM class_reservation
        WHERE members_id = p_members_id
          AND meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 해당 클래스를 신청하셨습니다.';
    END IF;

    -- 정원 초과 여부 확인 (limit 예약어 처리)
    IF v_count >= (
        SELECT `limit` FROM meditation_class
        WHERE meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '정원이 초과되었습니다.';
    END IF;

    -- 예약 등록
    INSERT INTO class_reservation (meditation_class_id, members_id)
    VALUES (p_meditation_class_id, p_members_id);
END $$

DELIMITER ;


-- 클래스를 예약하는 명령어
call moodmend.민형_10_클래스_신청(3, 1);

select * from class_reservation;