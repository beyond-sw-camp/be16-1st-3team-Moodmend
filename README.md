# Moodmend Platform - DB 설계 프로젝트 제출 문서

<p align="center">
  <img src="./images/moodmend_logo.png" width="200" alt="Moodmend Logo"/>
</p>

> 📦 **요약**  
> - 감정 데이터 기반의 명상 콘텐츠 서비스 ‘Moodmend’의 DB 설계 프로젝트입니다.  
> - 사용자 중심의 흐름, 정규화된 데이터 구조, 트랜잭션 기반 기록 방식이 특징입니다.  
> - 본 문서는 ERD 설계부터 테스트 쿼리까지, 실제 서비스에 적용 가능한 수준의 DB 구현을 담고 있습니다.

---

## 프로젝트 개요

**Moodmend**는 사용자 감정 데이터를 기반으로 한 명상 콘텐츠 제공 플랫폼입니다.  
본 프로젝트는 해당 플랫폼 구축을 위한 데이터 중심의 구조 설계, 정규화된 테이블 구성,  
그리고 사용자 흐름에 최적화된 DB 아키텍처 정의를 목표로 진행되었습니다.

- **프로젝트명**: Moodmend
- **주요 목적**: 감정 데이터 기반 명상 콘텐츠 추천 플랫폼 설계
- **수행 조직**: 한화시스템 Beyond SW 16기 - 3팀
- **작업 기간**: 2025년 6월 5일 ~ 2025년 6월 8일

---

## 설계 배경 및 방향성

1. **감정 데이터의 구조화**
   - 감정 일기를 통한 정성 데이터를 정량화 가능하게 저장
   - 분석 로그를 기반으로 콘텐츠 추천 로직과 연계
   - 사용자 입력과 시스템 분석 결과를 분리 저장하여 확장성과 유지보수 용이성 확보

2. **정규화된 관계형 데이터 모델**
   - 핵심 테이블(사용자, 콘텐츠, 구매, 포인트, 신고 등) 간 관계 명확화
   - 불필요한 중복 제거 및 데이터 일관성 확보

3. **확장 가능한 사용자 구조**
   - 일반 사용자 / 크리에이터 / 관리자 3단계 권한 체계 구축
   - 역할별 기능 분리를 통해 서비스 내 업무 분담 가능성 고려

4. **서비스 흐름 기반 DB 설계**
   - 사용자 행동 흐름(기록 → 분석 → 추천 → 구매/보상)과 DB 구조를 직접 연결

---

## 핵심 기능 정의 및 테이블 분류

| 기능 영역      | 주요 기능                          | 관련 테이블 요약 |
|-------------|----------------------------------|-----------------|
| 사용자 관리    | 가입/로그인/초대/탈퇴/권한 관리             | users, invites, roles |
| 감정 일기     | 감정 기록, 감정 분석 로그 자동 생성           | diaries, emoji_tags |
| 콘텐츠         | 콘텐츠 등록, 구매, 환불, 좋아요               | contents, purchases, refunds, likes |
| 포인트/보상   | 출석 체크, 포인트 지급/차감, 아바타 구매        | points, attendance, avatars |
| 신고 및 제재   | 콘텐츠 신고, 게시판 신고, 관리자 처리           | reports, report_logs |

---

## ERD 모델 요약

설계된 ERD는 사용자 중심의 전체 흐름을 반영하며, 기능별 핵심 엔티티 간 관계를 명확히 표현합니다.

- 감정 기록(`diaries`)과 감정 분석 결과(`emoji_tags`)는 역할이 다르므로 분리 설계
  - `diaries`: 사용자가 직접 입력한 감정 서술 기록
  - `emoji_tags`: 이모지로 감정 분류
- 콘텐츠 구매/환불/보상 흐름은 트랜잭션 기반 이력 관리
- 신고/좋아요 등은 복합 유니크 제약조건 설정으로 중복 방지 설계
- 포인트 흐름은 `points` 테이블을 통해 수치적 추적 가능

<p align="center">
  <img src="./images/ERD_Diagram.png" width="800" alt="Moodmend ERD"/>
</p>

---

## DML 쿼리 및 테스트 흐름

모든 테이블은 실제 서비스 흐름 기반의 테스트 시나리오로 검증하였으며,  
테스트용 INSERT / UPDATE / DELETE 쿼리를 포함합니다.

📂 [DML 테스트 SQL 보기](./sql/Test_DML.sql)

예시:
```sql
-- 감정 일기 작성
INSERT INTO diaries (user_id, emotion, content, created_at)
VALUES (1, '기쁨', '산책을 하며 기분이 좋아졌다.', NOW());

-- 콘텐츠 구매
INSERT INTO purchases (user_id, content_id, purchased_at)
VALUES (1, 1001, NOW());

-- 출석 포인트 지급
INSERT INTO attendance (user_id, check_date)
VALUES (1, CURDATE());

-- 감정 일기 수정
UPDATE diaries
SET content = '햇볕을 쬐며 마음이 한결 가벼워졌다.'
WHERE id = 1;

-- 콘텐츠 구매 취소 (환불 처리)
DELETE FROM purchases
WHERE user_id = 1 AND content_id = 1001;
```

---

## 산출물 문서 정리

- [요구사항 명세서](./docs/Project_Plan_and_Requirements.pdf)
- [ERD 이미지](./images/ERD_Diagram.png)
- [DB 아키텍처 설명서](./docs/DB_Architecture.md)
- [DML 테스트 쿼리](./sql/Test_DML.sql)
- [WBS 업무 분장표](./docs/WBS.xlsx)

---

## 작업 체계 및 역할 분장

본 프로젝트는 기능군 단위로 책임을 분장하여 협업 구조를 구성했습니다.

- **김지현**: 
- **이승지**: 
- **조민형**: 
- **임성후**: 

<p align="center">
  <img src="./images/members/kimjihyun.jpg" width="120"/>
  <img src="./images/members/leesungji.jpg" width="120"/>
  <img src="./images/members/jominhyung.jpg" width="120"/>
  <img src="./images/members/limseonghoo.jpg" width="120"/>
</p>

---

## 결론 및 기대 효과

Moodmend는 감정 기반 서비스라는 고유한 컨셉을 구조적 데이터 흐름으로 구체화한 프로젝트입니다.  
데이터 설계 단계부터 서비스 흐름을 반영함으로써 기능 확장성과 안정성을 모두 확보하였으며,  
이후 실제 서비스 구현 단계로의 확장 또한 용이하도록 구조화되었습니다.

> “데이터로 감정을 이해하다 - Moodmend”

---

<p align="center"><strong>Moodmend · 감정 중심 명상 콘텐츠 플랫폼 DB 설계 프로젝트</strong></p>

<br/>

<p align="center"><em>본 문서는 Team Moodmend가 성실히 설계하고 제출한 결과물입니다.</em></p>

<p align="center"><strong>감사합니다.<br/>Team Moodmend 일동</strong></p>
