------------------------------------
-- Bingyao Li     bil35
-- Yilun Zhao     yiz178
------------------------------------



------------------------------------
-- Question #1：
------------------------------------

DROP TABLE IF EXISTS FOREST CASCADE;
create table FOREST (
    forest_no   varchar(10),
    name	varchar(30),
    area	real,
    acid_level	real,
    MBR_XMin	real,
    MBR_XMax	real,
    MBR_YMin	real,
    MBR_YMax	real,
    sensor_count int,
    constraint pk_forest primary key (forest_no)
);


DROP TABLE IF EXISTS STATE CASCADE;
create table STATE (
	name		varchar(30),
	abbreviation	varchar(2),
	area		real,
	population	int,
    constraint pk_state primary key (abbreviation)
);


DROP TABLE IF EXISTS COVERAGE CASCADE;
create table COVERAGE(
    forest_no varchar(10),
    state varchar(2),
    percentage real,
    area real,
    constraint pk_forest_no primary key (forest_no, state),
    constraint fk_forest_no foreign key (forest_no) references FOREST(forest_no),
    constraint fk_state foreign key (state) references STATE(abbreviation)
);


DROP TABLE IF EXISTS ROAD CASCADE;
create table ROAD(
    road_no varchar(10),
    name varchar(30),
    length real,
    constraint pk_road_no primary key(road_no)
);


DROP TABLE IF EXISTS INTERSECTION CASCADE;
create table INTERSECTION(
    forest_no varchar(10),
    road_no varchar(10),
    constraint pk_intersection primary key (forest_no, road_no),
    constraint fk_forest_no foreign key(forest_no) references FOREST(forest_no),
    constraint fk_road_no foreign key(road_no) references ROAD(road_no)
);


DROP TABLE IF EXISTS WORKER CASCADE;
create table WORKER(
    ssn varchar(9) ,
    name varchar(30),
    rank int,
    constraint pk_ssn primary key(ssn)
);


DROP TABLE IF EXISTS SENSOR CASCADE;
create table SENSOR(
    sensor_id int,
    X real,
    Y real,
    last_charged timestamp,
    energy int,
    maintainer varchar(9) default null,
    last_read timestamp,
    constraint pk_sensor_id primary key(sensor_id),
    constraint fk_sensor foreign key (maintainer) references WORKER(ssn)
);


DROP TABLE IF EXISTS REPORT CASCADE;
create table REPORT(
    sensor_id int,
    temperature real,
    report_time timestamp,
    Constraint report_PK primary key (sensor_id, report_time) ,
    constraint fk_sensor_id foreign key(sensor_id) references SENSOR(sensor_id)
);



------------------------------------
-- Question #2
------------------------------------

-- a

alter table FOREST add constraint unique_forest_name unique (name);
alter table FOREST add constraint unique_forest_MBR unique (MBR_XMin, MBR_XMax, MBR_YMin, MBR_YMax);
alter table STATE add constraint unique_state_name unique (name);
alter table ROAD add constraint unique_road_name unique (name);
alter table SENSOR add constraint unique_sensor_coordinate unique (X,Y);
alter table WORKER add constraint unique_worker_name unique (name);

-- b

alter table SENSOR
add constraint check_energy CHECK (energy >=0 and energy <=10) initially immediate not deferrable;

-- c
alter table FOREST
add constraint check_acid CHECK (Acid_Level>=0 and Acid_Level<=1) initially immediate not deferrable;

-- d
alter table WORKER add age int;
alter table WORKER add constraint check_age CHECK (age >=0) initially immediate not deferrable;

-- e
alter table WORKER add employing_state varchar(2);
alter table WORKER add constraint work_state_uq unique (ssn, employing_state) initially immediate not deferrable;


------------------------------------
-- Question #3
------------------------------------

CREATE OR REPLACE FUNCTION func_employ()
RETURNS TRIGGER
AS $function$
BEGIN
    UPDATE SENSOR SET maintainer = NULL
    WHERE sensor_id IN (SELECT sensor_id FROM SENSOR WHERE maintainer is NOT NULL
    EXCEPT
    SELECT DISTINCT sensor_id
    FROM FOREST F, SENSOR S, WORKER W, COVERAGE C
    WHERE S.x <= F.mbr_xmax and S.x >= F.mbr_xmin and S.y <= F.mbr_ymax and S.y >= F.mbr_ymin
    and W.ssn = S.maintainer and F.forest_no = C.forest_no and C.state = employing_state);
