-- DDL

-- sunghoo 스키마 생성
CREATE DATABASE sunghoo
DEFAULT CHARACTER SET utf8mb4

-- sunghoo 스키마 사용
USE sunghoo;


-- sunghoo 스키마 하위의 contents 테이블 생성
-- contents 테이블은 티처(콘텐츠 크리에이터)가 업로드한 콘텐츠 정보를 저장
CREATE TABLE contents (
    contents_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id     BIGINT NOT NULL,
    emotion_id    BIGINT NOT NULL,
    name          VARCHAR(100) NOT NULL,
    upload_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description   TEXT NOT NULL,
    thumbnail     TEXT NOT NULL,
    duration      INT NOT NULL,
    is_premium    ENUM('일반', '프리미엄') NOT NULL DEFAULT '일반',
    views         BIGINT NOT NULL,
    price         INT UNSIGNED NOT NULL DEFAULT 0,
    video_url     TEXT NOT NULL,

    -- 외래키 제약
    CONSTRAINT fk_contents_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_contents_emotion FOREIGN KEY (emotion_id) REFERENCES emotion(emotion_id)
);

-- sunghoo 스키마 하위의 reports 테이블 생성
-- reports 테이블은 회원이 콘텐츠를 신고할 때 사용
CREATE TABLE reports (
    members_id     BIGINT NOT NULL,
    contents_id   BIGINT NOT NULL,
    reason        TEXT NOT NULL,
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    status        ENUM('검토 중', '처리완료', '반려') NOT NULL,

    -- 복합 기본 키로 중복 신고 방지
    PRIMARY KEY (members_id, contents_id),

    -- 외래키 제약 (members와 contents 연결)
    CONSTRAINT fk_reports_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_reports_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);

CREATE TABLE likes (
    members_id     BIGINT NOT NULL,
    contents_id   BIGINT NOT NULL,

    -- 복합 기본키: 중복 좋아요 방지
    PRIMARY KEY (members_id, contents_id),

    -- 외래키 설정
    CONSTRAINT fk_likes_members FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_likes_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);


-- sunghoo 스키마 하위의 download 테이블 생성
-- download 테이블은 회원이 콘텐츠를 다운로드할 때 사용
CREATE TABLE download (
    download_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    contents_id    BIGINT NOT NULL,
    members_id     BIGINT NOT NULL,
    downloaded_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- 외래키 제약
    CONSTRAINT fk_download_contents FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
    CONSTRAINT fk_download_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);


-- sunghoo 스키마 하위의 avatar 테이블 생성
-- avatar 테이블은 회원의 아바타 정보를 저장
-- 아바타는 회원당 하나만 가질 수 있으며, 기본 아바타 여부를 나타내는 is_default 컬럼이 있음
CREATE TABLE avatar (
    avatar_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id    BIGINT NOT NULL UNIQUE,
    avatar_name   VARCHAR(50),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_default    BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_avatar_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);


-- sunghoo 스키마 하위의 avatar_items_map 테이블 생성
CREATE TABLE avatar_items_map (
    avatar_items_map_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    avatar_id           BIGINT NOT NULL,
    items_id            BIGINT NOT NULL,

    CONSTRAINT fk_aim_avatar FOREIGN KEY (avatar_id) REFERENCES avatar(avatar_id),
    CONSTRAINT fk_aim_items FOREIGN KEY (items_id) REFERENCES items(items_id)
);


-- sunghoo 스키마 하위의 items 테이블 생성
CREATE TABLE items (
    items_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id       BIGINT NOT NULL,
    items_name       VARCHAR(30) NOT NULL,
    items_category   ENUM('헤어', '상의', '하의', '신발', '악세서리', '테두리', '뱃지') NOT NULL,
    items_price      INT NOT NULL,
    items_desc       TEXT NOT NULL,
    items_thumbnail  TEXT NOT NULL,
    graphic_source   TEXT NOT NULL,

    CONSTRAINT fk_items_members FOREIGN KEY (members_id) REFERENCES members(members_id)
);


-- sunghoo 스키마 하위의 owned 테이블 생성
-- owned 테이블은 회원이 소유한 아이템과 콘텐츠 정보를 저장
-- 소유한 아이템과 콘텐츠는 각각 items_id와 contents_id로 연결되며, 결제 상세 정보(payment_detail_id)도 포함
CREATE TABLE owned (
    owned_id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    members_id         BIGINT NOT NULL,
    items_id           BIGINT NULL,
    contents_id        BIGINT NULL,
    payment_detail_id  BIGINT NOT NULL,
    acquired_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source_type        ENUM('결제', '보상') NOT NULL DEFAULT '결제',
    is_equipped        BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_owned_members         FOREIGN KEY (members_id) REFERENCES members(members_id),
    CONSTRAINT fk_owned_items           FOREIGN KEY (items_id) REFERENCES items(items_id),
    CONSTRAINT fk_owned_contents        FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
    CONSTRAINT fk_owned_payment_detail  FOREIGN KEY (payment_detail_id) REFERENCES payment_detail(payment_detail_id),

    CONSTRAINT uc_owned_item     UNIQUE (members_id, items_id),
    CONSTRAINT uc_owned_contents UNIQUE (members_id, contents_id)
);
