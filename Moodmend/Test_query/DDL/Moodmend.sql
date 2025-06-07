CREATE TABLE members (
  members_id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL UNIQUE,
  nickname VARCHAR(20) NOT NULL UNIQUE,
  birthday DATE NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  role ENUM('Admin', 'Teacher', 'User') NOT NULL,
  signup_type ENUM('Email', 'Kakao', 'Google', 'Naver') NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  card VARCHAR(50) UNIQUE,
  bank VARCHAR(50),
  account_number VARCHAR(50),
  point INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (members_id)
);

CREATE TABLE emotion (
  emotion_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  emotion_name VARCHAR(30) NOT NULL UNIQUE,
  intensity TINYINT UNSIGNED NOT NULL
);

CREATE TABLE contents (
  contents_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  members_id BIGINT NOT NULL,
  emotion_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  upload_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  description TEXT NOT NULL,
  thumbnail TEXT NOT NULL,
  duration INT NOT NULL,
  is_premium ENUM('일반', '프리미엄') NOT NULL DEFAULT '일반',
  views BIGINT NOT NULL,
  price INT UNSIGNED NOT NULL DEFAULT 0,
  video_url TEXT NOT NULL,
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (emotion_id) REFERENCES emotion(emotion_id)
);

CREATE TABLE items (
  items_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  members_id BIGINT NOT NULL,
  items_name VARCHAR(30) NOT NULL,
  items_category ENUM('헤어', '상의', '하의', '신발', '악세서리', '테두리', '뱃지') NOT NULL,
  items_price INT NOT NULL,
  items_desc TEXT NOT NULL,
  items_thumbnail TEXT NOT NULL,
  graphic_source TEXT NOT NULL,
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE avatar (
  avatar_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  members_id BIGINT NOT NULL UNIQUE,
  avatar_name VARCHAR(50),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_default BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE avatar_items_map (
  avatar_items_map_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  avatar_id BIGINT NOT NULL,
  items_id BIGINT NOT NULL,
  FOREIGN KEY (avatar_id) REFERENCES avatar(avatar_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id)
);

CREATE TABLE attendance (
  attendance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  attendance_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  UNIQUE KEY unique_members_attendance_date (members_id, attendance_date)
);

CREATE TABLE emotion_diary (
  emotion_diary_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  members_id BIGINT,
  emotion_id BIGINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  contents TEXT NOT NULL,
  logged_at DATE NOT NULL DEFAULT (CURRENT_DATE),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (emotion_id) REFERENCES emotion(emotion_id),
  UNIQUE KEY unique_members_logged_at (members_id, logged_at)
);

CREATE TABLE friend (
  friend_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  status ENUM('friend', 'ignore') NOT NULL,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  nickname VARCHAR(30) NOT NULL,
  PRIMARY KEY (friend_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE likes (
  members_id BIGINT NOT NULL,
  contents_id BIGINT NOT NULL,
  PRIMARY KEY (members_id, contents_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);

CREATE TABLE download (
  download_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  contents_id BIGINT NOT NULL,
  members_id BIGINT NOT NULL,
  downloaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE owned (
  owned_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  members_id BIGINT NOT NULL,
  items_id BIGINT,
  contents_id BIGINT,
  payment_detail_id BIGINT NOT NULL,
  acquired_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source_type ENUM('결제', '보상') NOT NULL DEFAULT '결제',
  is_equipped BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (payment_detail_id) REFERENCES payment_detail(payment_detail_id),
  CONSTRAINT uc_owned_item UNIQUE (members_id, items_id),
  CONSTRAINT uc_owned_contents UNIQUE (members_id, contents_id),
  CHECK ((items_id IS NOT NULL AND contents_id IS NULL) OR (items_id IS NULL AND contents_id IS NOT NULL))
);

CREATE TABLE meditation_class (
  meditation_class_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  title VARCHAR(50) NOT NULL,
  category VARCHAR(20) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  `limit` INT NOT NULL,
  `status` ENUM('개강전','모집중','정원초과','모집완료') NOT NULL,
  PRIMARY KEY (meditation_class_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE class_reservation (
  class_reservation_id BIGINT NOT NULL AUTO_INCREMENT,
  meditation_class_id BIGINT NOT NULL,
  members_id BIGINT NOT NULL,
  reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (class_reservation_id),
  FOREIGN KEY (meditation_class_id) REFERENCES meditation_class(meditation_class_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE class_feedback (
  class_feedback_id BIGINT AUTO_INCREMENT,
  meditation_class_id BIGINT NOT NULL,
  class_reservation_id BIGINT UNIQUE NOT NULL,
  comment VARCHAR(255) NOT NULL,
  rating INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (class_feedback_id),
  FOREIGN KEY (meditation_class_id) REFERENCES meditation_class(meditation_class_id),
  FOREIGN KEY (class_reservation_id) REFERENCES class_reservation(class_reservation_id)
);

CREATE TABLE cart (
  cart_id BIGINT NOT NULL AUTO_INCREMENT,
  contents_id BIGINT,
  members_id BIGINT NOT NULL,
  items_id BIGINT,
  total INT UNSIGNED,
  PRIMARY KEY (cart_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id),
  CHECK ((contents_id IS NOT NULL AND items_id IS NULL) OR (contents_id IS NULL AND items_id IS NOT NULL))
);

CREATE TABLE payment (
  payment_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  items_id BIGINT NOT NULL,
  payment_method ENUM('신용카드','카카오페이','삼성페이','아이템') NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refund_date DATETIME,
  refund_require BOOLEAN DEFAULT FALSE,
  total_price INT UNSIGNED NOT NULL,
  PRIMARY KEY (payment_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id)
);

CREATE TABLE payment_detail (
  payment_detail_id BIGINT NOT NULL AUTO_INCREMENT,
  contents_id BIGINT,
  payment_id BIGINT NOT NULL,
  items_id BIGINT,
  purchase_type ENUM('콘텐츠 구매','아이템 구매') NOT NULL,
  price INT UNSIGNED NOT NULL,
  PRIMARY KEY (payment_detail_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id),
  FOREIGN KEY (payment_id) REFERENCES payment(payment_id),
  FOREIGN KEY (items_id) REFERENCES items(items_id)
);

CREATE TABLE post (
  post_id BIGINT NOT NULL AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  avatar_id BIGINT NOT NULL,
  views BIGINT,
  likes BIGINT,
  title VARCHAR(50) NOT NULL,
  `text` TEXT NOT NULL,
  category ENUM('고민','질문','좋은글','자유') NOT NULL,
  is_anonymous BOOLEAN NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (avatar_id) REFERENCES avatar(avatar_id)
);

CREATE TABLE post_likes (
  post_id BIGINT NOT NULL,
  members_id BIGINT NOT NULL,
  PRIMARY KEY (post_id, members_id),
  FOREIGN KEY (post_id) REFERENCES post(post_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE playlist (
  playlist_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  title VARCHAR(20) NOT NULL,
  description TEXT,
  is_public BOOLEAN NOT NULL,
  total_play_time TIME NOT NULL,
  playlist_share VARCHAR(255),
  FOREIGN KEY (members_id) REFERENCES members(members_id)
);

CREATE TABLE playlist_detail (
  pd_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  playlist_id BIGINT NOT NULL,
  contents_id BIGINT NOT NULL,
  FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);

CREATE TABLE point_reward (
  point_reward_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  members_id BIGINT NOT NULL,
  point_reward BIGINT NOT NULL DEFAULT 0,
  reward_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason TEXT NOT NULL,
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  UNIQUE KEY unique_members_reward_date (members_id, reward_date)
);

CREATE TABLE reports (
  members_id BIGINT NOT NULL,
  contents_id BIGINT NOT NULL,
  reason TEXT NOT NULL,
  reported_at DATETIME NOT NULL,
  status ENUM('검토 중', '처리완료', '반려') NOT NULL,
  PRIMARY KEY (members_id, contents_id),
  FOREIGN KEY (members_id) REFERENCES members(members_id),
  FOREIGN KEY (contents_id) REFERENCES contents(contents_id)
);
