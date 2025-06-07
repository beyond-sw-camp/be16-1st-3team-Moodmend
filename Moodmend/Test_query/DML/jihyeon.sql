DELIMITER $$

CREATE PROCEDURE 01_플레이리스트_기능 (
    IN p_action VARCHAR(20),
    IN p_members_id BIGINT,
    IN p_playlist_id BIGINT,
    IN p_title VARCHAR(50),
    IN p_description TEXT,
    IN p_is_public BOOLEAN,
    IN p_contents_id BIGINT
)
BEGIN
    IF p_action = 'create' THEN
        INSERT INTO playlist (members_id, title, description, is_public)
        VALUES (p_members_id, p_title, p_description, p_is_public);

    ELSEIF p_action = 'add' THEN
        INSERT INTO playlist_detail (playlist_id, contents_id)
        VALUES (p_playlist_id, p_contents_id);

    ELSEIF p_action = 'remove' THEN
        DELETE FROM playlist_detail
        WHERE playlist_id = p_playlist_id AND contents_id = p_contents_id;

    ELSEIF p_action = 'rename' THEN
        UPDATE playlist
        SET title = p_title, description = p_description
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'visibility' THEN
        UPDATE playlist
        SET is_public = p_is_public
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'share' THEN
        UPDATE playlist
        SET playlist_share = UUID()
        WHERE playlist_id = p_playlist_id AND members_id = p_members_id;

    ELSEIF p_action = 'view' THEN
        SELECT 
            p.playlist_id,
            p.title,
            p.description,
            p.is_public,
            p.playlist_share,
            d.pd_id,
            c.contents_id,
            c.name AS contents_name,
            c.duration,
            c.thumbnail
        FROM playlist p
        LEFT JOIN playlist_detail d ON p.playlist_id = d.playlist_id
        LEFT JOIN contents c ON d.contents_id = c.contents_id
        WHERE p.members_id = p_members_id AND (p_playlist_id IS NULL OR p.playlist_id = p_playlist_id);
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 02_포인트_이력_조회_jh (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        point_reward_id,
        point_reward,
        reward_date,
        reason
    FROM point_reward
    WHERE members_id = p_members_id
    ORDER BY reward_date DESC;
END $$

DELIMITER ; 

DELIMITER $$

CREATE PROCEDURE 04_재화_변경_관리자 (
    IN p_members_id BIGINT,
    IN p_point_change INT,
    IN p_reason VARCHAR(50)
)
BEGIN
    UPDATE members
    SET point = point + p_point_change
    WHERE members_id = p_members_id;

    INSERT INTO point_reward (members_id, point_reward, reason)
    VALUES (p_members_id, p_point_change, p_reason);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE 05_감정_다이어리_기록 (
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

DELIMITER $$

CREATE PROCEDURE 06_감정_기반_콘텐츠_추천 (
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

DELIMITER $$

CREATE PROCEDURE 07_출석_기록 (
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

DELIMITER $$

CREATE PROCEDURE 08_출석_조회 (
    IN p_members_id BIGINT
)
BEGIN
    SELECT 
        attendance_id,
        attendance_date
    FROM attendance
    WHERE members_id = p_members_id
    ORDER BY attendance_date DESC;
END $$

DELIMITER ;