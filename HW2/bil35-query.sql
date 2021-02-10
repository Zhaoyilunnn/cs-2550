------------------------------------
-- Bingyao Li     bil35
-- Yilun Zhao     yiz178
------------------------------------

------------------------------------
-- Question #5：
------------------------------------

-- a
SELECT R.name
FROM ROAD R, INTERSECTION I, FOREST F
WHERE R.road_no = I.road_no and F.forest_no = I.forest_no and
F.name = 'Stone Valley';

-- b
SELECT DISTINCT W.name
FROM WORKER W, SENSOR S
WHERE W.ssn = S.maintainer and S.maintainer != ALL (
    SELECT  S1.maintainer FROM SENSOR S1 WHERE S1.energy BETWEEN 3 AND 5);

-- c
SELECT F.name
FROM FOREST F, COVERAGE C
WHERE C.state = 'PA' and C.forest_no = F.forest_no and acid_level<0.6;

-- d
SELECT DISTINCT F.name
FROM FOREST F, INTERSECTION I
WHERE F.forest_no = I.forest_no and
      I.forest_no = (SELECT I2.forest_no FROM INTERSECTION I2 WHERE
      I2.road_no > ALL
      ( SELECT I1.road_no
        FROM INTERSECTION I1
        WHERE I1.forest_no = (SELECT F1.forest_no FROM FOREST F1 WHERE F1.name = 'Big Woods' )));

-- e
select
       case extract(dow from report_time)
           when 0 then 'Sunday'
           when 1 then 'Monday'
           when 2 then 'Tuesday'
           when 3 then 'Wednesday'
           when 4 then 'Thursday'
           when 5 then 'Friday'
           when 6 then 'Saturday'
       end
           as dow,
       CAST(count(*) as double precision) / CAST(count(distinct extract(day from report_time)) as double precision)
           as avg_count
from REPORT
where extract(year from report_time) = 2020 and
      extract(month from report_time) = 11
group by dow
order by avg_count desc limit 1 offset 0;

-- f
select extract(week from report_time) - 35 as week,
       (date_trunc('week', report_time::timestamp) - '1 days'::interval)::date as start_week,
       (date_trunc('week', report_time::timestamp) + '6 days'::interval)::date as end_week,
       sum(temperature) / count(*) as avg_temperature
from REPORT
where report_time >= '2020-09-01 00:00:00' and report_time <= '2020-11-30 23:59:59'
group by week, start_week, end_week
order by week;


------------------------------------
-- Question #6：
------------------------------------

set transaction read write;
set constraints all deferred;
INSERT INTO WORKER VALUES( '888888888', 'Robert', 1, 27,'VA');
UPDATE SENSOR SET maintainer='888888888' WHERE sensor_id = 9;
commit;


------------------------------------
-- Question #7：
------------------------------------

set transaction read write;
set constraints all deferred;
UPDATE SENSOR SET x = 110, y = 120,
                  last_charged = (SELECT now() - interval '2 H'),
                  last_read = (SELECT now() - interval '15 M')
WHERE sensor_id = 10;
UPDATE FOREST SET sensor_count = sensor_count + 1 WHERE name = 'Crooked Forest';
INSERT INTO REPORT VALUES (10, 52, current_timestamp);




------------------------------------
-- Question #8：
------------------------------------

update WORKER
set employing_state = case name
                            when 'John' then (select employing_state from WORKER where name = 'Mike')
                            when 'Mike' then (select employing_state from WORKER where name = 'John')
                      end
where name in ('John', 'Mike');

update SENSOR
set maintainer = case maintainer
                        when '123456789' then (select distinct maintainer from SENSOR where maintainer = '222222222')
                        when '222222222' then (select distinct maintainer from SENSOR where maintainer = '123456789')
                 end
where maintainer in ('123456789', '222222222');


------------------------------------
-- Question #9：
------------------------------------

-- a
--drop view FOREST_ROAD;
create view FOREST_ROAD as
select FOREST.name, count(*) as road_num
from INTERSECTION, FOREST
where INTERSECTION.forest_no = FOREST.forest_no
group by FOREST.name;

-- b
--drop view FOREST_SENSORS;
create view FOREST_SENSORS as
select FOREST.name, sensor_id
from FOREST, SENSOR
where X <= MBR_XMax and X >= MBR_XMin and Y <= MBR_YMax and Y >= MBR_YMin

-- c
--drop view DUTIES;
create view DUTIES as
select WORKER.name, count(*) as num_maintained_sensors
from SENSOR, WORKER
where SENSOR.maintainer = WORKER.ssn
group by maintainer, ssn, name
order by maintainer;


------------------------------------
-- Question #10：
------------------------------------

-- a
select FOREST_ROAD.name
from FOREST_ROAD
where road_num = (select distinct road_num from FOREST_ROAD order by road_num desc limit 1 offset 1);

-- b
select DUTIES.name, WORKER.employing_state, sum(COVERAGE.area)
from DUTIES, WORKER, COVERAGE
where num_maintained_sensors = (select max(num_maintained_sensors) from DUTIES)
  and DUTIES.name = WORKER.name
  and WORKER.employing_state = COVERAGE.state
group by DUTIES.name, WORKER.employing_state;

-- c
select distinct FOREST_SENSORS.name
from FOREST_SENSORS
where sensor_id in (select sensor_id from FOREST_SENSORS where FOREST_SENSORS.name = 'Big Woods');


------------------------------------
-- Question #11：
------------------------------------

-- a

CREATE OR REPLACE FUNCTION  pro_Increment_Sensor_Count ()
RETURNS TRIGGER
AS $$
DECLARE
    sensorX real;
    sensorY real;
BEGIN
    sensorX := TG_ARGV[0];
    sensorY := TG_ARGV[1];

    UPDATE FOREST
    SET  sensor_count = sensor_count + 1
    WHERE (SELECT F.forest_no FROM FOREST F
           WHERE F.mbr_xmax > sensorX and F.mbr_xmin < sensorX
                 and F.mbr_ymax > sensorY and F.mbr_ymin < sensorY);
END;
$$ LANGUAGE plpgsql;

-- b

CREATE OR REPLACE FUNCTION fun_compute_percentage ()
RETURNS TRIGGER
AS $percentage$
declare
    forestNo varchar;
    area_covered real;
    percentage real;
BEGIN
    forestNo := TG_ARGV[0];
    area_covered := TG_ARGV[1];

    SELECT area_covered/F.area into percentage
    FROM FOREST F
    where F.forest_no = forestNo;
    RETURN (percentage);
END;
$percentage$   LANGUAGE plpgsql;


------------------------------------
-- Question #12：
------------------------------------

-- a

CREATE TRIGGER tri_Sensor_Count
AFTER INSERT ON SENSOR
FOR EACH ROW
EXECUTE PROCEDURE pro_Increment_Sensor_Count();

-- b

CREATE TRIGGER tri_Percentage
BEFORE UPDATE OF area ON COVERAGE
FOR EACH ROW
EXECUTE PROCEDURE fun_compute_percentage ();