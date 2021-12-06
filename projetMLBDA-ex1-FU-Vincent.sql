-- DTD 1


-- Creation des types
drop type T_MOUNTAIN force;
/

create or replace type T_MOUNTAIN as object (
  name        VARCHAR2(50),
  height      NUMBER,
  country     VARCHAR2(4),
  province    VARCHAR2(50),
  member function toXML return XMLType);
/

drop type T_DESERT force; 
/

create or replace type T_DESERT as object (
  name        VARCHAR2(50),
  area        NUMBER,
  country     VARCHAR2(4),
  province    VARCHAR2(50),
  member function toXML return XMLType); 
/

drop type T_COORDINATES force; 
/

create or replace type T_COORDINATES as object (
  latitude    NUMBER,
  longitude   NUMBER,
  island      VARCHAR2(50),
  member function toXML return XMLType); 
/

drop type T_CONTINENT force; 
/

create or replace type T_CONTINENT as object (
  name        VARCHAR2(50),
  country     VARCHAR2(4),
  percent     NUMBER,
  member function toXML return XMLType);
/

drop type T_AIRPORT force; 
/

create or replace type T_AIRPORT as object (
  iatacode    VARCHAR2(4),
  name        VARCHAR2(100),
  nearCity    VARCHAR2(50),
  country     VARCHAR2(4),
  member function toXML return XMLType);
/

drop type T_ISLAND force; 
/

create or replace type T_ISLAND as object (
  name        VARCHAR2(50),
  country     VARCHAR2(4),
  province    VARCHAR2(50),
  member function toXML return XMLType); 
/

drop type T_PROVINCE force; 
/

create or replace type T_PROVINCE as object (
  name        VARCHAR2(50),
  country     VARCHAR2(50),
  capital     VARCHAR2(50),
  member function toXML return XMLType); 
/

drop type T_COUNTRY force; 
/

create or replace type T_COUNTRY as object (
  idcountry   VARCHAR2(4),
  nom         VARCHAR2(50),
  member function toXML return XMLType);
/


-- Creation des tables
drop table TheCountries; 
/
create table TheCountries of T_COUNTRY; 
/

drop table TheProvinces; 
/
create table TheProvinces of T_PROVINCE; 
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
/


-- Creation des methodes
create or replace type body T_MOUNTAIN as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<mountain name = "'||name||'" height = "'||height||'"/>');
    return output;
   end;
end;
/

create or replace type body T_DESERT as
   member function toXML return XMLType is
   output XMLType;
   begin
    if area is not NULL then 
      output := XMLType.createxml('<desert name = "'||name||'" area = "'||area||'"/>');
    else
      output := XMLType.createxml('<desert name = "'||name||'"/>');
    end if;
    return output;
   end;
end;
/

create or replace type body T_COORDINATES as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<coordinates latitude = "'||latitude||'" longitude = "'||longitude||'"/>');
    return output;
   end;
end;
/

create or replace type body T_CONTINENT as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<continent name = "'||name||'" percent = "'||percent||'"/>');
    return output;
   end;
end;
/

create or replace type body T_AIRPORT as
   member function toXML return XMLType is
   output XMLType;
   begin
    if nearCity is not NULL then 
      output := XMLType.createxml('<airport name = "'||name||'" nearCity = "'||nearCity||'"/>');
    else
      output := XMLType.createxml('<airport name = "'||name||'"/>');
    end if;
    return output;
   end;
end;
/

create or replace type body T_ISLAND as
   member function toXML return XMLType is
   output XMLType;
   coordinates T_COORDINATES;
   begin
    output := XMLType.createxml('<island name = "'||name||'"/>');
    select value(c) into coordinates
    from TheCoordinates c
    where self.name = c.island;
    if Coordinates is not NULL then
      output := XMLType.appendchildxml(output, 'island', coordinates.toXML());
    end if;
    return output;
   end;
end;
/

drop type SET_MOUNTAINS force;
/
drop type SET_DESERTS force;
/
drop type SET_ISLANDS force;
/

create or replace type SET_MOUNTAINS as table of T_MOUNTAIN; 
/
create or replace type SET_DESERTS as table of T_DESERT;
 /
create or replace type SET_ISLANDS as table of T_ISLAND; 
/
create or replace type body T_PROVINCE as
   member function toXML return XMLType is
   output XMLType;
   tmpMountains SET_MOUNTAINS;
   tmpDeserts SET_DESERTS;
   tmpIslands SET_ISLANDS;
   begin
    output := XMLType.createxml('<province name = "'||name||'" capital = "'||capital||'"/>');
    select value(m) bulk collect into tmpMountains
    from TheMountains m
    where self.name = m.province;
    select value(d) bulk collect into tmpDeserts
    from TheDeserts d
    where self.name = d.province;
    select value(i) bulk collect into tmpIslands
    from TheIslands i
    where self.name = i.province;
    for indx IN 1..tmpMountains.count
    loop
      output := XMLType.appendchildxml(output, 'province', tmpMountains(indx).toXML());   
    end loop;
    for indx IN 1..tmpDeserts.count
    loop
      output := XMLType.appendchildxml(output, 'province', tmpDeserts(indx).toXML());   
    end loop;
    for indx IN 1..tmpIslands.count
    loop
      output := XMLType.appendchildxml(output, 'province', tmpIslands(indx).toXML());   
    end loop;
    return output;
   end;
