/*
Author: Bingyao Li, bil35
        Yilun Zhao, yiz178
*/

/* Question 1 start */
/*CREATE DATABASE USForest;*/

DROP TABLE IF EXISTS FOREST CASCADE;
CREATE TABLE FOREST
(
    forest_no varchar(10) NOT NULL PRIMARY KEY,
    name varchar(30),
    area real,
    acid_level real,
    MBR_XMin real,
    MBR_XMax real,
    MBR_YMin real,
    MBR_YMax real,
    sensor_count integer
);

DROP TABLE IF EXISTS STATE CASCADE;
CREATE TABLE STATE
(
    name varchar(30),
    abbreviation varchar(2) NOT NULL PRIMARY KEY,
    area real,
    population integer
);

DROP TABLE IF EXISTS COVERAGE CASCADE;
CREATE TABLE COVERAGE
(
    forest_no varchar(10) REFERENCES FOREST(forest_no),
    state varchar(2) REFERENCES STATE(abbreviation),
    percentage real,
    area real
);

DROP TABLE IF EXISTS ROAD CASCADE;
CREATE TABLE ROAD
(
    road_no varchar(10) NOT NULL PRIMARY KEY,
    name varchar(30),
    length real
);

DROP TABLE IF EXISTS INTERSECTION CASCADE;
CREATE TABLE INTERSECTION
(
    forest_no varchar(10) REFERENCES FOREST(forest_no),
    road_no varchar(10) REFERENCES ROAD(road_no)
);

DROP TABLE IF EXISTS WORKER CASCADE;
CREATE TABLE WORKER
(
    ssn varchar(9) UNIQUE NOT NULL PRIMARY KEY,
    name varchar(30) UNIQUE,
    rank integer
);

DROP TABLE IF EXISTS SENSOR CASCADE;
CREATE TABLE SENSOR
(
    sensor_id integer NOT NULL PRIMARY KEY,
    X real,
    Y real,
    last_charged timestamp,
    energy integer,
    maintainer varchar(9) DEFAULT NULL REFERENCES WORKER(ssn),
    last_read timestamp
);

DROP TABLE IF EXISTS REPORT CASCADE;
CREATE TABLE REPORT
(
    sensor_id integer REFERENCES SENSOR(sensor_id),
    temperature integer,
    report_time timestamp
);

/* Question 1 end */


/* Question 2 start */





