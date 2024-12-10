--создание и заполнение таблиц
create table carService (carServiceID serial primary key, address text, region text);
insert into carService (address, region)
select distinct service_addr, service
from e880bb33_dedublicate;

create table cars (carID serial primary key, carVin text, carNumber text, carModel text, carColour text);
insert into cars (carVin, carNumber,carModel,carColour)
select distinct vin, car_number, car, color
from e880bb33_dedublicate;

create table employees (emplID serial primary key, empFirstlName text, emplSecondName text, emplExp int, emplPhone text, emplWages int);
insert into employees (empFirstlName, emplSecondName, emplExp, emplPhone, emplWages)
select distinct 
  coalesce(split_part(w_name, ' ', 1), ''),
  coalesce(case when position(' ' in w_name) > 0 then split_part(w_name, ' ', 2) else '' end, ''),
  w_exp,
  w_phone,
  wages
from e880bb33_dedublicate;

create table clients (clientID serial primary key, clientFirstName text, clientSecondName text, clientPhone text, clientEmail text, clientPassword text);
insert into clients (clientFirstName, clientSecondName, clientPhone, clientEmail, clientPassword)
select distinct 
  coalesce(split_part(name, ' ', 1), ''),
  coalesce(case when position(' ' in name) > 0 then split_part(name, ' ', 2) else '' end, ''),
  phone,
  email,
  password
from e880bb33_dedublicate;

create table orders (orderID serial primary key, clientID int references clients(clientID), emplID int references employees(emplID), carServiceID int references carService(carServiceID), carID int references cars (carID), date date, mileage int, payment text, card text, pin text);
insert into orders (clientID, emplID, carServiceID, carID, date, mileage, payment, card, pin)
select cl.clientID, e.emplID, cs.carServiceID, c.carID, ebd.date, ebd.mileage, ebd.payment, ebd.card, ebd.pin
from e880bb33_dedublicate ebd
JOIN clients cl on cl.clientFirstName || ' ' || cl.clientSecondName = ebd.name and cl.clientEmail = ebd.email
join employees e on e.empFirstlName || ' ' || e.emplSecondName = ebd.w_name and emplPhone = ebd.w_phone
JOIN carService cs on cs.region = ebd.service and cs.address = ebd.service_addr 
JOIN cars c on c.carVin = ebd.vin;


--добавление индексов
create index clientIndex on clients (clientEmail);
create index empoyeeIndex on employees (emplPhone);
create index carServiceIndex on carService (region);
create index carIndex on cars (carVin);
create index orderIndex on orders (date);


--добавление связей
alter table orders
add constraint clientFK
foreign key (clientID)
references clients(clientID)
on delete cascade,
add constraint employeesFK
foreign key (emplID)
references employees(emplID)
on delete cascade,
add constraint carServicesFK
foreign key (carServiceID)
references carService(carServiceID)
on delete cascade,
add constraint carsFK
foreign key (carID)
references cars(carID)
on delete cascade;