RETURN NULL;
END;
$function$   LANGUAGE plpgsql;

CREATE TRIGGER check_employ
    AFTER INSERT OR UPDATE ON SENSOR
    FOR EACH ROW
    EXECUTE FUNCTION func_employ();


------------------------------------
-- Question #4
------------------------------------

INSERT INTO FOREST VALUES( '1', 'Allegheny National Forest', 3500, 0.31, 20, 90, 10, 60, 4);
INSERT INTO FOREST VALUES( '2', 'Pennsylvania Forest', 2700, 0.74 , 40,	70,	20,	110, 3);
INSERT INTO FOREST VALUES( '3', 'Stone Valley', 5000, 0.56,	60,	160, 30, 80, 7);
INSERT INTO FOREST VALUES( '4', 'Big Woods', 3000, 0.92, 150, 180, 20, 120,	3);
INSERT INTO FOREST VALUES( '5', 'Crooked Forest', 2400,	0.23, 100, 140,	70,	130, 2);

INSERT INTO STATE VALUES( 'Pennsylvania', 'PA', 50000, 1400000 );
INSERT INTO STATE VALUES( 'Ohio', 'OH', 45000, 1200000 );
INSERT INTO STATE VALUES( 'Virginia', 'VA', 35000, 1000000 );

INSERT INTO COVERAGE VALUES( '1', 'OH', 1, 3500 );
INSERT INTO COVERAGE VALUES( '2', 'OH', 1, 2700 );
INSERT INTO COVERAGE VALUES( '3', 'OH', 0.3, 1500 );
INSERT INTO COVERAGE VALUES( '3', 'PA', 0.42, 2100 );
INSERT INTO COVERAGE VALUES( '3', 'VA', 0.28, 1400 );
INSERT INTO COVERAGE VALUES( '4', 'PA', 0.4, 1200 );
INSERT INTO COVERAGE VALUES( '4', 'VA', 0.6, 1800 );
INSERT INTO COVERAGE VALUES( '5', 'VA', 1, 2400 );

INSERT INTO ROAD VALUES( '1', 'Forbes', 500 );
INSERT INTO ROAD VALUES( '2', 'Bigelow', 300 );
INSERT INTO ROAD VALUES( '3', 'Bayard', 555 );
INSERT INTO ROAD VALUES( '4', 'Grant', 100 );
INSERT INTO ROAD VALUES( '5', 'Carson', 150 );
INSERT INTO ROAD VALUES( '6', 'Greatview', 180 );
INSERT INTO ROAD VALUES( '7', 'Beacon', 333 );

INSERT INTO INTERSECTION VALUES ( '1', '1' );
INSERT INTO INTERSECTION VALUES ( '1', '2' );
INSERT INTO INTERSECTION VALUES ( '1', '4' );
INSERT INTO INTERSECTION VALUES ( '2', '1' );
INSERT INTO INTERSECTION VALUES ( '2', '4' );
INSERT INTO INTERSECTION VALUES ( '2', '5' );
INSERT INTO INTERSECTION VALUES ( '2', '6' );
INSERT INTO INTERSECTION VALUES ( '2', '7' );
INSERT INTO INTERSECTION VALUES ( '3', '3' );
INSERT INTO INTERSECTION VALUES ( '3', '5' );
INSERT INTO INTERSECTION VALUES ( '4', '4' );
INSERT INTO INTERSECTION VALUES ( '4', '5' );
INSERT INTO INTERSECTION VALUES ( '4', '6' );
INSERT INTO INTERSECTION VALUES ( '5', '1' );
INSERT INTO INTERSECTION VALUES ( '5', '3' );
INSERT INTO INTERSECTION VALUES ( '5', '5' );
INSERT INTO INTERSECTION VALUES ( '5', '6' );

INSERT INTO WORKER VALUES('123456789', 'John', 6, 22, 'OH');
INSERT INTO WORKER VALUES('121212121', 'Jason', 5, 30, 'PA');
INSERT INTO WORKER VALUES('222222222', 'Mike', 4, 25, 'OH');
INSERT INTO WORKER VALUES('333333333', 'Tim', 2, 35, 'VA');

