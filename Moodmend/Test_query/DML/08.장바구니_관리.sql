DELIMITER $$

CREATE PROCEDURE 민형_01_장바구니_관리 (
    IN p_action VARCHAR(20),          -- 'add', 'remove', 'clear'
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE v_is_premium ENUM('일반', '프리미엄');
    DECLARE v_price INT UNSIGNED;

    IF p_action = 'add' THEN
        -- 프리미엄 여부 및 가격 확인
        SELECT is_premium, price INTO v_is_premium, v_price
        FROM contents
        WHERE contents_id = p_contents_id;

        IF v_is_premium != '프리미엄' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '무료 콘텐츠는 장바구니에 담을 수 없습니다.';
        END IF;

        -- total 포함하여 장바구니에 추가
        INSERT IGNORE INTO cart (members_id, contents_id, total)
        VALUES (p_members_id, p_contents_id, v_price);

    ELSEIF p_action = 'remove' THEN
        DELETE FROM cart
        WHERE members_id = p_members_id AND contents_id = p_contents_id;

    ELSEIF p_action = 'clear' THEN
        DELETE FROM cart
        WHERE members_id = p_members_id;
    END IF;
END $$

DELIMITER ;

-- 성후라는 일반 유저가 2번 콘텐츠를 장바구니에 추가
call moodmend.민형_01_장바구니_관리('add', 3, 2);


-- 장바구니 조회
select * from cart;