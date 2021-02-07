/*
Author: Bingyao Li, bil35
        Yilun Zhao, yiz178
*/

/* Question 1 start*/
CREATE DATABASE USForest;

DROP TABLE IF EXISTS FOREST;
CREATE TABLE FOREST
(
    forest_no varchar(10) NOT NULL,
    name varchar(30),
    area real,
    acid_level real,
    MBR_XMin real,
    MBR_XMax real,
    MBR_YMin real,
    MBR_YMax real,
    sensor_count integer
);

DROP TABLE IF EXISTS STATE;
CREATE TABLE STATE
(
    name varchar(30),
    abbreviation varchar(2),
    area real,
    population integer
);

DROP TABLE IF EXISTS COVERAGE;
CREATE TABLE COVERAGE
(
    forest_no varchar(10) REFERENCES FOREST(forest_no),
    state varchar(2) REFERENCES STATE(abbreviation),
    percentage real,
    area real
);

DROP TABLE IF EXISTS ROAD;
CREATE TABLE ROAD
(
    road_no varchar(10) NOT NULL,
    name varchar(30),
    length real
);

DROP TABLE IF EXISTS INTERSECTION;
CREATE TABLE INTERSECTION
(
    forest_no varchar(10) REFERENCES FOREST(forest_no),
    road_no varchar(10) REFERENCES ROAD(road_no)
);

DROP TABLE IF EXISTS SENSOR;
CREATE TABLE SENSOR
(
    sensor_id integer NOT NULL,
    X real,
    Y real,
    last_charged timestamp,
    energy integer,
    maintainer varchar(9) DEFAULT NULL REFERENCES WORKER(ssn),
    last_read timestamp
);

DROP TABLE IF EXISTS REPORT;
CREATE TABLE REPORT
(
    sensor_id integer REFERENCES SENSOR(sensor_id),
    temperature integer,
    report_time timestamp
);

DROP TABLE IF EXISTS WORKER;
CREATE TABLE WORKER
(
    ssn varchar(9) UNIQUE,
    name varchar(30) UNIQUE,
    rank integer
);

