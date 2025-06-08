-- 포인트 내역 조회

DELIMITER $$

CREATE PROCEDURE 지현_02_포인트_이력_조회 (
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


-- 일반 유저가 자신의 포인트 이력을 조회
call moodmend.지현_02_포인트_이력_조회(3);

-- 관리자가 모든 유저의 포인트 이력을 조회
call moodmend.지현_03_재화이력조회관리자();
