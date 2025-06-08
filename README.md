# 🧘‍♀️ Moodmend DB 프로젝트

감정 기반 명상 콘텐츠 추천 플랫폼 **Moodmend**의 데이터베이스 모델링 프로젝트입니다.

&nbsp;

<p align="center">
  <img src="./Moodmend/images/logo/moodmend_logo.png" width="1000" alt="Moodmend Logo"/>
</p>

---

## 📌 프로젝트 개요  

**Moodmend**는 감정 상태에 따라 맞춤 명상 콘텐츠를 추천하고, 유저의 지속적인 참여를 유도하는 감정 기반 명상 플랫폼입니다.  
이번 프로젝트는 Moodmend의 서비스 흐름을 바탕으로 **실제 서비스 운영에 적합한 ERD(Entity Relationship Diagram)를 설계**하고,  
**SQL 쿼리와 프로시저가 요구사항대로 정확하게 실행되는지 테스트**하는 데 중점을 두었습니다.

---

## 📅 프로젝트 기간  

**2025.06.05 ~ 2025.06.09**

---

## 🎯 기획 의도 및 배경  

명상은 여전히 비주류로 인식되는 콘텐츠입니다.  
Moodmend는 다음과 같은 핵심 목표를 중심으로 설계되었습니다:

- 감정 일기 기반 맞춤 추천 시스템  
- 프리미엄 콘텐츠 유료 판매 시스템  
- 출석 및 포인트 보상 기반 참여 유도  
- 아바타, 커뮤니티, 가상 시장, 실명 기반 채팅 등 재미 요소 추가  

이러한 요소를 통해 **사용자 참여를 유도하고, 명상 콘텐츠의 접근성과 확산을 높이는 것**이 핵심 방향입니다.

---

## 🧩 기능 구조 및 테이블 분류  

| 도메인        | 관련 테이블 |
|---------------|-------------|
| 회원관리      | `members`, `friend`, `logout_log` |
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

## 🗂️ ERD 모델 요약  

> ✏️ 추후 입력 예정

---

## 📎 프로젝트 주요 산출물  

각 항목은 클릭하여 확인하거나 다운로드할 수 있습니다.

- ✅ [요구사항 정의서](https://docs.google.com/spreadsheets/d/1lFGjxB9mXCP0s3Rz3rKsKB5AYQrcu9vMIBpgAjZERnI/edit#gid=1298947418)  
- ✅ [WBS (Work Breakdown Structure)](https://docs.google.com/spreadsheets/d/1lFGjxB9mXCP0s3Rz3rKsKB5AYQrcu9vMIBpgAjZERnI/edit#gid=0)  
- ✅ ERD 설계 이미지 보기 (링크 추가 예정)  
- ✅ 테스트용 DML 쿼리 파일 다운로드 (링크 추가 예정)

---

## 💡 기대 효과  

- 감정 기반 콘텐츠 큐레이션으로 **추천 정확도 향상**  
- 출석, 포인트, 보상, 커뮤니티 기능을 통해 **지속적인 사용자 참여 유도**  
- **명상 콘텐츠 소비 및 확산 기반 마련**

---

## 🔨 기술 스택  

<p align="left">
  <img src="https://img.shields.io/badge/MYSQL-005C84?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/MARIADB-003545?style=for-the-badge&logo=mariadb&logoColor=white" />
  <img src="https://img.shields.io/badge/GIT-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white" />
</p>

---

## 👥 팀원 및 역할 분장  

| 이름 | 역할 |
|------|------|
| 김지현 | (내용입력) |
| 이승지 | (내용입력) |
| 조민형 | (내용입력) |
| 임성후 | (내용입력) |

<p align="center">
  <img src="./images/members/kimjihyun.jpg" width="120" />
  <img src="./images/members/leesungji.jpg" width="120" />
  <img src="./images/members/jominhyung.jpg" width="120" />
  <img src="./images/members/limseonghoo.jpg" width="120" />
</p>

---

> “당신의 하루를 닮은 플랫폼 - Moodmend”

---

<p align="center"><strong>Moodmend · 감정 중심 명상 콘텐츠 플랫폼 DB 설계 프로젝트</strong></p>
<p align="center"><em>본 문서는 Team Moodmend가 성실히 설계하고 제출한 결과물입니다.</em></p>
<p align="center"><strong>감사합니다.</strong></p>
