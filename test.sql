-- DTD 1


-- Creation des types
drop type T_MOUNTAIN force;
/

create or replace type T_MOUNTAIN as object (
  name        VARCHAR2(50),
  height      NUMBER,
  member function toXML return XMLType);
/

drop type T_DESERT force; 
/

create or replace type T_DESERT as object (
  name        VARCHAR2(50),
  area        NUMBER,
  member function toXML return XMLType); 
/

drop type T_COORDINATES force; 
/

create or replace type T_COORDINATES as object (
  latitude    NUMBER,
  longitude   NUMBER,
  member function toXML return XMLType); 
/

drop type T_CONTINENT force; 
/

create or replace type T_CONTINENT as object (
  name        VARCHAR2(50),
  percent     NUMBER,
  member function toXML return XMLType);
/

drop type T_AIRPORT force; 
/

create or replace type T_AIRPORT as object (
  iatacode    VARCHAR2(4),
  name        VARCHAR2(100),
  nearCity    VARCHAR2(50),
  member function toXML return XMLType);
/

drop type T_ISLAND force; 
/

create or replace type T_ISLAND as object (
  name        VARCHAR2(50),
  ofCoordinates ref T_COORDINATES,
  member function toXML return XMLType); 
/

drop type SET_MOUNTAINS force;
/
drop type SET_DESERTS force;
/
drop type SET_ISLANDS force;
/
drop type T_PROVINCE force; 
/

create or replace type SET_MOUNTAINS as table of T_MOUNTAIN;
/
create or replace type SET_DESERTS as table of T_DESERT;
/
create or replace type SET_ISLANDS as table of T_ISLAND;
/
create or replace type T_PROVINCE as object (
  name        VARCHAR2(50),
  capital     VARCHAR2(50),
  mountains   SET_MOUNTAINS,
  deserts     SET_DESERTS,
  islands     SET_ISLANDS,
  member function toXML return XMLType); 
/

drop type SET_CONTINENTS force;
/
drop type SET_PROVINCES force;
/
drop type SET_AIRPORTS force;
/
drop type T_COUNTRY force; 
/

create or replace type SET_CONTINENTS as table of ref T_CONTINENT;
/
create or replace type SET_PROVINCES as table of T_PROVINCE;
/
create or replace type SET_AIRPORTS as table of T_AIRPORT;
/
create or replace type T_COUNTRY as object (
  idcountry   VARCHAR2(4),
  nom         VARCHAR2(50),
  continents  SET_CONTINENTS,
  provinces   SET_PROVINCES,
  airports    SET_AIRPORTS,
  member function toXML return XMLType);
/

drop type T_MONDIAL force;
/
drop type SET_COUNTRIES force;
/

create or replace type SET_COUNTRIES as table of T_COUNTRY;
/
create or replace type T_MONDIAL as object (
  countries   SET_COUNTRIES,
  member function toXML return XMLType);
/

-- Creations des tables
drop table Mondial; 
/
create table Mondial of T_MONDIAL nested table countries store as t1; 
/

drop table TheCountries; 
/
create table TheCountries of T_COUNTRY nested table continents store as t2, nested table provinces store as t3, nested table airports store as t4;
/

drop table TheProvinces; 
/
create table TheProvinces of T_PROVINCE nested table mountains store as t5, nested table deserts store as t6, nested table islands store as t7; 
/

drop table TheMountains; 
/
create table TheMountains of T_MOUNTAIN; 
/

drop table TheDeserts; 
/
create table TheDeserts of T_DESERT; 
/

drop table TheIslands; 
/
create table TheIslands of T_ISLAND;
/

drop table TheCoordinates; 
/
create table TheCoordinates of T_COORDINATES; 
/

drop table TheContinents; 
/
create table TheContinents of T_CONTINENT; 
/

drop table TheAirports; 
/
create table TheAirports of T_AIRPORT; 

select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx in 1..tmpCountries.count
    loop
      output := XMLType.appendchildxml(output,'mondial', tmpCountries(indx).toXML());   
    end loop;      



