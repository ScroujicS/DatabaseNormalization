--проверка на кол-во null значений
select 
    count(case when date is null then 1 end) as date_is_null_count, --0
    count(case when service is null then 1 end) as service_is_null_count, --8820 - количество пропусков /получилось заполнить пропуски
    count(case when service_addr is null then 1 end) as service_addr_is_null_count, --8897 - количество пропусков /получилось заполнить пропуски
    count(case when w_name is null then 1 end) as w_name_is_null_count, --4451 - количество пропусков /получилось заполнить пропуски
    count(case when w_exp is null then 1 end) as w_exp_is_null_count, --4426 - количество пропусков /получилось заполнить пропуски
    count(case when w_phone is null then 1 end) as w_phone_is_null_count, --4410 - количество пропусков /получилось заполнить пропуски
    count(case when wages is null then 1 end) as wages_is_null_count, --4430 - количество пропусков /получилось заполнить пропуски
    count(case when card is null then 1 end) as card_is_null_count, --5961 - количество пропусков /НЕ получилось заполнить пропуски
    count(case when payment is null then 1 end) as payment_is_null_count, --5818 - количество пропусков /НЕ получилось заполнить пропуски
    count(case when pin is null then 1 end) as pin_is_null_count, --5938 - количество пропусков /НЕ получилось заполнить пропуски
    count(case when name is null then 1 end) as name_is_null_count, --2066 - количество пропусков /получилось заполнить пропуски
    count(case when phone is null then 1 end) as phone_is_null_count, --1981 - количество пропусков /получилось заполнить пропуски
    count(case when email is null then 1 end) as email_is_null_count, --1951 - количество пропусков /получилось заполнить пропуски
    count(case when password is null then 1 end) as password_is_null_count, --1923 - количество пропусков /получилось заполнить пропуски
    count(case when car is null then 1 end) as car_is_null_count, --2035 - количество пропусков /получилось заполнить пропуски
    count(case when mileage is null then 1 end) as mileage_is_null_count, --1971 - количество пропусков /получилось заполнить пропуски
    count(case when vin is null then 1 end) as vin_is_null_count, --1872 - количество пропусков /получилось заполнить пропуски
    count(case when car_number is null then 1 end) as car_number_is_null_count, --1954 - количество пропусков /получилось заполнить пропуски
    count(case when color is null then 1 end) as color_is_null_count --1964 - количество пропусков /получилось заполнить пропуски
from e880bb33_dedublicate ebd;


-- заполнение пропусков
update e880bb33_dedublicate ebd
set service = (select eb.service from e880bb33 eb where eb.w_name = ebd.w_name and eb.service is not null limit 1)
where ebd.service is null;

update e880bb33_dedublicate ebd 
set service_addr = (select eb.service_addr from e880bb33 eb where eb.w_name = ebd.w_name and eb.service_addr is not null limit 1)
where ebd.service_addr is null;

update e880bb33_dedublicate ebd
set w_name = (select eb.w_name from e880bb33 eb where eb.w_phone = ebd.w_phone and eb.w_name is not null limit 1)
where ebd.w_name is null;

update e880bb33_dedublicate ebd
set w_exp = (select eb.w_exp from e880bb33 eb where eb.w_name = ebd.w_name and eb.w_exp is not null limit 1)
where ebd.w_exp is null;

update e880bb33_dedublicate ebd
set w_phone = (select eb.w_phone from e880bb33 eb where eb.w_name = ebd.w_name and eb.w_phone is not null limit 1)
where ebd.w_phone is null;

update e880bb33_dedublicate ebd
set wages = (select eb.wages from e880bb33 eb where eb.w_name = ebd.w_name and eb.wages is not null limit 1)
where ebd.wages is null;

update e880bb33_dedublicate ebd
set email = (select eb.email from e880bb33 eb where eb.name = ebd.name and eb.email is not null limit 1)
where ebd.email is null;

update e880bb33_dedublicate ebd
set phone = (select eb.phone from e880bb33 eb where eb.name = ebd.name and eb.phone is not null limit 1)
where ebd.phone is null;

update e880bb33_dedublicate ebd
set password = (select eb.password from e880bb33 eb where eb.name = ebd.name and eb.password is not null limit 1)
where ebd.password is null;

update e880bb33_dedublicate ebd
set car = (select eb.car from e880bb33 eb where eb.name = ebd.name and eb.car is not null limit 1)
where ebd.car is null;

update e880bb33_dedublicate ebd
set name = (select eb.name from e880bb33 eb where eb.email = ebd.email and eb.phone = ebd.phone and eb.name is not null limit 1)
where ebd.name is null;

update e880bb33_dedublicate ebd
set vin = (select eb.vin from e880bb33 eb where eb.car_number = ebd.car_number and eb.vin is not null limit 1)
where ebd.vin is null;

update e880bb33_dedublicate ebd
set car_number = (select eb.car_number from e880bb33 eb where eb.vin = ebd.vin and eb.car_number is not null limit 1)
where ebd.car_number is null;

update e880bb33_dedublicate ebd
set color = (select eb.color from e880bb33 eb where eb.car_number = ebd.car_number and eb.color is not null limit 1)
where ebd.color is null;

with Mileage as (
    select  
        id, vin, date, mileage,
        lag(mileage, 1, null) over (partition by vin order by date) as mileagePrev,
        lead(mileage, 1, null) over (partition by vin order by date) as mileageNext
    from e880bb33_dedublicate ebd
),
MileageNew as (
  select 
    id,
    case 
      when mileage is null and mileagePrev is not null then mileagePrev
      when mileage is null and mileageNext is not null then mileageNext
      else mileage
    end as new_mileage
  from Mileage
)
update e880bb33_dedublicate  
set mileage = new_mileage
from MileageNew
where e880bb33_dedublicate.id = MileageNew.id;

