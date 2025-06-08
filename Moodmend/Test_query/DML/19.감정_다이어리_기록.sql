-- 감정 다이어리 기록 프로시저
DELIMITER $$

CREATE PROCEDURE 지현_05_감정_다이어리_기록 (
    IN p_members_id BIGINT,
    IN p_emotion_id BIGINT,
    IN p_intensity TINYINT,
    IN p_title VARCHAR(255),
    IN p_contents TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM emotion_diary 
        WHERE members_id = p_members_id AND logged_at = CURRENT_DATE
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '오늘은 이미 감정 다이어리를 작성하셨습니다.';
    END IF;

    INSERT INTO emotion_diary (
        members_id,
        emotion_id,
        title,
        contents,
        logged_at
    ) VALUES (
        p_members_id,
        p_emotion_id,
        p_title,
        p_contents,
        CURRENT_DATE
    );

    UPDATE emotion
    SET intensity = p_intensity
    WHERE emotion_id = p_emotion_id;
END $$

DELIMITER ;

-- 성후라는 유저가 감정 다이어리에 본인의 감정 카테고리와 강도를 기록하는 예시
-- emotion_id = 6 의 '슬픔' 강도 1로 설정
call moodmend.지현_05_감정_다이어리_기록(3, 6, 1, '성후의 다이어리', '오늘은 너무 슬프다.');