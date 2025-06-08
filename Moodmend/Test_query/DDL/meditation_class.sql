-- 명상수업 테이블 생성
create table meditation_class(meditation_class_id bigint not null auto_increment, members_id bigint not null, title varchar(50) not null, category varchar(20) not null, 
start_time datetime not null, end_time datetime not null, `limit` int not null, `status` enum("개강전","모집중","정원초과","모집완료") not null,
primary key (meditation_class_id), foreign key (members_id) references members(members_id));

-- 수업후기 테이블 생성
create table class_feedback(class_feedback_id bigint auto_increment, meditation_class_id bigint not null, class_reservation_id bigint unique not null, 
comment varchar(255) not null, rating int unsigned not null, created_at datetime default current_timestamp, 
 primary key(class_feedback_id), foreign key (meditation_class_id) references meditation_class(meditation_class_id), 
foreign key (class_reservation_id) references class_reservation(class_reservation_id));

-- 수업예약 테이블 생성
create table class_reservation(class_reservation_id bigint not null auto_increment, meditation_class_id bigint not null, members_id bigint not null, reserved_at datetime default current_timestamp, 
primary key(class_reservation_id), foreign key(meditation_class_id) references meditation_class(meditation_class_id), foreign key(members_id) references members(members_id));

-- 장바구니 테이블 생성
create table cart(cart_id bigint not null auto_increment, contents_id bigint unique, members_id bigint not null, items_id bigint unique, total int unsigned, 
primary key(cart_id), foreign key(contents_id) references contents(contents_id), foreign key(members_id) references members(members_id), foreign key(items_id) references items(items_id));

-- 결제 테이블 생성
create table payment(payment_id bigint not null auto_increment, members_id bigint not null, items_id bigint not null, payment_method enum('신용카드','카카오페이','삼성페이','아이템') not null, 
payment_date datetime not null default current_timestamp, refund_date datetime, refund_require boolean default false, total_price int unsigned not null, 
primary key(payment_id), foreign key(members_id) references members(members_id), foreign key(items_id) references items(items_id));

-- 결제완료 상세내역 테이블(연결 테이블) 생성
create table payment_detail(payment_detail_id bigint not null auto_increment, contents_id bigint, payment_id bigint not null, items_id bigint, purchase_type enum('콘텐츠 구매','아이템 구매') not null, price int unsigned not null, 
primary key(payment_detail_id), foreign key(contents_id) references contents(contents_id), foreign key(payment_id) references payment(payment_id), foreign key(items_id) references items(items_id));

-- 게시판 테이블 생성
create table post(post_id bigint not null auto_increment, members_id bigint not null, avatar_id bigint not null, views bigint, likes bigint, title varchar(50) not null, `text` text not null, category enum('고민','질문','좋은글','자유') not null, 
is_anonymous boolean not null, created_at datetime not null default current_timestamp, updated_at datetime current_timestamp, 
primary key(post_id), foreign key(members_id) references members(members_id), foreign key(avatar_id) references avatar(avatar_id));

-- 게시글 좋아요 테이블 생성
create table post_likes(post_id bigint not null, members_id bigint not null, 
primary key(post_id, members_id));

