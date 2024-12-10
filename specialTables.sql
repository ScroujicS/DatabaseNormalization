--добавление скидок для 10 лучших клиентов
create table discount (discountID SERIAL PRIMARY KEY, clientID int, constraint clientsIDFK foreign key (clientID) references clients(clientID), percentage decimal(5, 2) not null, description text);
with topClients as (
    select clientID
    from orders
    group by clientID
    order by count(*) desc
    limit 10
)
insert into discount (clientID, percentage, description)
select clientID, 20.00, 'Скидка 20% для топ-10 клиентов'
from topClients;


--увелечение зарплаты трех лучших сотрудников на 10%
update employees
set emplWages = emplWages * 1.10
where emplID in (
    with topEmployees as (
        select emplID
        from orders
        group by emplID
        order by count(*) desc
        limit 3
    )
    select emplID
    from topEmployees
);


--месячный отчет для директора
create view monthlyReport as
select
    cs.region,
    cs.address,
    count(o.orderID) as last_month_count_number_orders,
    sum(o.payment::numeric) as lat_month_income,
    sum(o.payment::numeric) - sum(e.emplWages) as month_margin
from
    orders o
join
    carService cs on o.carServiceID = cs.carServiceID
join
    employees e on o.emplID = e.emplID
where
    o.date >= (select max(date) from orders) - interval '1 month'
group by
    cs.region, cs.address
order by
    cs.region, cs.address;


--отчет по надежности автомобилей
with carReport as (
    select
        c.carModel,
        count(*) as serviceCount,
        row_number() over (order by count(*) asc) as rowNumberasc,
        row_number() over (order by count(*) desc) as rowNumberDesc
    from
        orders o
    join
        cars c on o.carID = c.carID
    group by
        c.carModel
),
RankedCars as (
  select
        carModel,
        serviceCount,
        'Reliable' as reliability
    from
        carReport
    where rowNumberasc <= 5
  union all
  select
        carModel,
        serviceCount,
        'Unreliable' as reliability
    from
        carReport
    where rowNumberDesc <= 5
)
select carModel, serviceCount, reliability
from RankedCars
order by reliability, serviceCount;


--отчет по окрасу автомобилей
with colourReport as (
    select
        c.carModel,
        c.carColour,
        count(*) as serviceCount,
        row_number() over (PARTITIon BY c.carModel order by count(*) asc) as rowNumber
    from
        orders o
    join
        cars c on o.carID = c.carID
    group by
        c.carModel, c.carColour
)
select
    carModel,
    carColour,
    serviceCount
from
    colourReport
where rowNumber = 1
order by
    carModel;
  
