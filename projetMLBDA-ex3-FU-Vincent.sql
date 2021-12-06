-- DTD 1 pour xpath


drop type T_CONTINENT force;
/

create or replace type T_CONTINENT as object (
  name        VARCHAR2(50),
  member function toXML return XMLType);
/


drop type T_COUNTRY force;
/

create or replace type T_COUNTRY as object (
  name     VARCHAR2(50),
  population NUMBER,
  code     VARCHAR2(4),
  continent VARCHAR2(50),
  member function toXML return XMLType,
  member function toXML2 return XMLType);
/

drop type T_ORGANIZATION force;
/

create or replace type T_ORGANIZATION as object(
  name VARCHAR2(80),
  abbreviation VARCHAR2(12),
  established DATE,
  country VARCHAR2(4),
  member function toXML return XMLType);
/

drop table TheCountries;
/

create table TheCountries of T_COUNTRY; 
/

drop table TheContinents; 
/
create table TheContinents of T_CONTINENT; 
/

drop table TheOrganizations;
/
create table TheOrganizations of T_ORGANIZATION;
/

insert into TheContinents 
  select T_CONTINENT(c.name)
  from CONTINENT c;
/

insert into TheCountries
  select T_COUNTRY(c.name, c.population, c.code, e.continent)
  from COUNTRY c, ENCOMPASSES e
  where c.code = e.country and e.percentage = (select max(e2.percentage)
                                               from ENCOMPASSES e2
                                               where c.code = e2.country);
/

insert into TheOrganizations
  select T_ORGANIZATION(o.name, o.abbreviation, o.established, i.country)
  from ORGANIZATION o, isMember i
  where i.organization = o.abbreviation;
/

drop type SET_ORGANIZATIONS force;
/

create or replace type SET_ORGANIZATIONS as table of T_ORGANIZATION;
/ 
create or replace type body T_COUNTRY as
  member function toXML return XMLType is
  output XMLType;
  begin
  output := XMLType.createxml('<country code = "'||code||'" name = "'||name||'" population = "'||population||'"/>');
  return output;
  end;
  member function toXML2 return XMLType is
  output XMLType;
  tmpOrganizations SET_ORGANIZATIONS;
  begin
  output := XMLType.createxml('<country code = "'||code||'" name = "'||name||'"/>');
  select T_ORGANIZATION(o.name, o.abbreviation, o.established, o.country) bulk collect into tmpOrganizations
  from TheOrganizations o
  where self.code = o.country
  order by o.established ASC;
  for indx in 1..tmpOrganizations.count
  loop
    output := XMLType.appendchildxml(output, 'country', tmpOrganizations(indx).toXML());
  end loop;
  return output;
  end;
end;
/

drop type SET_COUNTRIES force;
/

create type SET_COUNTRIES as table of T_COUNTRY;
/
create or replace type body T_CONTINENT as
  member function toXML return XMLType is
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
  output := XMLType.createxml('<continent name = "'||name||'"/>');
  select value(c) bulk collect into tmpCountries
  from TheCountries c
  where self.name = c.continent;
  for indx in 1..tmpCountries.count
  loop
    output := XMLType.appendchildxml(output, 'continent', tmpCountries(indx).toXML());
  end loop;
  return output;
  end;
end;
/

create or replace type body T_ORGANIZATION as
  member function toXML return XMLType is
  output XMLType;  
  begin
  if established is not NULL then
    output := XMLType.createxml('<organization abbreviation = "'||abbreviation||'" name = "'||name||'" established = "'||established||'"/>');
  else
    output := XMLType.createxml('<organization abbreviation = "'||abbreviation||'" name = "'||name||'"/>');
  end if;
  return output;
  end;
end;
/

drop type SET_CONTINENTS force;
/

