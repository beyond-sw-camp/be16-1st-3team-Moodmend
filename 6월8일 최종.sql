select * from items;
select * from payment_detail;
describe payment_detail;
select * from payment;


insert into payment_detail(payment_id, contents_id items_id, purchase_type, price) values (2, 2, '아이템 구매', 30);
update members set point = 70;
select members.point, owned.* from owned inner join members on owned.members_id = members.members_id where owned_id = 1;

select * from post;
describe post;