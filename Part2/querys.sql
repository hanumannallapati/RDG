
1.	Write SQL to show the 10 coldest countries that have never medaled at the winter Olympics. 
    Show them in order of population – largest to smallest. 

Solution:

First pulled the list of countries who won a medal and that as a reference extracted 
countries who never medaled.

with countries_won_medals as ( select distinct country 
                                 from olympics.medals
                            )
select t.* 
  from (
         select t.country
              , p.population 
              , t.ave_temp 
           from olympics.population p
          inner join olympics.temperature t
                  on p.country = t.country
                 and p.country not in ( select cwm.country 
                                          from countries_won_medals cwm 
                                      )
          order by  t.ave_temp asc
          limit 10
       ) as t
 order by t.population desc
;

2. Write SQL to show the top 10 performing countries of all time at the winter Olympics 
   where a gold medal is worth 3 points, a silver medal 2 points and a bronze medal 1 point. 


Solution:

select m.country 
     , sum (
            case 
               when m.medal = 'gold' 
               then 3
               when m.medal = 'silver'
               then 2
               when m.medal = 'bronze'
               then 1
            end
           ) as points 
  from olympics.medals m
 group by m.country
 order by 2 desc
 limit 10;


3.	We know how much Britain spent on winter Olympics funding for some years. 
Write SQL to show the cost per medal for Britain – by year - where the data exists. 

Solution:

Converted the columns to rows (unpivot) and that as reference calculated the cost per medal.


with 
      funds 
         as (
              select f.country
                   , unnest(array[2002, 2006, 2010, 2014])  as years
                   , unnest(array[f.y2002, f.y2006, f.y2010, f.y2014]) funding
                from  olympics.funding f
            )
 select t.country
      , t.year
      , t.num_of_medals
      , t.cost_per_year
      , cost_per_year/num_of_medals as cost_per_medal
   from (
          select f.country 
               , m.year 
               , count(m.medal) num_of_medals
               , max(f.funding) as cost_per_year  
            from olympics.medals m
           inner join funds f 
                   on m.year = f.years
           where f.country = 'Britain'
           group by f.country , m.year
        ) t
;