create or replace type SET_CONTINENTS as table of T_CONTINENT;
/
create or replace function xp_mondial return XMLType as
  output XMLType;
  tmpContinents SET_CONTINENTS;
  begin
  output := XMLType.createxml('<mondial/>');
  select T_CONTINENT(c.name) bulk collect into tmpContinents
  from TheContinents c;
  for indx in 1..tmpContinents.count
  loop
    output := XMLType.appendchildxml(output, 'mondial', tmpContinents(indx).toXML());
  end loop;
  return output;
  end;
/



WbExport -type=text
         -file='xp_mondial.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select xp_mondial().getClobVal() 
from dual;
/


-- DTD 2 pour xpath


create or replace function xp_mondial2 return XMLType as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
  output := XMLType.createxml('<mondial/>');
  select value(c) bulk collect into tmpCountries
  from TheCountries c;
  for indx in 1..tmpCountries.count
  loop
    output := XMLType.appendchildxml(output, 'mondial', tmpCountries(indx).toXML2());
  end loop;
  return output;
  end;
/
  
WbExport -type=text
         -file='xp_mondial2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select xp_mondial2().getClobVal() 
from dual;
/
  

-- DTD 3 pour xpath

drop type T_PROVINCE force; 
/

create or replace type T_PROVINCE as object (
  name        VARCHAR2(50),
  country     VARCHAR2(50),
  capital     VARCHAR2(50),
  member function toXML return XMLType); 
/

drop type T_MOUNTAIN force;
/

create or replace type T_MOUNTAIN as object (
  name        VARCHAR2(50),
  height      NUMBER,
  latitude    NUMBER,
  longitude   NUMBER,
  country     VARCHAR2(4),
  province    VARCHAR2(50),
  member function toXML return XMLType);
/

drop table TheProvinces; 
/
create table TheProvinces of T_PROVINCE; 
/

drop table TheMountains; 
/
create table TheMountains of T_MOUNTAIN; 
/

create or replace type body T_MOUNTAIN as
   member function toXML return XMLType is
   output XMLType;
   begin
    output := XMLType.createxml('<mountain name = "'||name||'" height = "'||height||'" latitude = "'||latitude||'" longitude = "'||longitude||'"/>');
    return output;
   end;
end;
/

drop type SET_MOUNTAINS force;
/

create or replace type SET_MOUNTAINS as table of T_MOUNTAIN; 
/

create or replace type body T_PROVINCE as
   member function toXML return XMLType is
   output XMLType;
   tmpMountains SET_MOUNTAINS;
   begin
    output := XMLType.createxml('<province name = "'||name||'" capital = "'||capital||'"/>');
    select value(m) bulk collect into tmpMountains
    from TheMountains m
    where self.name = m.province;
    for indx IN 1..tmpMountains.count
    loop
      output := XMLType.appendchildxml(output, 'province', tmpMountains(indx).toXML());   
    end loop;
    return output;
   end;
end;
/

insert into TheProvinces
  select T_PROVINCE(p.name,p.country, p.capital)
  from PROVINCE p;
/

insert into TheMountains 
  select T_MOUNTAIN(m.name, m.height, m.coordinates.latitude, m.coordinates.longitude, gm.country, gm.province)
  from MOUNTAIN m, GEO_MOUNTAIN gm
  where m.name = gm.mountain;
/

drop type SET_PROVINCES force;

create or replace type SET_PROVINCES as table of T_PROVINCE;
/
create or replace function xp_mondial3 return XMLType as
  output XMLType;
  tmpProvinces SET_PROVINCES;
  begin
  output := XMLType.createxml('<mondial/>');
  select value(p) bulk collect into tmpProvinces
  from TheProvinces p;
  for indx in 1..tmpProvinces.count
  loop
    output := XMLType.appendchildxml(output, 'mondial', tmpProvinces(indx).toXML());
  end loop;
  return output;
  end;
/

WbExport -type=text
         -file='xp_mondial3.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select xp_mondial3().getClobVal() 
from dual;
/


  


