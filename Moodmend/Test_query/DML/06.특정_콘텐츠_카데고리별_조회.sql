-- 특정 콘텐츠 카테고리별 조회

DELIMITER $$

CREATE PROCEDURE 성후_09_카테고리별_콘텐츠_조회(
    IN p_category VARCHAR(20)
)
BEGIN
    SELECT 
        c.contents_id,
        c.name,
        c.description,
        c.thumbnail,
        c.duration,
        c.price,
        c.is_premium,
        c.upload_at,
        e.emotion_name,
        m.nickname AS creator
    FROM contents c
    JOIN emotion e ON c.emotion_id = e.emotion_id
    JOIN members m ON c.members_id = m.members_id
    WHERE e.emotion_name = p_category;
END $$

DELIMITER ;


-- 성후라는 일반 유저가 '슬픔' 카테고리의 콘텐츠를 조회
call moodmend.성후_09_카테고리별_콘텐츠_조회('슬픔');
