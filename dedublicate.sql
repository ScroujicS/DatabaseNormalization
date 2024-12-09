--создаем новую таблицу без дубликатов
create table e880bb33_dedublicate (
	id serial primary key,
    date date,
    service text,
    service_addr text,
    w_name text,
    w_exp INT,
    w_phone text,
    wages INT,
    card text,
    payment text,
    pin text,
    name text,
    phone text,
    email text,
    password text,
    car text,
    mileage INT,
    vin text,
    car_number text,
    color text
);

--меняем формат даты в исходной таблице
alter table public.e880bb33 alter column "date" type date using "date"::date;

--добавляем данные в новую таблицу (без дупликатов)
insert into e880bb33_dedublicate (id, date, service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email, password, car, mileage, vin, car_number, color)
select 
    row_number () over (order by date) as id ,
    date , service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email, password, car,
    mileage, vin, car_number, color
from (
    select distinct  date, service, service_addr, w_name, w_exp, w_phone, wages, card, payment, pin, name, phone, email,
    password, car, mileage, vin, car_number, color
    from e880bb33 
    )
order by date;