end;
/

drop type SET_CONTINENTS force;
/
drop type SET_PROVINCES force;
/
drop type SET_AIRPORTS force;
/

create or replace type SET_CONTINENTS as table of T_CONTINENT; 
/
create or replace type SET_PROVINCES as table of T_PROVINCE;
/
create or replace type SET_AIRPORTS as table of T_AIRPORT; 
/
create or replace type body T_COUNTRY as
   member function toXML return XMLType is
   output XMLType;
   tmpContinents SET_CONTINENTS;
   tmpProvinces SET_PROVINCES;
   tmpAirports SET_AIRPORTS;
   begin
    output := XMLType.createxml('<country idcountry = "'||idcountry||'" nom = "'||nom||'"/>');
    select value(c) bulk collect into tmpContinents
    from TheContinents c
    where self.idcountry = c.country;
    select value(p) bulk collect into tmpProvinces
    from TheProvinces p
    where self.idcountry = p.country;
    select value(a) bulk collect into tmpAirports
    from TheAirports a
    where self.idcountry = a.country;
    for indx IN 1..tmpContinents.count
    loop
      output := XMLType.appendchildxml(output, 'country', tmpContinents(indx).toXML());   
    end loop;
    for indx IN 1..tmpProvinces.count
    loop
      output := XMLType.appendchildxml(output, 'country', tmpProvinces(indx).toXML());   
    end loop;
    for indx IN 1..tmpAirports.count
    loop
      output := XMLType.appendchildxml(output, 'country', tmpAirports(indx).toXML());   
    end loop;
    return output;
   end;
end;
/


-- Insertion des donnees
insert into TheCountries
  select T_COUNTRY(c.code, c.name)
  from COUNTRY c;
/

insert into TheProvinces
  select T_PROVINCE(p.name,p.country, p.capital)
  from PROVINCE p;
/

insert into TheMountains 
  select T_MOUNTAIN(m.name, m.height, gm.country, gm.province)
  from MOUNTAIN m, GEO_MOUNTAIN gm
  where m.name = gm.mountain;
/

insert into TheDeserts 
  select T_DESERT(d.name, d.area, gd.country, gd.province)
  from DESERT d, GEO_DESERT gd
  where d.name = gd.desert;
/

insert into TheIslands 
  select T_ISLAND(i.name, gi.country, gi.province)
  from ISLAND i, GEO_ISLAND gi
  where i.name = gi.island;
/

insert into TheCoordinates 
  select T_COORDINATES(i.coordinates.latitude, i.coordinates.longitude, i.name)
  from ISLAND i;
/

insert into TheContinents 
  select T_CONTINENT(e.continent, e.country, e.percentage)
  from ENCOMPASSES e;
/

insert into TheAirports 
  select T_AIRPORT(a.iatacode, a.name, a.city , a.country)
  from AIRPORT a; 
/


-- Creation du xml
drop type SET_COUNTRIES force;
/

