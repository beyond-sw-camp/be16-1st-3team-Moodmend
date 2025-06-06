# 🧘‍♀️ Moodmend ERD 설계 프로젝트  
감정 기반 명상 콘텐츠 추천 플랫폼 **Moodmend**의 데이터베이스 모델링 프로젝트입니다.

---

## 📌 프로젝트 개요  
Moodmend는 감정 상태에 따라 맞춤 명상 콘텐츠를 추천하고,  
유저의 지속적인 참여를 유도하는 감정 기반 명상 플랫폼입니다.  
이번 프로젝트는 Moodmend의 서비스 흐름을 바탕으로 실제 서비스 운영에 적합한  
ERD(Entity Relationship Diagram)를 설계하고,
실제 SQL 쿼리와 프로시저가 요구사항대로 정확하게 실행되는지 테스트하는데에 중점을 두었습니다.

---

## 🎯 기획 의도 및 배경  
명상은 여전히 비주류로 인식되는 콘텐츠입니다. 이에 따라 다음과 같은 방향성을 중심으로 DB 구조를 설계했습니다:

- 감정 일기 기반 맞춤 추천 시스템  
- 프리미엄 콘텐츠 유료 판매 시스템  
- 출석 및 포인트 보상 기반 참여 유도  
- 아바타, 커뮤니티, 가상 시장, 실명 기반 채팅 등의 재미 요소 추가  

이를 통해 사용자 참여를 유도하고, 명상이라는 주제의 관심도와 접근성을 확장하고자 했습니다.

---

## 🧩 기능 구조 및 테이블 분류  

| 기능 영역        | 주요 기능                                        | 관련 테이블                                |
|------------------|--------------------------------------------------|--------------------------------------------|
| 사용자 관리       | 가입, 로그인, 초대코드, 탈퇴, 역할 관리              | `users`, `invites`, `roles`                |
| 감정 일기        | 감정 기록, 이모지 태그, 감정 분석 로그 자동 생성       | `diaries`, `emoji_tags`                    |
| 콘텐츠            | 콘텐츠 등록, 구매, 환불, 좋아요 기능                   | `contents`, `purchases`, `refunds`, `likes`|
| 포인트 및 보상    | 출석 체크, 포인트 적립 및 사용, 아바타 구매            | `points`, `attendance`, `avatars`          |
| 신고 및 제재      | 콘텐츠/게시글 신고, 관리자 처리 기록                  | `reports`, `report_logs`                   |

---

## 🗂️ ERD 모델 요약  

- `users`: 사용자 기본 정보 및 권한(일반 / 판매자 / 관리자) 저장  
- `diaries`: 사용자 감정 일기와 감정 태그 기록  
- `emoji_tags`: 감정 표현 이모지 태그 및 추천 연동  
- `contents`: 명상 콘텐츠 정보 (영상, 오디오 등)  
- `purchases`, `refunds`: 콘텐츠 유료 구매 및 환불 이력 관리  
- `likes`: 콘텐츠 좋아요 내역 저장  
- `points`: 포인트 적립 및 사용 내역  
- `attendance`: 출석 체크 기록  
- `avatars`: 아바타 구매 및 사용자 연동  
- `reports`, `report_logs`: 실명 기반 신고 및 처리 이력  
- `invites`, `roles`: 초대 코드 및 권한 분류  

---

## 💡 기대 효과  

- 감정 기반 콘텐츠 큐레이션으로 추천 정확도 향상  
- 게임화 요소(출석, 포인트, 보상 등)로 지속적인 유저 참여 유도  
- 실명 기반 커뮤니티로 사용자 간 신뢰 확보  
- 명상 콘텐츠의 소비와 확산을 위한 기반 마련  

---


### 🔨 기술 스택

[![MySQL](https://img.shields.io/badge/MYSQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Git](https://img.shields.io/badge/GIT-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![GitHub](https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![MariaDB](https://img.shields.io/badge/MARIADB-003545?style=for-the-badge&logo=mariadb&logoColor=white)](https://mariadb.org/)

---

## 👥 팀원 및 역할 분장  

- **김지현**: (내용입력)  
- **이승지**: (내용입력)  
- **조민형**: (내용입력)  
- **임성후**: (내용입력)  

<p align="center">
  <img src="./images/members/kimjihyun.jpg" width="120"/>
  <img src="./images/members/leesungji.jpg" width="120"/>
  <img src="./images/members/jominhyung.jpg" width="120"/>
  <img src="./images/members/limseonghoo.jpg" width="120"/>
</p>

---

> “감정을 데이터로 설계하다 - Moodmend”

---

<p align="center"><strong>Moodmend · 감정 중심 명상 콘텐츠 플랫폼 DB 설계 프로젝트</strong></p>
<p align="center"><em>본 문서는 Team Moodmend가 성실히 설계하고 제출한 결과물입니다.</em></p>
<p align="center"><strong>감사합니다.
