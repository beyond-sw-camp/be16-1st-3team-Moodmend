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

-- 게시판 테이블 생성
create table post(post_id bigint not null auto_increment, members_id bigint not null, avatar_id bigint not null, views bigint, likes bigint, title varchar(50) not null, `text` text not null, category enum('고민','질문','좋은글','자유') not null, 
is_anonymous boolean not null, created_at datetime not null default current_timestamp, updated_at datetime current_timestamp, 
primary key(post_id), foreign key(members_id) references members(members_id), foreign key(avatar_id) references avatar(avatar_id));

-- 게시글 좋아요 테이블 생성
create table post_likes(post_id bigint not null, members_id bigint not null, 
primary key(post_id, members_id));

