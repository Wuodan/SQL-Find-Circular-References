use sql_circular_references
go

if object_id('BillProductAttribute', 'U') is not null
	drop table BillProductAttribute
if object_id('BillProduct', 'U') is not null
	drop table BillProduct
if object_id('Bill', 'U') is not null
	drop table Bill
if object_id('ProductInHouseHold', 'U') is not null
	drop table ProductInHouseHold
if object_id('ProductAttribut', 'U') is not null
	drop table ProductAttribut
if object_id('Product', 'U') is not null
	drop table Product
if object_id('HouseHold', 'U') is not null
	drop table HouseHold
go

create table HouseHold(
	id int identity not null primary key,
	name varchar(255) not null,
	street varchar(255) not null,
	zip varchar(255) not null,
	city varchar(255) not null
)
go

create table Product(
	id int identity not null primary key,
	name varchar(255) not null
)
go

create table ProductAttribut(
	id int identity not null primary key,
	idProduct int not null foreign key references Product(id),
	name varchar(255) not null,
	unit varchar(255) not null
)
go

create table ProductInHouseHold(
	id int identity not null primary key,
	idProduct int not null foreign key references Product(id),
	idHousehold int not null foreign key references Household(id),
)

create table Bill(
	id int identity not null primary key,
	idHouseHold int not null foreign key references HouseHold(id),
	serialNumber uniqueidentifier not null unique default(newid())
)

create table BillProduct(
	id int identity not null primary key,
	idBill int not null foreign key references Bill(id),
	idProductInHouseHold int not null foreign key references ProductInHouseHold(id),
	cost decimal(38, 2) not null
)

create table BillProductAttribute(
	id int identity not null primary key,
	idBillProduct int not null foreign key references BillProduct(id),
	idProductAttribut int not null foreign key references ProductAttribut(id),
	value decimal(38, 2) not null
)