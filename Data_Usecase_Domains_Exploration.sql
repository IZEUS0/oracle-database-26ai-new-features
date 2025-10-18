--Creating and Implementing Data Usecase Domains
-- Drop the domain if it already exists
drop domain if exists price force;

-- Creating a single column domain
create domain price as number
constraint price check (value > 0);

-- Drop the domain if it already exists
drop domain if exists coordinates force;

-- Creating a multi-column domain
create domain coordinates as (
    latitude  as number,
    longitude as number,
    location_name as varchar2 (100)
)
constraint coordinates check (latitude between -90 and 90 and longitude between -180 and 180);

-- Drop the Data Usecase Domains if they already exists
drop domain if exists personal_contact_dom force;
drop domain if exists business_contact_dom force;
drop domain if exists default_contact_dom force;

-- Personal contact domain
create domain personal_contact_dom as (
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)
)
constraint personal_contact_dom check (first_name is not null and 
                                       phone is not null);

-- Business contact domain
create domain business_contact_dom as (
    company_name   as varchar2(100),
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)

)
constraint business_contact_dom check (first_name is not null and 
                                       phone is not null);

-- Default contact domain
create domain default_contact_dom as (
    first_name     as varchar2(50),
    last_name      as varchar2(50),
    email          as varchar2(100),
    phone          as varchar2(20)
)
constraint default_contact_dom check (first_name is not null and 
                                       phone is not null);

-- Flexible domain to choose contact based on type
create flexible domain contact_flex_dom (company_name, first_name, last_name, email, phone)
choose domain using (contact_type varchar2(100))
from case
    when contact_type = 'personal' then personal_contact_dom(first_name, last_name, email, phone)
    when contact_type = 'business' then business_contact_dom(company_name, first_name, last_name, email, phone)
    else default_contact_dom(first_name, last_name, email, phone)
end;

select name as "System provided domains" from all_domains where owner = 'SYS';

--Implementing and Utilizing Data Usecase Domains in Tables for Data Management
-- Drop table with single column domain if exists
drop table if exists products purge;

-- Table with single column domain
create table products (
    product_id   number,
    name         varchar2(100),
    price        price          -- User defined domain
);

-- Drop table with multi-column domain if exists
drop table if exists locations purge;

-- Table with multi-column domain
create table locations (
    location_id     number,
    latitude        number,
    longitude       number,
    location_name   varchar2(100),
    domain  coordinates(latitude, longitude, location_name)    -- User defined domain
);

-- Drop table with flexible domain if exists
drop table if exists contacts purge;

-- Table with flexible domain
create table contacts (
    contact_id     number,
    contact_type   varchar2(100),
    company_name   varchar2(100),
    first_name     varchar2(50),
    last_name      varchar2(50),
    email          varchar2(100),
    phone          varchar2(20),
    domain         contact_flex_dom(company_name, first_name, last_name, email, phone) using (contact_type) -- User defined domain
);

-- Inserting data into products table
insert into products (product_id, name, price) values (1, 'Widget', 10.99);
insert into products (product_id, name, price) values (2, 'Gadget', -5.99); -- This will fail

-- Inserting data into locations table with multi-column domain
insert into locations (location_id, location_name, latitude, longitude) 
values (1, 'Headquarters', 100.7749, -122.4194); -- This will fail 

insert into locations (location_id, location_name, latitude, longitude) 
values (2, 'Branch Office', 40.7128, -74.0060);


-- Inserting a personal contact
insert into contacts (contact_id, contact_type, first_name, last_name, email, phone)
values (1, 'personal', 'John', 'Doe', 'john.doe@example.com', 1231231231);

drop domain if exists order_status_domain;

create domain order_status_domain as
enum (
pending,
processing,
shipped,
delivered
);

select * from order_status_domain;

drop domain if exists order_status_domain;

create domain order_status_domain as
enum (
pending = 5,
processing = 6,
shipped = 7,
delivered = 8
);

select * from order_status_domain;

drop table if exists orders;

create table orders (
id          number generated always as identity primary key,
customer    varchar2(100),
product     varchar2(100),
status      order_status_domain
);


insert into orders (customer, product, status) 
values 
        ('Alice', 'Laptop', order_status_domain.pending),
        ('Bob', 'Smartphone', order_status_domain.processing),
        ('Charlie', 'Headphones', order_status_domain.shipped),
        ('Diana', 'Monitor', order_status_domain.delivered);

select id, customer, product, domain_display(status) as status from orders;

--Viewing our Data Usecase Domains
select * from USER_DOMAIN_CONSTRAINTS;
--
drop table if exists products purge;
drop table if exists locations purge;
drop table if exists contacts purge;
drop table if exists orders purge;
drop domain if exists personal_contact_dom force;
drop domain if exists business_contact_dom force;
drop domain if exists default_contact_dom force;
drop domain if exists order_status_domain force;