-- 플레이리스트 프로시저
DELIMITER $$

CREATE PROCEDURE 지현_01_플레이리스트_기능 (
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


-- 플레이리스트 생성

call moodmend.지현_01_플레이리스트_기능('create', 3, 1, '성후의 플레이리스트', '나의 명상!', 1, 2);