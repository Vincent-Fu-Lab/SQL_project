-- DTD 1


-- Creation des elements
drop type T_GEO force;
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
create or replace type T_GEO as object (
  country     VARCHAR2(50),
  member function x_mountains return SET_MOUNTAINS,
  member function x_deserts return SET_DESERTS,
  member function x_islands return SET_ISLANDS,
  member function toXML return XMLType);
/

drop type T_COUNTRY force;
/
drop type SET_BORDERS force;
/

create or replace type SET_BORDERS as table of T_BORDER; 
/
create or replace type T_COUNTRY as object (
  name     VARCHAR2(50),
  code     VARCHAR2(4),
  member function x_peak return NUMBER,
  member function x_continent return VARCHAR2,
  member function x_border return SET_BORDERS,
  member function x_blength return NUMBER,
  member function toXML return XMLType,
  member function toXML2 return XMLType,
  member function toXML3 return XMLType,
  member function toXML4 return XMLType);
/

-- Creation des tables
drop table TheCountries; 
/
create table TheCountries of T_COUNTRY; 
/

drop table TheGeos; 
/
create table TheGeos of T_GEO; 
/

 
set serveroutput on;
/
-- Creation des methodes
create or replace type body T_GEO as
   member function x_mountains return SET_MOUNTAINS is
   output SET_MOUNTAINS;
   begin
    select value(m) bulk collect into output
    from TheMountains m
    where self.country = m.country;
    return output;
   end;
   member function x_deserts return SET_DESERTS is
   output SET_DESERTS;
   begin
    select value(d) bulk collect into output
    from TheDeserts d
    where self.country = d.country;
    return output;
   end;
   member function x_islands return SET_ISLANDS is
   output SET_ISLANDS;
   begin
    select value(i) bulk collect into output
    from TheIslands i
    where self.country = i.country;
    return output;
   end;
   member function toXML return XMLType is
   output XMLType;
   tmpMountains SET_MOUNTAINS;
   tmpDeserts SET_DESERTS;
   tmpIslands SET_ISLANDS;
   tmpx XMLType;
   begin
    tmpMountains := x_mountains();
    tmpDeserts := x_deserts();
    tmpIslands := x_islands();
    output := XMLType.createxml('<geo/>');
    for indx in 1..tmpMountains.count
    loop
      output := XMLType.appendchildxml(output, 'geo', XMLType.createxml('<mountain name = "'||tmpMountains(indx).name||'" height = "'||tmpMountains(indx).height||'"/>'));
    end loop;
    for indx in 1..tmpDeserts.count
    loop
      if tmpDeserts(indx).area is not NULL then
        tmpx := XMLType.createxml('<desert name = "'||tmpDeserts(indx).name||'" area = "'||tmpDeserts(indx).area||'"/>');
       else
        tmpx := XMLType.createxml('<desert name = "'||tmpDeserts(indx).name||'"/>');
      end if;
      output := XMLType.appendchildxml(output, 'geo', tmpx);
    end loop;
    for indx in 1..tmpIslands.count
    loop
      output := XMLType.appendchildxml(output, 'geo', tmpIslands(indx).toXML());
    end loop;
    return output;
    end;
end;
/


