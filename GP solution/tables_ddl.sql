/*
    All tables were created in Greenplum dialect. Most of the columns were taken from enumerated required cols in task description.
    As requested there are some columns with some relevant to tables information. 

    Designed database corresponds to 3NF for several reasons:
     - It corresponds to 1NF and 2NF;
     - There are not transitive dependencies between non key  attributes in tables;
    
    * In `customers`, `products` and `sales_transactions` tables there are primary key columns 
    which requires `serial primary key` type of column.     
    * The type of column `numeric` used in columns which requires precise calculation of price or quantity.
    * `varchar` column type, used in columns that require string format but has a size limitation
    * Column type `integer`, used in columns as foreign keys that refer to directory tables
*/

create table customers (
    customer_id serial primary key, 
    customer_name varchar(100) not null,
    email_address varchar(100) unique not null,
    country varchar(50) not null,
    phone_number varchar(20), -- phone number of customer
    registration_date date default current_date, -- date of registration 
    is_active boolean default true -- client activity status
);

create table products (
    product_id serial primary key,
    prodcut_name varchar(100) not null,
    price numeric(10, 2) not null,
    category varchar(50),
    description text, -- description of product
    stock_quantity numeric(10, 2) not null, -- quantity left on stock
    date_added date default current_date -- date the product was added
);

create table sales_transactions (
    transaction_id serial primary key,
    customer_id integer not null,
    product_id integer not null,
    purchase_date date not null,
    quantity numeric(10, 2) not null,
    total_amount numeric(12, 2), -- total transaction amount (price x quantity)
    payment_method varchar(50), -- the method of payment used to pay for the products
    constraint fk_customer foreign key (customer_id) references customers(customer_id), -- fk for customer_id
    constraint fk_product foreign key (product_id) references products(product_id) -- fk for product_id
);

create table shipping_details (
    transaction_id integer not null,
    shipping_date date not null,
    shipping_address varchar(255) not null,
    city varchar(100),
    country varchar(50),
    tracking_number varchar(50), -- tracking number of shipping 
    recipient_phone varchar(20), -- phone number of recipient
    shipping_status varchar(50) default 'Pending', -- status of shipping
    constraint fk_transaction foreign key (transaction_id) references sales_transactions(transaction_id) -- fk for transaction_id
);
