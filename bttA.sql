-- PHÂN TÍCH NGHIỆP VỤ 
-- hệ thống cần quản lý những đối tượng như : người dùng, sản phẩm, danh mục, đơn hàng, chi tiết đơn hàng 
-- dữ liệu có thể thay đổi theo thời gian : thông tin khách hàng , thông tin sản phẩm , trạng thái tồn kho
-- dữ liệu cần lưu lịch sử cố định : 
-- Giá sản phẩm tại thời điểm mua (Snapshot Price): Giá thực tế mà khách hàng đã trả.
-- Địa chỉ giao hàng tại thời điểm đặt (Snapshot Address): Địa chỉ cụ thể đơn hàng được gửi đến.
-- Thời gian giao dịch: Ngày giờ tạo đơn, ngày thanh toán.
-- Trạng thái đơn hàng: Nhật ký thay đổi từ khi đặt đến khi hoàn tất hoặc hủy.

-- PHÂN LOẠI DỮ LIỆU : 
-- dữ liệu thay đổi : dữ liệu phản ánh trạng thái hiện tại , khi có sự cập nhật , giá trị cũ sẽ bị ghi đè 
-- dữ liệu cố định : là dữ liệu mang tính lịch sử , khi đã ghi nhận thì không thay đổi 

-- PHÂN TÍCH VẤN ĐỀ HỆ THỐNG 
-- Vì sao dữ liệu địa chỉ bị thay đổi trong đơn hàng cũ là sai 
-- mất dấu nhận đơn : đơn hàng trong quá khứ đã được giao đến địa chỉ A, nhưng khách hàng chuyển nhà đến địa chỉ B , hệ thôngs cập nhật toàn bộ địa chỉ thành địa chỉ B , khi đó sẽ mất dấu vết 
-- đơn hàng đã giao thành công 
-- Vì sao giá sản phẩm không được dùng trực tiếp khi truy vấn lại đơn hàng 
-- sự sai lệch doanh thu
 -- khi bán vật phẩm này ở tháng 1 là giá 10 tr nhưng tháng 2 đã tăng giá lên 12 tr thì khi đó báo cáo tài chính sẽ bị độn ảo lên 2tr 
 -- Vì sao cần kiểm tra tồn kho trước khi tạo đơn 
 -- tránh việc đơn hàng bị treo , khi cho phép khách hàng đặt hàng khi tồn kho bằng 0 , đơn hàng sẽ bị treo và khách hàng sẽ ko nhận được hàng 

CREATE DATABASE RikkeiSoft;
USE RikkeiSoft;

create table  Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    current_address VARCHAR(255)
);

create table  Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

create table Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(255) NOT NULL,
    current_price DECIMAL(15,2) NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

create table Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status varchar(20) DEFAULT 'Pending', -- pending, cancelled, paid 
    shipping_address VARCHAR(255) NOT NULL,
    total_money DECIMAL(15,2) DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

create table Order_Details (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

insert into Users (full_name, email, phone, current_address)
values 
	('Nguyen Van A', 'a@gmail.com', '0901', 'Hanoi'),
	('Tran Thi B', 'b@gmail.com', '0902', 'HCMC'),
	('Le Van C', 'c@gmail.com', '0903', 'Danang'),
	('Pham D', 'd@gmail.com', '0904', 'Hue'),
	('Vu E', 'e@gmail.com', '0905', 'Can Tho');

insert into Categories (category_name) 
values 
	('Electronics'), 
	('Clothing'),
	('Books');

insert into  Products (category_id, product_name, current_price, stock)
values 
	(1, 'Laptop Dell', 1000.00, 10),
	(1, 'iPhone 15', 800.00, 20),
	(2, 'T-Shirt', 20.00, 100),
	(3, 'SQL Book', 30.00, 50),
	(1, 'Mouse', 15.00, 200);

insert into Orders (user_id, status, shipping_address, total_money)
values 
	(1, 'Paid', 'Hanoi', 1800.00),
	(2, 'Pending', 'HCMC', 20.00),
	(3, 'Cancelled', 'Danang', 30.00),
	(4, 'Paid', 'Hue', 30.00),
	(1, 'Paid', 'Hanoi', 1000.00);

insert into Order_Details (order_id, product_id, quantity, unit_price)
values 
	(1, 1, 1, 1000.00),
	(1, 2, 1, 800.00),
	(2, 3, 1, 20.00),
	(3, 4, 1, 30.00),
	(4, 5, 2, 15.00),
	(5, 1, 1, 1000.00);
    
select o.order_id, o.order_date, u.full_name, o.total_money
from orders o
join users u on o.user_id = u.user_id;

select p.*
from products p
join categories c on p.category_id = c.category_id
where c.category_name = 'electronics';

select user_id, full_name, email from users;

select sum(total_money) as system_total_revenue from orders;

select p.product_id, p.product_name, sum(od.quantity) as total_quantity
from products p
join order_details od on p.product_id = od.product_id
group by p.product_id, p.product_name;

select p.product_id, p.product_name, sum(od.quantity) as total_quantity
from products p
join order_details od on p.product_id = od.product_id
group by p.product_id, p.product_name
order by total_quantity desc
limit 1;

select o.order_id, u.full_name, o.total_money, sum(od.quantity) as total_items
from orders o
join users u on o.user_id = u.user_id
join order_details od on o.order_id = od.order_id
group by o.order_id, u.full_name, o.total_money;

select * from products
where product_id not in (select distinct product_id from order_details);

select u.user_id, u.full_name, count(o.order_id) as total_orders
from users u
join orders o on u.user_id = o.user_id
group by u.user_id, u.full_name;

select * from products
where current_price > (select avg(current_price) from products);

select u.user_id, u.full_name, sum(o.total_money) as total_spent
from users u
join orders o on u.user_id = o.user_id
group by u.user_id, u.full_name
having sum(o.total_money) > (
select avg(user_spent)
from (select sum(total_money) as user_spent from orders group by user_id) as avg_table
);

select * from orders order by total_money desc limit 1;

select c.category_name, sum(od.quantity * od.unit_price) as total_revenue
from categories c
join products p on c.category_id = p.category_id
join order_details od on p.product_id = od.product_id
group by c.category_id, c.category_name
order by total_revenue desc
limit 1;

select p.product_id, p.product_name, sum(od.quantity) as total_quantity
from products p
join order_details od on p.product_id = od.product_id
group by p.product_id, p.product_name
order by total_quantity desc, p.product_id asc
limit 3;

select * from users
where user_id not in (select distinct user_id from orders); 