-- 콘텐츠 신고 프로시저

DELIMITER $$

CREATE PROCEDURE 성후_11_콘텐츠_신고 (
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT,
    IN p_reason TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM reports
        WHERE members_id = p_members_id AND contents_id = p_contents_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 신고한 콘텐츠입니다.';
    END IF;

    INSERT INTO reports (members_id, contents_id, reason, reported_at, status)
    VALUES (p_members_id, p_contents_id, p_reason, NOW(), '검토 중');
END $$

DELIMITER ;


-- 성후라는 일반 유저가 2번 콘텐츠를 과하게 비싸다는 이유로 신고
call moodmend.성후_11_콘텐츠_신고(3, 2, '너무 과하게 비쌈');

-- 신고 내역 조회
select * from reports;