create or replace type body T_COUNTRY as
  member function x_peak return NUMBER is
  tmpPeak NUMBER;
  tmpGeo T_GEO;
  tmpMountains SET_MOUNTAINS;
  begin
    select value(g) into tmpGeo
    from TheGeos g
    where self.code = g.country;
    tmpMountains := tmpGeo.x_mountains();
    select max(m.height) into tmpPeak
    from table(tmpMountains) m;
    if tmpPeak is not NULL then
      return tmpPeak;
    else
      return 0;
    end if;
  end;  
  member function x_continent return VARCHAR2 is
  tmpContinent VARCHAR2(50);
  begin
  select c.name into tmpContinent
  from TheContinents c
  where self.code = c.country and c.percent = (select max(c.percent)
                                               from TheContinents c
                                               where self.code = c.country);
  return tmpContinent;
  end;
  member function x_border return SET_BORDERS is
  tmpBorders SET_BORDERS;
  begin
  select value(b) bulk collect into tmpBorders
  from TheBorders b
  where self.code = b.borders;
  return tmpBorders;
  end;
  member function x_blength return NUMBER is
  output NUMBER;
  tmpBorders SET_BORDERS;
  begin 
  tmpBorders := x_border();
  select sum(b.len) into output
  from table(tmpBorders) b;
  return output;
  end;
  member function toXML return XMLType is
  output XMLType;
  tmpGeo T_GEO;
  begin
   output := XMLType.createxml('<country name = "'||name||'"/>');
   select value(g) into tmpGeo
   from TheGeos g
   where self.code = g.country;
   output := XMLType.appendchildxml(output, 'country', tmpGeo.toXML());
   return output;
  end;
  member function toXML2 return XMLType is
  output XMLType;
  tmpGeo T_GEO;
  tmpPeak NUMBER;
  begin
   output := XMLType.createxml('<country name = "'||name||'"/>');
   select value(g) into tmpGeo
   from TheGeos g
   where self.code = g.country;
   output := XMLType.appendchildxml(output, 'country', tmpGeo.toXML());
   tmpPeak := x_peak();
   if tmpPeak != 0 then
    output := XMLType.appendchildxml(output, 'country', XMLType.createxml('<peak height ="'||tmpPeak||'"/>'));
   end if;
   return output;
  end;
  member function toXML3 return XMLType is
  output XMLType;
  tmpContinent VARCHAR2(50);
  tmpBorders SET_BORDERS;
  tmp XMLType;
  begin
  tmpContinent := x_continent();
  tmpBorders := x_border();
  output := XMLType.createxml('<country name = "'||name||'" continent = "'||tmpContinent||'"/>');
  tmp := XMLType.createxml('<contCountries/>');
  for indx in 1..tmpBorders.count
  loop
    tmp := XMLType.appendchildxml(tmp, 'contCountries', tmpBorders(indx).toXML());
  end loop;
  output := XMLType.appendchildxml(output, 'country', tmp);
  return output;
  end;
  member function toXML4 return XMLType is
  output XMLType;
  tmpContinent VARCHAR2(50);
  tmpBorders SET_BORDERS;
  tmp XMLType;
  blength NUMBER;
  begin
  blength := x_blength();
  tmpBorders := x_border();
  output := XMLType.createxml('<country name = "'||name||'" blength = "'||blength||'"/>');
  tmp := XMLType.createxml('<contCountries/>');
  for indx in 1..tmpBorders.count
  loop
    tmp := XMLType.appendchildxml(tmp, 'contCountries', tmpBorders(indx).toXML());
  end loop;
  output := XMLType.appendchildxml(output, 'country', tmp);
  return output;
  end;
end;
/


-- Insertion des donnees
insert into TheCountries 
  select T_COUNTRY(c.name, c.code) 
  from COUNTRY c;
  
insert into TheGeos
  select T_GEO(c.code)
  from COUNTRY c;
  

-- Creation du xml
drop type SET_COUNTRIES force;
/

create or replace type SET_COUNTRIES as table of T_COUNTRY;
/
create or replace function x_ex2 return XMLtype as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
    output :=  XMLType.createxml('<ex2/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx IN 1..tmpCountries.count
    loop
    output := XMLType.appendchildxml(output, 'ex2', tmpCountries(indx).toXML());
    end loop;
    return output;
  end;
/

create or replace function x_ex22 return XMLtype as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
    output :=  XMLType.createxml('<ex2/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx IN 1..tmpCountries.count
    loop
    output := XMLType.appendchildxml(output, 'ex2', tmpCountries(indx).toXML2());
    end loop;
    return output;
  end;
/

create or replace function x_ex23 return XMLtype as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
    output :=  XMLType.createxml('<ex2/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx IN 1..tmpCountries.count
    loop
    output := XMLType.appendchildxml(output, 'ex2', tmpCountries(indx).toXML3());
    end loop;
    return output;
  end;
/

create or replace function x_ex24 return XMLtype as
  output XMLType;
  tmpCountries SET_COUNTRIES;
  begin
    output :=  XMLType.createxml('<ex2/>');
    select value(c) bulk collect into tmpCountries
    from TheCountries c;
    for indx IN 1..tmpCountries.count
    loop
    output := XMLType.appendchildxml(output, 'ex2', tmpCountries(indx).toXML4());
    end loop;
    return output;
  end;
/

WbExport -type=text
         -file='ex2.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_ex2().getClobVal()
from dual;
/

WbExport -type=text
         -file='ex22.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_ex22().getClobVal()
from dual;
/

WbExport -type=text
         -file='ex23.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_ex23().getClobVal()
from dual;
/

WbExport -type=text
         -file='ex24.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select x_ex24().getClobVal()
from dual;
/



