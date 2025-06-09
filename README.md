# 🧘‍♀️ Moodmend DB 프로젝트

감정 기반 명상 콘텐츠 추천 플랫폼 **Moodmend**의 데이터베이스 모델링 프로젝트입니다.

&nbsp;

<p align="center">
  <img src="./Moodmend/images/logo/moodmend_logo.png" width="1000" alt="Moodmend Logo"/>
</p>

---

## 📌 프로젝트 개요  

- **Moodmend** : 사용자가 직접 `감정일기(Emotion Diary)`를 작성하면, 그 내용에 따라 명상 콘텐츠 중에서 **사용자 감정에 맞는 영상이나 음원을 추천**해주는 모바일 기반의 앱입니다.

- Moodmend의 서비스 흐름을 바탕으로 실제 서비스 운영에 적합한 **ERD**를 설계하고, **SQL 쿼리와 프로시저가 요구사항대로 정확하게 실행되는지 테스트**하는 데 중점을 두었습니다.

---

## 📅 프로젝트 기간  

**2025.06.05 ~ 2025.06.09**

---

## 🎯 기획 의도 및 배경  
<br>

### <div align="center"> Mood + Amend = _"감정을 개선하다."_ </div>

<br>

명상이라는 주제가 다소 생소할 수 있으므로, **사용자 참여를 높이고 플랫폼의 지속성을 유지하기 위해** 다양한 부가 기능도 함께 설계했습니다.

- 티처 (명상 제작자)를 위한 디지털 콘텐츠 판매 공간 마련
- 명상 클래스 강의 수강 시스템을 통한 꾸준하고 체계적인 명상 훈련 가능
- 출석과 포인트 지급을 통한 유저 확보 및 보상 서비스
- 아바타, 커뮤니티 게시판, 친구 맺기 등의 재미 요소 추가

이러한 요소를 통해 **사용자 참여를 유도하고, 명상 콘텐츠의 접근성을 높이는 것**이 핵심 방향입니다.

---

## 🧩 기능 구조 및 테이블 분류  

| 도메인        | 관련 테이블 |
|---------------|-------------|
| 회원관리      | `members`, `friend` |
| 콘텐츠        | `contents`, `likes`, `downloads`, `emotion`, `owned`, `payment_detail`, `reports` |
| 구매          | `cart`, `payment`, `payment_detail`, `owned` |
| 주문          | `payment`, `payment_detail` |
| 플레이리스트  | `playlist`, `playlist_detail` |
| 재화          | `members`, `point_reward` |
| 보상          | `attendance`, `point_reward` |
| 아이템        | `items`, `owned`, `payment`, `payment_detail`, `cart` |
| 아바타        | `avatar`, `avatar_items_map`, `items`, `post` |
| 게시판        | `post`, `post_likes` |
| 감정 다이어리 | `emotion_diary`, `emotion` |
| 명상 클래스   | `meditation_class`, `class_reservation`, `class_feedback` |

---

## 📎 프로젝트 주요 산출물  

각 항목은 클릭하여 확인하거나 다운로드할 수 있습니다.

