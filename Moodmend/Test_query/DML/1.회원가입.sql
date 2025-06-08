-- 1. 회원가입

-- 멤버 (유저) 테이블 생성
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