INSERT INTO SENSOR VALUES( '1', 33, 29, to_timestamp('2020-06-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, '123456789', to_timestamp('2020-12-01 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '2', 78, 24, to_timestamp('2020-07-09 23:00:00', 'YYYY-MM-DD HH24:MI:SS'), 8, '222222222', to_timestamp('2020-11-01 18:30:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '3', 51, 51, to_timestamp('2020-09-01 18:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, '222222222', to_timestamp('2020-11-09 08:25:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '4', 67, 49, to_timestamp('2020-09-09 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, '121212121', to_timestamp('2020-12-06 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '5', 66, 92, to_timestamp('2020-09-11 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, '123456789', to_timestamp('2020-11-07 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '6', 100, 52, to_timestamp('2020-09-13 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, '121212121', to_timestamp('2020-11-09 23:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '7', 111, 41, to_timestamp('2020-09-21 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, '222222222', to_timestamp('2020-11-21 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '8', 120, 75, to_timestamp('2020-10-13 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, '123456789', to_timestamp('2020-11-13 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '9', 124, 108, to_timestamp('2020-10-21 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 7, '333333333', to_timestamp('2020-11-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '10', 153, 50, to_timestamp('2020-11-10 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, '333333333', to_timestamp('2020-11-21 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '11', 151, 33, to_timestamp('2020-11-21 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, '222222222', to_timestamp('2020-11-27 22:00:00', 'YYYY-MM-DD HH24:MI:SS') );
INSERT INTO SENSOR VALUES( '12', 151, 73, to_timestamp('2020-11-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, '121212121', to_timestamp('2020-11-30 09:00:00', 'YYYY-MM-DD HH24:MI:SS') );

insert into REPORT values (7,46,to_timestamp('2020-05-10 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,88,to_timestamp('2020-05-24 13:40:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,87,to_timestamp('2020-06-28 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (6,38,to_timestamp('2020-07-09 23:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (2,46,to_timestamp('2020-09-01 18:30:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (1,34,to_timestamp('2020-09-01 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,57,to_timestamp('2020-09-05 10:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (4,62,to_timestamp('2020-09-06 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (5,52,to_timestamp('2020-09-07 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,61,to_timestamp('2020-09-09 08:25:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,37,to_timestamp('2020-09-09 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (1,58,to_timestamp('2020-09-10 20:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,46,to_timestamp('2020-09-10 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (8,44,to_timestamp('2020-09-11 02:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,49,to_timestamp('2020-09-11 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (8,51,to_timestamp('2020-09-13 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (9,55,to_timestamp('2020-09-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (10,70,to_timestamp('2020-09-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,88,to_timestamp('2020-09-24 13:40:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,46,to_timestamp('2020-09-27 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,60,to_timestamp('2020-09-30 09:03:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (2,46,to_timestamp('2020-10-01 18:30:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (1,34,to_timestamp('2020-10-01 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,57,to_timestamp('2020-10-05 10:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (5,52,to_timestamp('2020-10-07 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,37,to_timestamp('2020-10-09 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (6,38,to_timestamp('2020-10-09 23:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,46,to_timestamp('2020-10-10 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,49,to_timestamp('2020-10-11 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (8,51,to_timestamp('2020-10-13 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (10,70,to_timestamp('2020-10-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,88,to_timestamp('2020-10-24 13:40:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,46,to_timestamp('2020-10-27 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,60,to_timestamp('2020-10-30 09:03:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (2,46,to_timestamp('2020-11-01 18:30:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,57,to_timestamp('2020-11-05 10:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,53,to_timestamp('2020-11-06 11:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (4,62,to_timestamp('2020-11-06 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (5,52,to_timestamp('2020-11-07 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (3,61,to_timestamp('2020-11-09 08:25:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,37,to_timestamp('2020-11-09 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (6,38,to_timestamp('2020-11-09 23:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (1,58,to_timestamp('2020-11-10 20:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (8,44,to_timestamp('2020-11-11 02:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,49,to_timestamp('2020-11-11 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,76,to_timestamp('2020-11-11 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (8,51,to_timestamp('2020-11-13 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (7,47,to_timestamp('2020-11-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (9,55,to_timestamp('2020-11-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (10,70,to_timestamp('2020-11-21 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,77,to_timestamp('2020-11-24 13:40:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (9,33,to_timestamp('2020-11-27 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (11,46,to_timestamp('2020-11-27 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (9,35,to_timestamp('2020-11-28 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,87,to_timestamp('2020-11-28 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (12,60,to_timestamp('2020-11-30 09:03:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (1,34,to_timestamp('2020-12-01 22:00:00','YYYY-MM-DD HH24:MI:SS'));
insert into REPORT values (4,62,to_timestamp('2020-12-06 22:00:00','YYYY-MM-DD HH24:MI:SS'));