- ✅ [요구사항 정의서](https://docs.google.com/spreadsheets/d/1lFGjxB9mXCP0s3Rz3rKsKB5AYQrcu9vMIBpgAjZERnI/edit#gid=1298947418)  
- ✅ [WBS (Work Breakdown Structure)](https://docs.google.com/spreadsheets/d/1lFGjxB9mXCP0s3Rz3rKsKB5AYQrcu9vMIBpgAjZERnI/edit#gid=0)  
- ✅ [ERD 설계 이미지 보기](https://www.erdcloud.com/d/M7TAEEmzaw7qiSWE2)
<br>
<p align="center">
  <img src="./Moodmend/images/ERD/ERD_Moodmend.png" width="2000" alt="Moodmend ERD"/>
</p>

---

## ❓ ERD 설계 시 고민했던 사항들과 해결 방안

---

### 1️⃣ 감정 카테고리 충돌 방지

- 초기 설계에서는 `감정`이라는 카테고리가 유저의 `감정 일기장`과 티처(판매자)의 `명상 콘텐츠`
  <br>모두에서 중복 사용되면서, **키 충돌** 문제가 발생할 가능성이 있었습니다.

- 이를 방지하기 위해 `emotion`이라는 **공통 감정 카테고리 테이블**을 생성하고,  
  `emotion_diary`와 `contents`가 이를 **각각 외래키로 참조**하도록 설계했습니다.

- 이 구조를 통해 감정 기준의 **일관성**을 확보하고,
  **추천 알고리즘에서 충돌 없이 동일한 감정 기준**을 적용할 수 있게 되었습니다.

---

### 2️⃣ 사용자 보유 내역 `owned` 테이블 설계

- 처음에는 `payment_detail`만으로 유저의 콘텐츠 및 아이템 보유 여부를 파악하려 했습니다.
  
- 그러나 결제는 단순한 **이력 정보**이고, 보유는 **현재 상태**이기 때문에 이 방식은 한계가 있습니다.

- 예를 들어, 콘텐츠가 **환불**되거나, 아이템의 **사용 기한이 만료**되는 경우  
  단순히 결제 내역만으로는 **정확한 소유 여부를 판단하기 어렵습니다.**

- 이를 해결하기 위해 `owned`라는 **보유 내역 전용 테이블**을 별도로 설계했습니다.  
  이 테이블은 `payment_detail`과 연결되어 있으며, 유저가 **현재 보유 중인 콘텐츠/아이템을 명확하게 관리**할 수 있습니다.

---

## 📄 프로시저 테스트 결과

<details>
<summary>▶️ 프로시저 테스트</summary>

### 01. 회원가입 프로시저
<p align="center">
  <img src="./Moodmend/images/Test_Query/R001_회원가입.png" width="800" alt="회원가입 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 회원가입 (
  IN p_name VARCHAR(20),
  IN p_password VARCHAR(255),
  IN p_phone_number VARCHAR(20),
  IN p_nickname VARCHAR(20),
  IN p_birthday DATE,
  IN p_email VARCHAR(50),
  IN p_role ENUM('Admin', 'Teacher', 'User'),
  IN p_signup_type ENUM('Email', 'Kakao', 'Google', 'Naver')
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE phone_number = p_phone_number OR email = p_email
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '이미 등록된 이메일 또는 전화번호입니다.';
  ELSE
    INSERT INTO members (
      name, password, phone_number, nickname, birthday, email,
      role, signup_type, created_at, updated_at, point
    )
    VALUES (
      p_name, p_password, p_phone_number, p_nickname, p_birthday, p_email,
      p_role, p_signup_type, NOW(), NOW(), 0
    );
  END IF;
END$$

DELIMITER ;
```

### 02. 로그인 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R002_로그인.png" width="800" alt="로그인 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 로그인 (
  IN p_login_id VARCHAR(50), -- 이메일 또는 전화번호
  IN p_password VARCHAR(255)
)
BEGIN
  IF EXISTS (
    SELECT 1 FROM members 
    WHERE (email = p_login_id OR phone_number = p_login_id)
      AND password = p_password
  ) THEN
    SELECT members_id, name, nickname FROM members 
    WHERE (email = p_login_id OR phone_number = p_login_id)
      AND password = p_password;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '로그인 정보가 일치하지 않습니다.';
  END IF;
END$$

DELIMITER ;


```

### 03. 콘텐츠 등록 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R003_콘텐츠_등록.png" width="800" alt="콘텐츠 등록 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 콘텐츠_등록(
    IN p_members_id BIGINT,
    IN p_emotion_id BIGINT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_thumbnail TEXT,
    IN p_duration INT,
    IN p_is_premium ENUM('일반', '프리미엄'),
    IN p_video_url TEXT,
    IN p_price INT UNSIGNED
)
BEGIN
    IF p_is_premium = '프리미엄' AND p_price = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '프리미엄 콘텐츠는 가격이 0원이 될 수 없습니다.';
    END IF;

    IF p_is_premium = '일반' AND p_price != 0 THEN
        SET p_price = 0;
    END IF;

    INSERT INTO contents (
        members_id,
        emotion_id,
        name,
        description,
        thumbnail,
        duration,
        is_premium,
        views,
        price,
        video_url
    ) VALUES (
        p_members_id,
        p_emotion_id,
        p_name,
        p_description,
        p_thumbnail,
        p_duration,
        p_is_premium,
        0,
        p_price,
        p_video_url
    );
END $$

DELIMITER ;

select * from contents;
```

### 04. 좋아요 등록 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R004_좋아요_누르기.png" width="800" alt="좋아요 누르기 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 좋아요_등록(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요 등록 중 오류 발생(롤백 수행됨)';
    END;

    START TRANSACTION;

    -- 중복 좋아요 방지: 트랜잭션 내에서도 확인
    IF EXISTS (
        SELECT 1 FROM likes
        WHERE members_id = p_members_id AND contents_id = p_contents_id
        FOR UPDATE
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 좋아요를 누르셨습니다.';
    END IF;

    INSERT INTO likes (members_id, contents_id)
    VALUES (p_members_id, p_contents_id);

    COMMIT;
END $$

DELIMITER ;
```


### 05. 좋아요 취소 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R005_좋아요_취소.png" width="800" alt="좋아요 취소 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 좋아요_취소(
    IN p_members_id BIGINT,
    IN p_contents_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요 취소 중 오류 발생(롤백 수행됨)';
    END;

    START TRANSACTION;

    -- 좋아요 눌렀는지 확인 및 잠금
    IF NOT EXISTS (
        SELECT 1 FROM likes
        WHERE members_id = p_members_id AND contents_id = p_contents_id
        FOR UPDATE
    ) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '좋아요를 누른 기록이 없습니다.';
    END IF;

    DELETE FROM likes
    WHERE members_id = p_members_id AND contents_id = p_contents_id;

    COMMIT;
END $$

DELIMITER ;
```

### 06. 특정 카테고리 콘텐츠 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R006_특정_카테고리_콘텐츠_조회.png" width="800" alt="특정 카테고리 콘텐츠 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 카테고리별_콘텐츠_조회(
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
```

### 07. 콘텐츠 신고 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R007_콘텐츠_신고.png" width="800" alt="콘텐츠 신고 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 콘텐츠_신고 (
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
```

### 08. 장바구니 추가 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R008_장바구니_추가.png" width="800" alt="장바구니 추가 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 장바구니_관리 (
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
```

### 09. 콘텐츠 구매 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R009_콘텐츠_구매.png" width="800" alt="콘텐츠 구매 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 콘텐츠 구매 (
    IN p_members_id BIGINT,
    IN p_payment_method ENUM('신용카드', '휴대폰', '계좌이체')
)
BEGIN
    DECLARE v_total INT UNSIGNED;
    DECLARE v_payment_id BIGINT;
    DECLARE v_cart_contents_id BIGINT;
    DECLARE v_cart_items_id BIGINT;

    -- [1] 유효한 결제 대상이 하나만 존재하는지 확인
    IF NOT EXISTS (
        SELECT 1 FROM cart
        WHERE members_id = p_members_id
          AND ((contents_id IS NOT NULL AND items_id IS NULL) OR (contents_id IS NULL AND items_id IS NOT NULL))
          AND total IS NOT NULL AND total > 0
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '결제할 항목이 없습니다.';
    END IF;

    -- [2] 유효한 데이터 1개를 가져옴 (정확한 조건 포함)
    SELECT contents_id, items_id, total
    INTO v_cart_contents_id, v_cart_items_id, v_total
    FROM cart
    WHERE members_id = p_members_id
      AND ((contents_id IS NOT NULL AND items_id IS NULL) OR (contents_id IS NULL AND items_id IS NOT NULL))
      AND total IS NOT NULL AND total > 0
    LIMIT 1;

    -- [3] payment 테이블 기록
    INSERT INTO payment (
        members_id, items_id, payment_method, total_price
    )
    VALUES (
        p_members_id, v_cart_items_id, p_payment_method, v_total
    );

    SET v_payment_id = LAST_INSERT_ID();

    -- [4] 콘텐츠 결제 처리
    IF v_cart_contents_id IS NOT NULL THEN
        INSERT INTO payment_detail (
            contents_id, payment_id, purchase_type, price
        )
        VALUES (
            v_cart_contents_id, v_payment_id, '콘텐츠 구매', v_total
        );

        INSERT INTO owned (
            members_id, contents_id, payment_detail_id, source_type
        )
        VALUES (
            p_members_id, v_cart_contents_id, LAST_INSERT_ID(), '결제'
        );
    END IF;

    -- [5] 아이템 결제 처리
    IF v_cart_items_id IS NOT NULL THEN
        INSERT INTO payment_detail (
            items_id, payment_id, purchase_type, price
        )
        VALUES (
            v_cart_items_id, v_payment_id, '아이템 구매', v_total
        );

        INSERT INTO owned (
            members_id, items_id, payment_detail_id, source_type
        )
        VALUES (
            p_members_id, v_cart_items_id, LAST_INSERT_ID(), '결제'
        );
    END IF;

    -- [6] 장바구니 비우기
    DELETE FROM cart 
    WHERE members_id = p_members_id;
END $$

DELIMITER ;
```

### 10. 상세구매내역 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R010_상세구매내역_조회.png" width="800" alt="상세구매내역 조회 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 주문_상세_조회 (
    IN p_payment_id BIGINT
)
BEGIN
    SELECT 
        pd.payment_detail_id,
        pd.purchase_type,
        pd.price,
        c.name AS contents_name
    FROM payment_detail pd
    LEFT JOIN contents c ON pd.contents_id = c.contents_id
    WHERE pd.payment_id = p_payment_id;
END $$

DELIMITER ;
```

### 11. 플레이리스트 생성 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R011_플레이리스트_생성(수동).png" width="800" alt="플레이리스트 생성 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$

CREATE PROCEDURE 플레이리스트_기능 (
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

```

### 12. 플레이리스트 등록 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R012_플레이리스트_등록.png" width="800" alt="플레이리스트 등록 프로시저 테스트 결과"/>
</p>

```sql
call moodmend.플레이리스트_기능('create', 3, 1, '성후의 플레이리스트', '나의 명상!', 1, 2);


```

### 13. 신규유저 100포인트 지급 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R013_신규유저_100포인트_지급(수동).png" width="800" alt="신규유저 100포인트 지급 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$


DELIMITER ;
```

### 14. 포인트 지급내역 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R014_포인트_지급내역_조회.png" width="800" alt="포인트 지급내역 조회 프로시저 테스트 결과"/>
</p>

```sql
회원등록 하면 자동으로 지급
select * from members;
```

### 15. 아이템 등록 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R015_아이템_등록(수동).png" width="800" alt="아이템 등록 프로시저 테스트 결과"/>
</p>

```sql
select * from items;
insert into items(members_id, items_name, items_category, items_price, items_desc, items_thumbnail, graphic_source)
values(1, '곱슬머리', '헤어', 50, '한정판입니다.', 'url', 'url');
```

### 16. 아이템 구매 보유내역 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R016_아이템구매_보유내역조회.png" width="800" alt="아이템 구매 보유내역 조회 프로시저 테스트 결과"/>
</p>

```sql
call moodmend.보유내역조회(3);
```



### 17. 아바타 등록 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R017_아바타_등록.png" width="800" alt="아바타 등록 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 아바타_조회_수정_등록 (
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
```

### 18. 게시판 등록, 게시판 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R018_게시판_등록_게시판_조회.png" width="800" alt="게시판 등록, 게시판 조회 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 게시판_등록 (
  IN p_members_id BIGINT,
  IN p_title VARCHAR(50),
  IN p_text TEXT,
  IN p_category VARCHAR(10),
  IN p_is_anonymous BOOLEAN
)
BEGIN
  DECLARE v_avatar_id BIGINT;

  -- 유효 카테고리 검사
  IF p_category NOT IN ('고민', '질문', '좋은글', '자유') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '유효하지 않은 게시글 카테고리입니다.';
  END IF;

  -- 아바타 존재 확인
  IF NOT EXISTS (
    SELECT 1 FROM avatar WHERE members_id = p_members_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '해당 멤버는 등록된 아바타가 없습니다.';
  END IF;

  -- 아바타 ID 조회
  SELECT avatar_id INTO v_avatar_id
  FROM avatar
  WHERE members_id = p_members_id
  LIMIT 1;

  -- 게시글 등록
  INSERT INTO post (
    members_id, avatar_id, title, text, category, is_anonymous, created_at, updated_at
  ) VALUES (
    p_members_id, v_avatar_id, p_title, p_text, p_category, p_is_anonymous, NOW(), NOW()
  );
END$$

DELIMITER ;
```


### 19. 감정 다이어리 기록, 감정 다이어리 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R019_감정_다이어리_기록_다이어리_조회_셀렉트문.png" width="800" alt="감정 다이어리 기록, 다이어리 조회 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 감정_다이어리_기록 (
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
select * from emotion_diary;
```

### 20. 감정 기반 콘텐츠 추천 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R020_감정기반_콘텐츠_추천.png" width="800" alt="감정기반 콘텐츠 추천 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 감정_기반_콘텐츠_추천 (
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
```

### 21. 출석기록, 출석조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R021_출석기록_출석조회.png" width="800" alt="출석기록, 출석조회 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 출석_기록 (
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

CREATE PROCEDURE 출석_조회 (
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
```

### 22. 클래스 개설 및 상태설정 클래스 조회 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R022_클래스_개설_및_상태설정_클래스_조회.png" width="800" alt="클래스 개설 및 상태설정 클래스 조회 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 클래스_개설_및_상태설정 (
    IN p_members_id BIGINT,
    IN p_title VARCHAR(50),
    IN p_category VARCHAR(20),
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_limit INT
)
BEGIN
    DECLARE v_now DATETIME;
    DECLARE v_status ENUM('개강전','모집중','정원초과','모집완료');

    SET v_now = NOW();

    IF p_start_time > v_now THEN
        SET v_status = '모집중';
    ELSE
        SET v_status = '개강전';
    END IF;

    INSERT INTO meditation_class (
        members_id, title, category,
        start_time, end_time, `limit`, status
    ) VALUES (
        p_members_id, p_title, p_category,
        p_start_time, p_end_time, p_limit, v_status
    );
END $$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE 클래스_조회()
BEGIN
    SELECT 
        mc.meditation_class_id,
        mc.title,
        mc.category,
        mc.start_time,
        mc.end_time,
        mc.limit,
        mc.status,
        m.nickname AS teacher
    FROM meditation_class mc
    JOIN members m ON mc.members_id = m.members_id
    ORDER BY mc.start_time DESC;
END $$

DELIMITER ;
```


### 23. 클래스 신청 프로시저

<p align="center">
  <img src="./Moodmend/images/Test_Query/R023_클래스_신청_셀렉트문.png" width="800" alt="클래스 신청 프로시저 테스트 결과"/>
</p>

```sql
DELIMITER $$
CREATE PROCEDURE 클래스_신청 (
    IN p_members_id BIGINT,
    IN p_meditation_class_id BIGINT
)
BEGIN
    DECLARE v_count INT;

    -- 현재 예약 인원 수 확인
    SELECT COUNT(*) INTO v_count
    FROM class_reservation
    WHERE meditation_class_id = p_meditation_class_id;

    -- 중복 예약 여부 확인
    IF EXISTS (
        SELECT 1 FROM class_reservation
        WHERE members_id = p_members_id
          AND meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이미 해당 클래스를 신청하셨습니다.';
    END IF;

    -- 정원 초과 여부 확인 (limit 예약어 처리)
    IF v_count >= (
        SELECT `limit` FROM meditation_class
        WHERE meditation_class_id = p_meditation_class_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '정원이 초과되었습니다.';
    END IF;

    -- 예약 등록
    INSERT INTO class_reservation (meditation_class_id, members_id)
    VALUES (p_meditation_class_id, p_members_id);
END $$

DELIMITER ;
```

</details>

---


## 💡 기대 효과  

- 감정 기반 콘텐츠 큐레이션으로 **추천 정확도 향상**  
- 출석, 포인트, 보상, 커뮤니티 기능을 통해 **지속적인 사용자 참여 유도**  
- **명상 콘텐츠 소비 및 확산 기반 마련**

---

## 🔨 기술 스택  

<p align="left">
  <img src="https://img.shields.io/badge/ERDCloud-1F1F1F?style=for-the-badge&logo=cloud&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/MARIADB-003545?style=for-the-badge&logo=mariadb&logoColor=white" />
  <img src="https://img.shields.io/badge/MYSQL-005C84?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL%20Workbench-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/GIT-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white" />
</p>

---

## 👥 팀원 및 역할 분장  

<table>
  <tr>
    <th>이름</th>
    <th>역할</th>
  </tr>
  <tr>
    <td align="center">
      <img src="/Moodmend/images/Profile/임성후.png" width="80"/><br/>
      <a href="https://github.com/dev-s3lim" target="_blank" style="text-decoration: none; color: inherit;">
        임성후
      </a>
    </td>
    <td>
      <code>기획</code>, <code>요구사항서 작성</code>, <code>WBS 작성</code>, <code>ERD 설계</code>, <code>DDL 및 DML 작성</code>,  
      <code>GitHub 배포</code>, <code>테스트</code>, <code>ReadMe</code>, <code>발표</code>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/Moodmend/images/Profile/조민형.png" width="80"/><br/>
      <a href="https://github.com/jominhyeong97" target="_blank" style="text-decoration: none; color: inherit;">
        조민형
      </a>
    </td>
    <td>
      <code>기획</code>, <code>요구사항서 작성</code>, <code>WBS 작성</code>, <code>ERD 설계</code>, <code>DDL 및 DML 작성</code>,  
      <code>GitHub 배포</code>, <code>테스트</code>, <code>ReadMe</code>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/Moodmend/images/Profile/이승지.png" width="80"/><br/>
      <a href="https://github.com/SeungJi20" target="_blank" style="text-decoration: none; color: inherit;">
        이승지
      </a>
    </td>
    <td>
      <code>기획</code>, <code>요구사항서 작성</code>, <code>WBS 작성</code>, <code>ERD 설계</code>, <code>DDL 및 DML 작성</code>,  
      <code>GitHub 배포</code>, <code>테스트</code>, <code>ReadMe</code>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="/Moodmend/images/Profile/김지현.png" width="80"/><br/>
      <a href="https://github.com/userkimjihyeon" target="_blank" style="text-decoration: none; color: inherit;">
        김지현
      </a>
    </td>
    <td>
      <code>기획</code>, <code>요구사항서 작성</code>, <code>WBS 작성</code>, <code>ERD 설계</code>, <code>DDL 및 DML 작성</code>,  
      <code>GitHub 배포</code>, <code>테스트</code>
    </td>
  </tr>
</table>




---

> “당신의 하루를 닮은 플랫폼 - Moodmend”

---

<p align="center"><strong>Moodmend · 감정 중심 명상 콘텐츠 플랫폼 DB 설계 프로젝트</strong></p>
<p align="center"><em>본 문서는 Team Moodmend가 성실히 설계하고 제출한 결과물입니다.</em></p>
<p align="center"><strong>감사합니다.</strong></p>
