create extension if not exists pgcrypto;

drop table if exists billproductattribute cascade;
drop table if exists billproduct cascade;
drop table if exists bill cascade;
drop table if exists productinhousehold cascade;
drop table if exists productattribut cascade;
drop table if exists product cascade;
drop table if exists household cascade;

create table household(
    id integer generated always as identity primary key,
    name varchar(255) not null,
    street varchar(255) not null,
    zip varchar(255) not null,
    city varchar(255) not null
);

create table product(
    id integer generated always as identity primary key,
    name varchar(255) not null
);

create table productattribut(
    id integer generated always as identity primary key,
    idproduct integer not null references product(id),
    name varchar(255) not null,
    unit varchar(255) not null
);

create table productinhousehold(
    id integer generated always as identity primary key,
    idproduct integer not null references product(id),
    idhousehold integer not null references household(id)
);

create table bill(
    id integer generated always as identity primary key,
    idhousehold integer not null references household(id),
    serialnumber uuid not null unique default gen_random_uuid()
);

create table billproduct(
    id integer generated always as identity primary key,
    idbill integer not null references bill(id),
    idproductinhousehold integer not null references productinhousehold(id),
    cost numeric(38, 2) not null
);

create table billproductattribute(
    id integer generated always as identity primary key,
    idbillproduct integer not null references billproduct(id),
    idproductattribut integer not null references productattribut(id),
    value numeric(38, 2) not null
);
