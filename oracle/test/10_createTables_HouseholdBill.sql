whenever sqlerror exit sql.sqlcode

create table HouseHold(
    id number generated always as identity primary key,
    name varchar2(255) not null,
    street varchar2(255) not null,
    zip varchar2(255) not null,
    city varchar2(255) not null
);

create table Product(
    id number generated always as identity primary key,
    name varchar2(255) not null
);

create table ProductAttribut(
    id number generated always as identity primary key,
    idProduct number not null references Product(id),
    name varchar2(255) not null,
    unit varchar2(255) not null
);

create table ProductInHouseHold(
    id number generated always as identity primary key,
    idProduct number not null references Product(id),
    idHousehold number not null references HouseHold(id)
);

create table Bill(
    id number generated always as identity primary key,
    idHouseHold number not null references HouseHold(id),
    serialNumber varchar2(36) default lower(rawtohex(sys_guid())) not null unique
);

create table BillProduct(
    id number generated always as identity primary key,
    idBill number not null references Bill(id),
    idProductInHouseHold number not null references ProductInHouseHold(id),
    cost number(38, 2) not null
);

create table BillProductAttribute(
    id number generated always as identity primary key,
    idBillProduct number not null references BillProduct(id),
    idProductAttribut number not null references ProductAttribut(id),
    value number(38, 2) not null
);

exit
