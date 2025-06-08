-- 출석 기록 프로시저
DELIMITER $$

CREATE PROCEDURE 지현_07_출석_기록 (
    IN p_members_id BIGINT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM attendance 
        WHERE members_id = p_members_id AND attendance_date = CURRENT_DATE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오늘은 이미 출석하셨습니다.';
    END IF;

    INSERT INTO attendance (members_id, attendance_date)
    VALUES (p_members_id, CURRENT_DATE);
END $$

DELIMITER ;


-- 출석 기록 예시
call moodmend.지현_06_감정_기반_콘텐츠_추천(3);