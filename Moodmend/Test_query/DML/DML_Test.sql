-- #1. 회원관리_회원가입 프로시저

-- #2. 회원관리_로그인 프로시저

-- #3. 콘첸츠_등록 프로시저
select * from emotion;
insert into emotion(emotion_name, intensity) values ('슬픔', 1);

-- #4. 좋아요_등록 프로시저

-- #5. 좋아요_취소 프로시저

-- #6. 
select * from contents where emotion_id = 1;

-- #7. 콘텐츠_신고

-- #8. 장바구니_관리

-- #9. 결제_진행

-- #10. 주문상세조회

-- #11. 
select * from playlist;
insert into playlist(members_id, title, description, is_public, total_play_time, playlist_share) values (4, '안정을찾을때', '힘들고 슬플때 들으려구', 0, 20, 'url');

-- #12. 플레이리스트_기능(action=add)

-- #13. 최초가입 유저 100포인트 지급
select * from point_reward;
insert into point_reward (members_id, point_reward, reason) values (5, 100, '신규 유저');

-- #14. 포인트 사용 및 지급 내역 조회

-- #15. 관리자의 아이템 등록
select * from items;
insert into items(members_id, items_name, items_category, items_price, items_desc, items_thumbnail, graphic_source)
values(1, '곱슬머리', '헤어', 50, '한정판입니다.', 'url', 'url');