-- 감정 기반 콘텐츠 추천 프로시저
DELIMITER $$

CREATE PROCEDURE 지현_06_감정_기반_콘텐츠_추천 (
    IN p_members_id BIGINT
)
BEGIN
    DECLARE v_emotion_id BIGINT;

    SELECT emotion_id INTO v_emotion_id
    FROM emotion_diary
    WHERE members_id = p_members_id
    ORDER BY logged_at DESC
    LIMIT 1;

    SELECT 
        c.contents_id,
        c.name,
        c.description,
        c.thumbnail,
        c.duration,
        c.price,
        c.is_premium
    FROM contents c
    WHERE c.emotion_id = v_emotion_id
    ORDER BY upload_at DESC;
END $$

DELIMITER ;


-- 성후라는 유저의 감정 다이어리에 기록된 감정에 기반하여 콘텐츠를 추천하는 예시
call moodmend.지현_06_감정_기반_콘텐츠_추천(3);