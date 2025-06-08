SELECT * FROM moodmend.avatar;


-- 아바타 등록 및 수정 프로시저

DELIMITER $$

CREATE PROCEDURE 성후_17_아바타_조회_수정_등록 (
    IN p_members_id BIGINT,
    IN p_avatar_name VARCHAR(50),
    IN p_is_default BOOLEAN
)
BEGIN
    DECLARE v_exists INT;

    START TRANSACTION;

    -- 존재 여부 확인
    SELECT COUNT(*) INTO v_exists
    FROM avatar
    WHERE members_id = p_members_id;

    -- 수정 또는 등록
    IF v_exists > 0 THEN
        UPDATE avatar
        SET avatar_name = p_avatar_name,
            is_default = p_is_default
        WHERE members_id = p_members_id;
    ELSE
        INSERT INTO avatar (members_id, avatar_name, is_default)
        VALUES (p_members_id, p_avatar_name, p_is_default);
    END IF;

    -- 조회 결과 반환
    SELECT *
    FROM avatar
    WHERE members_id = p_members_id;

    COMMIT;
END$$

DELIMITER ;


-- 성후라는 일반 유저가 아바타를 조회, 수정 또는 등록
call moodmend.성후_17_아바타_조회_수정_등록(3, '기본 아바타', 1);

-- 아바타 아이템 장착
INSERT INTO avatar_items_map (avatar_id, items_id)
VALUES (1, 1);

select * from moodmend.avatar_items_map;