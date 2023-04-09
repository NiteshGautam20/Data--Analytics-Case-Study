use revison;
select * FROM revison.spotify_activity;

-- Spotify_Activity table show the app-installed and app purchased activites for spotify app along with country details:

 /*Que1 Find the Total Active users each day ?
 event_date    Total_active_users
 2022-01-01      3
 2022-01-02      1
 2022-01-03      3
 2022-01-04      1 
 */
 Select event_date , count(distinct user_id) as Total_active_users from spotify_activity
 group by event_date;
 
 
/*Que2- Find total active users each week ?

Week_number        Total_active_users
1                     3
2                     5 
*/

Select week(event_date)+1 as week_number , count(distinct user_id) as Total_active_users  from spotify_activity
group by  week(event_date);

-- Note: We did +1 in week because we want week day start from monday(1) bydefault in mysql week day strat from sunday(0)...


/* Que-3 Find the date Wise total number of users who made the purchase same day they installed the app?

event_date          no_of_users_same_day_purchase
2022-01-01           0
2022-01-02           0
2022-01-03           2
2022-01-04           1
*/
With cte1 as
(Select user_id,event_date , count(distinct event_name) as event_status from spotify_activity
group by event_date , user_id
having count(distinct event_name)=2)
select s1.event_date ,count( distinct cte1.user_id) as no_of_users_same_day_purchase from spotify_activity as s1 
left join cte1 on s1.event_date =cte1.event_date
group by event_date;
-- or
select event_date , count(users) as no_of_users_same_day_purchase from
(Select event_date,COUNT(user_id) , count(distinct event_name) as event_status , CASE WHEN count(distinct event_name)=2 then 1 else null end as users from spotify_activity
group by event_date , user_id) n
group by event_date;

/* Que-4 Find the percentage of paid users in India ,usa , and any other should be taged as other?

Country   Percentage_users
India     40
USA       20
Other     40
*/

  with cte1 as
(Select case when country in('India' , 'USA') then country else 'Other' end  as new_Country , count(distinct user_id) as purchased_user from spotify_activity 
where event_name ="app-purchase" 
group by new_country)
,cte2 as(select count(user_id) as total_user from spotify_activity where event_name ="app-purchase")
select new_country as country , (purchased_user/total_user)*100 as Percentage_users  from cte1 
cross join cte2;


/* Que-5 Among all the users who installed app on given day , how many did in app purchased on the very next day -- day wise result 

event_date       cnt_users
2022-01-01          0
2022-01-02          1
2022-01-03          0
2022-01-04          0
*/
 
(select s1.event_date , count(s2.user_id) as cnt_users from spotify_activity as s1 
left join spotify_activity as s2 on s1.user_id =s2.user_id
and datediff(s1.event_date , s2.event_date)=1
and s2.event_name ="app-installed" and s1.event_name="app-purchase" 
group by s1.event_date);

-- or
with cte1 as
(select * ,lag(event_date,1) over(partition by user_id order by event_date) as previous_date,
lag(event_name,1) over(partition by user_id order by event_date) as previous_event_name from spotify_activity)
select event_date , count(distinct case when datediff(event_date,previous_date)=1 and previous_event_name ="app-installed" and event_name="app-purchase" then 1 else null end ) as cnt_users
from cte1
group by event_date