create or replace type SET_COUNTRIES as table of T_COUNTRY;
/
create or replace function x_mondial return XMLtype as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
    output :=  XMLType.createxml('<mondial/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx IN 1..tmpCountries.count
    loop
    output := XMLType.appendchildxml(output, 'mondial', tmpCountries(indx).toXML());
    end loop;
    return output;
  end;
/

WbExport -type=text
         -file='mondial.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_mondial().getClobVal()
from dual;
/


-- DTD 2


-- Creation des types
drop type T_LANGUAGE force;
/

create or replace type T_LANGUAGE as object(
  language    VARCHAR2(50),
  percent     VARCHAR2(50),
  country     VARCHAR2(4),
  member function toXML return XMLType);
/

drop type T_BORDER force;
/

create or replace type T_BORDER as object(
  countryCode VARCHAR2(4),
  len         NUMBER,
  borders     VARCHAR2(4),
  member function toXML return XMLType);
/

drop type T_HEADQUARTER force;
/

create or replace type T_HEADQUARTER as object(
  name        VARCHAR2(50),
  organization VARCHAR2(12),
  member function toXML return XMLType);
/

drop type T_BORDERS force;
/

create or replace type T_BORDERS as object(
  country     VARCHAR2(4),
  member function toXML return XMLType);
/

drop type T_COUNTRY force;
/

create or replace type T_COUNTRY as object(
  code        VARCHAR2(4),
  name        VARCHAR2(50),
  population  NUMBER,
  organization VARCHAR2(12),
  member function toXML return XMLType);
/

drop type T_ORGANIZATION force;
/

create or replace type T_ORGANIZATION as object(
  abbreviation VARCHAR2(12),
  member function toXML return XMLType);
/


-- Creation des tables
drop table TheLanguages; 
/
create table TheLanguages of T_LANGUAGE; 
/

drop table TheBorders; 
/
create table TheBorders of T_BORDER; 
/

drop table TheHeadquarters; 
/
create table TheHeadquarters of T_HEADQUARTER; 
/

drop table TheBorderss; 
/
create table TheBorderss of T_BORDERS; 
/

drop table TheCountries; 
/
create table TheCountries of T_COUNTRY; 
/

drop table TheOrganizations; 
/
create table TheOrganizations of T_ORGANIZATION; 
/


-- Creation des methodes
create or replace type body T_LANGUAGE as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<language name = "'||language||'" height = "'||percent||'"/>');
    return output;
   end;
end;
/

create or replace type body T_BORDER as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<border countryCode = "'||countryCode||'" length = "'||len||'"/>');
    return output;
   end;
end;
/

create or replace type body T_HEADQUARTER as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<headquarter name = "'||name||'"/>');
    return output;
   end;
end;
/

drop type SET_BORDERS force;
/

create or replace type SET_BORDERS as table of T_BORDER; 
/

create or replace type body T_BORDERS as
   member function toXML return XMLType is
   output XMLType;
   tmpBorders SET_BORDERS;
   begin
    output := XMLType.createxml('<borders/>');
    select value(b) bulk collect into tmpBorders
    from TheBorders b
    where self.country = b.borders;
    for indx IN 1..tmpBorders.count
    loop
      output := XMLType.appendchildxml(output, 'borders', tmpBorders(indx).toXML());   
    end loop;
    return output;
   end;
end;
/

drop type SET_LANGUAGES force;
/

create or replace type SET_LANGUAGES as table of T_LANGUAGE; 
/
create or replace type body T_COUNTRY as
   member function toXML return XMLType is
   output XMLType;
   tmpLanguages SET_LANGUAGES;
   tBorderss T_BORDERS;
   begin
    if code is not NULL then
      output := XMLType.createxml('<country code = "'||code||'" name = "'||name||'" population = "'||population||'"/>');
    else
      output := XMLType.createxml('<country name = "'||name||'" population = "'||population||'"/>');
    end if;
    select value(l) bulk collect into tmpLanguages
    from TheLanguages l
    where self.code = l.country;
    select value(b) into tBorderss
    from TheBorderss b
    where self.code = b.country;
    for indx IN 1..tmpLanguages.count
    loop
      output := XMLType.appendchildxml(output, 'country', tmpLanguages(indx).toXML());   
    end loop;
    output := XMLType.appendchildxml(output, 'country', tBorderss.toXML());   
    return output;
   end;
end;
/

drop type SET_COUNTRIES force;
/

create or replace type SET_COUNTRIES as table of T_COUNTRY; 
/
create or replace type body T_ORGANIZATION as
   member function toXML return XMLType is
   output XMLType;
   tmpCountries SET_Countries;
   tHeadquarter T_HEADQUARTER;
   begin
    output := XMLType.createxml('<organization/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c
    where self.abbreviation = c.organization;
    select value(h) into tHeadquarter
    from TheHeadquarters h
    where self.abbreviation = h.organization;
    for indx IN 1..tmpCountries.count
    loop
      output := XMLType.appendchildxml(output, 'organization', tmpCountries(indx).toXML());   
    end loop;
    output := XMLType.appendchildxml(output, 'organization', tHeadquarter.toXML());   
    return output;
   end;
end;
/


-- Insertion des donnees
insert into TheOrganizations
  select T_ORGANIZATION(o.abbreviation)
  from ORGANIZATION o 
  where o.city is not NULL;
/


insert into TheCountries
  select T_COUNTRY(c.code, c.name, c.population, m.organization)
  from COUNTRY c, isMember m
  where m.country = c.code;
/

insert into TheLanguages
  select T_LANGUAGE(l.name, l.percentage, l.country)
  from LANGUAGE l;
/

insert into TheBorderss
  select T_BORDERS(c.code)
  from COUNTRY c
/

insert into TheBorders
  select T_BORDER(b.country1, b.length, b.country2)
  from BORDERS b;
/

insert into TheBorders
  select T_BORDER(b.country2, b.length, b.country1)
  from BORDERS b;
/

insert into TheHeadquarters
  select T_HEADQUARTER(o.city, o.abbreviation)
  from ORGANIZATION o;
/


-- Creation du xml
drop type SET_ORGANIZATIONS force;
/

create or replace type SET_ORGANIZATIONS as table of T_ORGANIZATION;
/
create or replace function x_mondial2 return XMLtype as
  output XMLType;
  tmpOrganizations SET_ORGANIZATIONS;
  begin
    output :=  XMLType.createxml('<mondial/>');
    select value(o) bulk collect into tmpOrganizations
    from TheOrganizations o;
    for indx IN 1..tmpOrganizations.count
    loop
    output := XMLType.appendchildxml(output, 'mondial', tmpOrganizations(indx).toXML());
    end loop;
    return output;
  end;
/

WbExport -type=text
         -file='mondial2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_mondial2().getClobVal()
from dual;
/




