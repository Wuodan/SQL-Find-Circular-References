drop table if exists billproductattribute;
drop table if exists billproduct;
drop table if exists bill;
drop table if exists productinhousehold;
drop table if exists productattribut;
drop table if exists product;
drop table if exists household;

create table household(
    id int not null auto_increment primary key,
    name varchar(255) not null,
    street varchar(255) not null,
    zip varchar(255) not null,
    city varchar(255) not null
);

create table product(
    id int not null auto_increment primary key,
    name varchar(255) not null
);

create table productattribut(
    id int not null auto_increment primary key,
    idproduct int not null,
    name varchar(255) not null,
    unit varchar(255) not null,
    constraint fk_productattribut_product foreign key (idproduct) references product(id)
);

create table productinhousehold(
    id int not null auto_increment primary key,
    idproduct int not null,
    idhousehold int not null,
    constraint fk_productinhousehold_product foreign key (idproduct) references product(id),
    constraint fk_productinhousehold_household foreign key (idhousehold) references household(id)
);

create table bill(
    id int not null auto_increment primary key,
    idhousehold int not null,
    serialnumber char(36) not null unique default (uuid()),
    constraint fk_bill_household foreign key (idhousehold) references household(id)
);

create table billproduct(
    id int not null auto_increment primary key,
    idbill int not null,
    idproductinhousehold int not null,
    cost decimal(38, 2) not null,
    constraint fk_billproduct_bill foreign key (idbill) references bill(id),
    constraint fk_billproduct_productinhousehold foreign key (idproductinhousehold) references productinhousehold(id)
);

create table billproductattribute(
    id int not null auto_increment primary key,
    idbillproduct int not null,
    idproductattribut int not null,
    value decimal(38, 2) not null,
    constraint fk_billproductattribute_billproduct foreign key (idbillproduct) references billproduct(id),
    constraint fk_billproductattribute_productattribut foreign key (idproductattribut) references productattribut(id)
);
