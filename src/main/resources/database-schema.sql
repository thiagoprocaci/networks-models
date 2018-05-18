--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.10
-- Dumped by pg_dump version 9.5.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: answers_after_best(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION answers_after_best(community_name text) RETURNS TABLE(id_question bigint, id_user_answers_after_best bigint, best_answer_date timestamp without time zone, user_answer_date timestamp without time zone, diff_secs double precision, diff_min double precision, diff interval)
    LANGUAGE sql
    AS $_$


with QUESTION_SOLVED as (
	select *
	from post question
	where question.post_type = 1 
	and question.accepted_answer_comm_id is not null
	and question.id_community in (select id from community where name = $1)
), 
BEST_ANSWER as (
	select  question.id as id_question, 
			question.id_post_comm as id_question_comm,
			answer.id as id_answer, 
			answer.creation_date as answer_date ,
			answer.id_community
	from post answer 
	inner join QUESTION_SOLVED question on question.accepted_answer_comm_id = answer.id_post_comm
	where answer.post_type = 2
	and answer.id_community = question.id_community
) select ba.id_question,
		p.id_user as id_user_answers_after_best,
		ba.answer_date as best_answer_date,
		p.creation_date as user_answer_date,
		(select extract(epoch from(p.creation_date - ba.answer_date ))) as diff_secs,
		(select extract(epoch from(p.creation_date - ba.answer_date ))) / 60 as diff_min,
		(p.creation_date - ba.answer_date ) as diff
	from BEST_ANSWER ba, post p
	where 
	p.parent_post_comm_id = ba.id_question_comm
	and p.post_type = 2
	and p.id_community = ba.id_community
	and p.creation_date > ba.answer_date
	and p.id_user is not null
order by ba.id_question

$_$;


ALTER FUNCTION public.answers_after_best(community_name text) OWNER TO postgres;

--
-- Name: comm_user_ari(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_ari(community_name text) RETURNS TABLE(id bigint, category text, avg_ari double precision, avg_chars double precision, avg_syllabes double precision, avg_words double precision, avg_complex_words double precision, avg_sentences double precision)
    LANGUAGE sql
    AS $_$
with  user_ranking_profile as (
	select * from comm_user_ranking_profile($1)
)


select 
	u.id,
	u.category,
	avg(u.ari) as avg_ari,
	avg(u.characters_) as avg_chars,
	avg(u.syllables) as avg_syllabes,
	avg(u.words) as avg_words,
	avg(u.complexwords) as avg_complex_words,
	avg(u.sentences) as avg_sentences


from (

	select A.*,
	    case
		   	when A.top_5 = 1 then 'top_5'
		   	when A.top_5_10 = 1 then 'top_5_10'
		   	when A.top_10_15 = 1 then 'top_10_15'
		   	when A.top_15_20 = 1 then 'top_15_20'
		   	when A.top_20_25 = 1 then 'top_20_25'
		   	when A.top_25_30 = 1 then 'top_25_30'
		   	when A.top_30_35 = 1 then 'top_30_35'
		   	when A.top_35_40 = 1 then 'top_35_40'
		   	when A.top_40_45 = 1 then 'top_40_45'
		   	when A.top_45_50 = 1 then 'top_45_50'
		   	when A.top_50_100 = 1 then 'top_50_100'
		   	when A.no_participation = 1 then 'no_participation'
		   end as category

	from (
			select u.*,
				   p.ari_text as ari,
				   p.characters_text as characters_,
				   p.syllables_text as syllables,
				   p.words_text as words,
				   p.complexwords_text as complexwords,
				   p.sentences_text as sentences
			from post p
			inner join user_ranking_profile u on p.id_user = u.id
			where p.id_community in (select co.id from community co where co.name = $1)
			
			union all
			
			select u.*,
				   p.ari as ari,
				   p."characters" as characters_,
				   p.syllables as syllables,
				   p.words as words,
				   p.complexwords as complexwords,
				   p.sentences as sentences
			from "comment" p
			inner join user_ranking_profile u on p.id_user = u.id
			where p.id_community in (select co.id from community co where co.name = $1)
	)A
)u
group by u.id, u.category
$_$;


ALTER FUNCTION public.comm_user_ari(community_name text) OWNER TO postgres;

--
-- Name: comm_user_ari_by_category(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_ari_by_category(community_name text) RETURNS TABLE(category text, avg_ari double precision, avg_chars double precision, avg_syllabes double precision, avg_words double precision, avg_complex_words double precision, avg_sentences double precision)
    LANGUAGE sql
    AS $_$
select 
	A.category,
	A.avg_ari,
	A.avg_chars,
	A.avg_syllabes,
	A.avg_words,
	A.avg_complex_words,
	A.avg_sentences

	from (
	select 
		u.category,
		avg(u.avg_ari) as avg_ari,
		avg(u.avg_chars) as avg_chars,
		avg(u.avg_syllabes) as avg_syllabes,
		avg(u.avg_words) as avg_words,
		avg(u.avg_complex_words) as avg_complex_words,
		avg(u.avg_sentences) as avg_sentences,
		case
		   	when u.category = 'top_5' then 1
		   	when u.category = 'top_5_10' then 2
		   	when u.category = 'top_10_15' then 3
		   	when u.category = 'top_15_20' then 4
		   	when u.category = 'top_20_25' then 5
		   	when u.category = 'top_25_30' then 6
		   	when u.category = 'top_30_35' then 7
		   	when u.category = 'top_35_40' then 8
		   	when u.category = 'top_40_45' then 9
		   	when u.category = 'top_45_50' then 10
		   	when u.category = 'top_50_100' then 11
		   	when u.category = 'no_participation' then 12
		   end as category_id
	from comm_user_ari($1) u
	group by u.category 
)A order by A.category_id

$_$;


ALTER FUNCTION public.comm_user_ari_by_category(community_name text) OWNER TO postgres;

--
-- Name: comm_user_ari_over_time(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_ari_over_time(community_name text) RETURNS TABLE(id bigint, category text, period_post integer, avg_ari double precision, avg_chars double precision, avg_syllabes double precision, avg_words double precision, avg_complex_words double precision, avg_sentences double precision)
    LANGUAGE sql
    AS $_$

with  user_ranking_profile as (
	select * from comm_user_ranking_profile($1)
)


select
	u.id,
	u.category,
	u.period_post,
	avg(u.ari) as avg_ari,
	avg(u.characters_) as avg_chars,
	avg(u.syllables) as avg_syllabes,
	avg(u.words) as avg_words,
	avg(u.complexwords) as avg_complex_words,
	avg(u.sentences) as avg_sentences


from (

	select A.*,
	    case
		   	when A.top_5 = 1 then 'top_5'
		   	when A.top_5_10 = 1 then 'top_5_10'
		   	when A.top_10_15 = 1 then 'top_10_15'
		   	when A.top_15_20 = 1 then 'top_15_20'
		   	when A.top_20_25 = 1 then 'top_20_25'
		   	when A.top_25_30 = 1 then 'top_25_30'
		   	when A.top_30_35 = 1 then 'top_30_35'
		   	when A.top_35_40 = 1 then 'top_35_40'
		   	when A.top_40_45 = 1 then 'top_40_45'
		   	when A.top_45_50 = 1 then 'top_45_50'
		   	when A.top_50_100 = 1 then 'top_50_100'
		   	when A.no_participation = 1 then 'no_participation'
		   end as category

	from (
			select u.*,
				   p.ari_text as ari,
				   p.characters_text as characters_,
				   p.syllables_text as syllables,
				   p.words_text as words,
				   p.complexwords_text as complexwords,
				   p.sentences_text as sentences,
				   p.period as period_post
			from post p
			inner join user_ranking_profile u on p.id_user = u.id
			where p.id_community in (select co.id from community co where co.name = $1)

			union all

			select u.*,
				   p.ari as ari,
				   p."characters" as characters_,
				   p.syllables as syllables,
				   p.words as words,
				   p.complexwords as complexwords,
				   p.sentences as sentences,
				   p.period as period_post
			from "comment" p
			inner join user_ranking_profile u on p.id_user = u.id
			where p.id_community in (select co.id from community co where co.name = $1)
	)A
)u
group by u.id, u.category, u.period_post order by u.period_post 

$_$;


ALTER FUNCTION public.comm_user_ari_over_time(community_name text) OWNER TO postgres;

--
-- Name: comm_user_ari_overtime_by_category(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_ari_overtime_by_category(community_name text) RETURNS TABLE(category text, period_post integer, avg_ari double precision, avg_chars double precision, avg_syllabes double precision, avg_words double precision, avg_complex_words double precision, avg_sentences double precision)
    LANGUAGE sql
    AS $_$

select 
	u.category,
	u.period_post,
	avg(u.avg_ari) as avg_ari,
	avg(u.avg_chars) as avg_chars,
	avg(u.avg_syllabes) as avg_syllabes,
	avg(u.avg_words) as avg_words,
	avg(u.avg_complex_words) as avg_complex_words,
	avg(u.avg_sentences) as avg_sentences

from comm_user_ari_over_time($1) u
group by u.category, u.period_post order by  u.period_post
$_$;


ALTER FUNCTION public.comm_user_ari_overtime_by_category(community_name text) OWNER TO postgres;

--
-- Name: comm_user_basic_data(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_basic_data(community_name text) RETURNS TABLE(category text, website_null numeric, website_not_null numeric, location_null numeric, location_not_null numeric, age_null numeric, age_not_null numeric, about_me_null numeric, about_me_not_null numeric, total_user numeric, perc_website_null numeric, perc_website_not_null numeric, perc_location_null numeric, perc_location_not_null numeric, perc_age_null numeric, perc_age_not_null numeric, perc_about_me_null numeric, perc_about_me_not_null numeric)
    LANGUAGE sql
    AS $_$ 

select * from (

select B.*,
	(B.website_null / B.total_user * 100) as perc_website_null,
	(B.website_not_null / B.total_user * 100) as perc_website_not_null,
	(B.location_null / B.total_user * 100) as perc_location_null,
	(B.location_not_null / B.total_user * 100) as perc_location_not_null,
	(B.age_null / B.total_user * 100) as perc_age_null,
	(B.age_not_null / B.total_user * 100) as perc_age_not_null,	
	(B.about_me_null / B.total_user * 100) as perc_about_me_null,
	(B.about_me_not_null / B.total_user * 100) as perc_about_me_not_null

from (

select 
	A.category,
	sum(A.website_null) as website_null,
	sum(A.website_not_null) as website_not_null,
	sum(A.location_null) as location_null,
	sum(A.location_not_null) as location_not_null,	
	sum(A.age_null) as age_null,
	sum(A.age_not_null) as age_not_null,
	sum(A.about_me_null) as about_me_null,
	sum(A.about_me_not_null) as about_me_not_null,
	(sum(A.about_me_null) + sum(A.about_me_not_null)) as total_user
from (
	with USER_TAB as (
		select * from comm_user_ranking_profile($1)
	)
	
	select 
		'top_5' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_5' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.location is null

	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_5' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_5 = 1
	and u.about_me is not null
	
	union all 
	
	select 
		'top_5_10' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_5_10' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.location is null

	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_5_10' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_5_10 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_10_15' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_10_15' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.location is null

	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_10_15' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_10_15 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_15_20' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_15_20' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.location is null

	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_15_20' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_15_20 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_20_25' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_20_25' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.location is null

	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_20_25' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_20_25 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_25_30' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_25_30' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.location is null

	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_25_30' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_25_30 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_30_35' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_30_35' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.location is null

	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_30_35' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_30_35 = 1
	and u.about_me is not null
	
	union all 
	
	select 
		'top_35_40' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_35_40' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.location is null

	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_35_40' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_35_40 = 1
	and u.about_me is not null
	
	union all 
	
	select 
		'top_40_45' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_40_45' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.location is null

	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_40_45' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_40_45 = 1
	and u.about_me is not null
	
	union all
	select 
		'top_45_50' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_45_50' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.location is null

	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_45_50' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_45_50 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'top_50_100' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.website_url is null
	
	union all
	
	select 
		'top_50_100' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.location is null

	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.location is not null
	
	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.age is null
	
	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.age is not null
	
	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.about_me is null
	
	union all 
	
	select 
		'top_50_100' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.top_50_100 = 1
	and u.about_me is not null
	
	union all
	
	select 
		'no_participation' as category,
		count(*) as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.website_url is null
	
	union all
	
	select 
		'no_participation' as category,
		0  as website_null,
		count(*) as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.website_url is not null
	
	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		count(*) as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.location is null

	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		count(*) as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.location is not null
	
	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		count(*) as age_null,
		0 as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.age is null
	
	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		count(*) as age_not_null,
		0 as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.age is not null
	
	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		count(*) as about_me_null,
		0 as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.about_me is null
	
	union all 
	
	select 
		'no_participation' as category,
		0 as website_null,
		0 as website_not_null,
		0 as location_null,
		0 as location_not_null,
		0 as age_null,
		0 as age_not_null,
		0 as about_me_null,
		count(*) as about_me_not_null
	from USER_TAB u
	where u.no_participation = 1
	and u.about_me is not null
	
)A  group by A.category 

)B )C

order by C.perc_about_me_not_null desc
$_$;


ALTER FUNCTION public.comm_user_basic_data(community_name text) OWNER TO postgres;

--
-- Name: comm_user_by_discussion(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_by_discussion(community_name text) RETURNS TABLE(id_question bigint, id_user bigint)
    LANGUAGE sql
    AS $_$
select * from (

with QUESTION as (
	select * from post p where p.post_type = 1
	and p.id_community in (select id from community where name = $1)
),
ANSWERS as (
	select p.parent_post_comm_id, p.id_user  from post p where p.post_type = 2
	and p.id_community in (select id from community where name = $1) 
	and p.id_user is not null

),
QUESTION_COMMENTS as (
	select question.id as question_id, c.id_user from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user is not null

),
ANSWER_COMMENTS as (
	select question.id as question_id, c.id_user from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name =  $1)
	and c.id_community = answer.id_community
	and c.id_user is not null
	and answer.id_community = question.id_community

)

select question.id as id_question,
	   question.id_user
from QUESTION question
where question.id_user is not null

union all
	   
select question.id as id_question,
		answer.id_user
from QUESTION question
inner join  ANSWERS answer on answer.parent_post_comm_id = question.id_post_comm

union all 

select question.id as id_question,
		question_comm.id_user
		
from QUESTION question
inner join QUESTION_COMMENTS question_comm on question_comm.question_id = question.id


union all

select question.id as id_question,
		answer_comm.id_user
from QUESTION question
inner join ANSWER_COMMENTS answer_comm on answer_comm.question_id = question.id


)A order by A.id_question
$_$;


ALTER FUNCTION public.comm_user_by_discussion(community_name text) OWNER TO postgres;

--
-- Name: comm_user_participation(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_participation(community_name text) RETURNS TABLE(id bigint, about_me text, age integer, creation_date timestamp without time zone, display_name character varying, down_votes integer, id_user_comm bigint, last_access_date timestamp without time zone, location character varying, period integer, reputation integer, up_votes integer, views integer, website_url character varying, id_community integer, answers bigint, questions bigint, comments bigint, reviews bigint, accepted_answers bigint, votes_favorite_given bigint, votes_bounty_start_given bigint, total_participation bigint, total_participation_with_votes bigint)
    LANGUAGE sql
    AS $_$


select A.*, 
	(A.answers + A.questions + A.comments + A.reviews) as total_participation, 
	(A.answers + A.questions + A.comments + A.reviews + A.votes_favorite_given
	+ A.votes_bounty_start_given) as total_participation_with_votes
	from (

with USER_TABLE as (
	 select * from comm_user u where u.id_community in (select co.id from community co where co.name = $1)
),

 USER_QUESTIONS as (

	select u.id, count(*) as questions from comm_user u
		inner join post p on u.id = p.id_user
	where  p.post_type = 1
	and u.id_community in (select co.id from community co where co.name = $1)
	group by u.id

),
  USER_ANSWERS as (
	select u.id, count(*) as answers from comm_user u
		inner join post p on u.id = p.id_user
	where  p.post_type = 2
	and u.id_community in (select co.id from community co where co.name = $1)
	group by u.id
),
  USER_COMMENTS as (
	select u.id, count(*) as comments from comm_user u
		inner join "comment" p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	group by u.id
), USER_REVIEW as (
	select u.id, count(*) as reviews from comm_user u
		inner join post_history p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.post_history_type not in (1,2,3)
	group by u.id
), USER_ACCEPTED_ANSWERS as (
		with QUESTIONS_SOLVED as (
		select * from post p 
			where p.post_type = 1 and p.accepted_answer_comm_id is not null
			and p.id_community in (select co.id from community co where co.name = $1) 
		) select u.id, count(*) as accepted_answers from comm_user u
				inner join post p on u.id = p.id_user
				inner join QUESTIONS_SOLVED qs on qs.accepted_answer_comm_id = p.id_post_comm
			where  p.post_type = 2
			and u.id_community in (select co.id from community co where co.name = $1)
			group by u.id

), USER_VOTE_FAVORITE as (
	select u.id, count(*) as votes_favorite_given from comm_user u
		inner join vote p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.vote_type = 5
	group by u.id
	
), USER_VOTE_BOUNTY_START as (
	select u.id, count(*) as votes_bounty_start_given from comm_user u
		inner join vote p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.vote_type = 8
	group by u.id
)

select ut.*,
		COALESCE(ua.answers, 0) as answers,
		COALESCE(uq.questions, 0) as questions,
		COALESCE(uc.comments, 0) as comments,
		COALESCE(ur.reviews, 0) as reviews,
		COALESCE(uaa.accepted_answers, 0) as accepted_answers,
		COALESCE(uvf.votes_favorite_given, 0) as votes_favorite_given,
		COALESCE(uvbt.votes_bounty_start_given, 0) as votes_bounty_start_given
		from USER_TABLE ut
	left join USER_ANSWERS ua on ut.id = ua.id
	left join USER_QUESTIONS uq on ut.id = uq.id
	left join USER_COMMENTS uc on ut.id = uc.id
	left join USER_REVIEW ur on ut.id = ur.id
	left join USER_ACCEPTED_ANSWERS uaa on ut.id = uaa.id
	left join USER_VOTE_FAVORITE uvf on ut.id = uvf.id
	left join USER_VOTE_BOUNTY_START uvbt on ut.id = uvbt.id
	order by ut.reputation desc
)A

$_$;


ALTER FUNCTION public.comm_user_participation(community_name text) OWNER TO postgres;

--
-- Name: comm_user_participation_by_category(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_participation_by_category(community_name text) RETURNS TABLE(category text, questions numeric, answers numeric, comments numeric, ques_ans_comm numeric, reviews numeric, ques_ans_comm_rev numeric, accepted_answers numeric, total_users_in_category bigint, total_questions numeric, total_answers numeric, total_comments numeric, total_ques_ans_comm numeric, total_reviews numeric, total_ques_ans_comm_rev numeric, total_accepted_answers numeric, total_users_in_community numeric, perc_questions numeric, perc_answers numeric, perc_comments numeric, perc_ques_ans_comm numeric, perc_reviews numeric, perc_ques_ans_comm_rev numeric, perc_accepted_answers numeric, questions_per_user numeric, answers_per_user numeric, comments_per_user numeric, ques_ans_comm_per_user numeric, reviews_per_user numeric, ques_ans_comm_rev_per_user numeric, accepted_answers_per_user numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (

select 
	A.category,
	sum(A.questions) as questions, 
	sum(A.answers) as answers,
	sum(A.comments) as comments,
	(sum(A.questions) + sum(A.answers) + sum(A.comments)) as ques_ans_comm,
	sum(A.reviews) as reviews,
	(sum(A.questions) + sum(A.answers) + sum(A.comments) + sum(A.reviews)) as ques_ans_comm_rev,
	sum(A.accepted_answers) as accepted_answers,
	count(*) as total_users_in_category
	from (
	select u.*,
		case
		   	when u.top_5 = 1 then 'top_5'
		   	when u.top_5_10 = 1 then 'top_5_10'
		   	when u.top_10_15 = 1 then 'top_10_15'
		   	when u.top_15_20 = 1 then 'top_15_20'
		   	when u.top_20_25 = 1 then 'top_20_25'
		   	when u.top_25_30 = 1 then 'top_25_30'
		   	when u.top_30_35 = 1 then 'top_30_35'
		   	when u.top_35_40 = 1 then 'top_35_40'
		   	when u.top_40_45 = 1 then 'top_40_45'
		   	when u.top_45_50 = 1 then 'top_45_50'
		   	when u.top_50_100 = 1 then 'top_50_100'
		   	when u.no_participation = 1 then 'no_participation'
		   end as category,
		 case
		   	when u.top_5 = 1 then 1
		   	when u.top_5_10 = 1 then 2
		   	when u.top_10_15 = 1 then 3
		   	when u.top_15_20 = 1 then 4
		   	when u.top_20_25 = 1 then 5
		   	when u.top_25_30 = 1 then 6
		   	when u.top_30_35 = 1 then 7
		   	when u.top_35_40 = 1 then 8
		   	when u.top_40_45 = 1 then 9
		   	when u.top_45_50 = 1 then 10
		   	when u.top_50_100 = 1 then 11
		   	when u.no_participation = 1 then 12
		   end as category_id
	from comm_user_ranking_profile($1) u
	)A group by A.category, A.category_id order by A.category_id
) ,
GENERAL_PARTICIPATION as (
	select 
		sum(A.questions) as total_questions, 
		sum(A.answers) as total_answers,
		sum(A.comments) as total_comments,
		sum(A.ques_ans_comm) as total_ques_ans_comm,
		sum(A.reviews) as total_reviews,
		sum(A.ques_ans_comm_rev) as total_ques_ans_comm_rev,
		sum(A.accepted_answers) as total_accepted_answers,
		sum(total_users_in_category) as total_users_in_community	
	from participation_by_category A
),
all_data as (
	select * from participation_by_category, GENERAL_PARTICIPATION
)
select a.*,
	  (a.questions * 100/total_questions) as perc_questions,
	  (a.answers * 100/total_answers) as perc_answers,
	  (a.comments * 100/total_comments) as perc_comments,
	  (a.ques_ans_comm * 100/total_ques_ans_comm) as perc_ques_ans_comm,
	  (a.reviews * 100/total_reviews) as perc_reviews,
	  (a.ques_ans_comm_rev * 100/total_ques_ans_comm_rev) as perc_ques_ans_comm_rev,
	  (a.accepted_answers * 100/total_accepted_answers) as perc_accepted_answers,

	  (a.questions/total_users_in_category) as questions_per_user,
	  (a.answers/total_users_in_category) as answers_per_user,
	  (a.comments/total_users_in_category) as comments_per_user,
	  (a.ques_ans_comm/total_users_in_category) as ques_ans_comm_per_user,
	  (a.reviews/total_users_in_category) as reviews_per_user,
	  (a.ques_ans_comm_rev/total_users_in_category) as ques_ans_comm_rev_per_user,
	  (a.accepted_answers/total_users_in_category) as accepted_answers_per_user
	  
from all_data a

$_$;


ALTER FUNCTION public.comm_user_participation_by_category(community_name text) OWNER TO postgres;

--
-- Name: comm_user_participation_by_period(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_participation_by_period(community_name text) RETURNS TABLE(id bigint, period_participation integer, total_questions numeric, total_answers numeric, total_comments numeric, accepted_answers numeric, reviews numeric, votes_favorite_given numeric, votes_bounty_start_given numeric)
    LANGUAGE sql
    AS $_$
select 
	A.id,
	A.period_participation,
	sum(A.total_questions) as total_questions,
	sum(A.total_answers) as total_answers,
	sum(A.total_comments) as total_comments,
	sum(A.accepted_answers) as accepted_answers,
	sum(A.reviews) as reviews,
	sum(A.votes_favorite_given) as votes_favorite_given,
	sum(A.votes_bounty_start_given) as votes_bounty_start_given
	
from (

	select u.id, p.period as period_participation, 
		count(*) as total_questions, 
		0 as total_answers,
		0 as total_comments,
		0 as accepted_answers,
		0 as reviews, 
		0 as votes_favorite_given,
		0 as votes_bounty_start_given
	from comm_user u
			inner join post p on u.id = p.id_user
		where  p.post_type = 1 and p.period is not null
		and u.id_community in (select co.id from community co where co.name = $1)
		group by u.id, p.period
	
	union all
	
	select u.id, p.period as period_participation, 
		0 as total_questions, 
		count(*) as total_answers, 
		0 as total_comments,
		0 as accepted_answers,
		0 as reviews,
		0 as votes_favorite_given,
		0 as votes_bounty_start_given
	from comm_user u
			inner join post p on u.id = p.id_user
		where  p.post_type = 2 and p.period is not null
		and u.id_community in (select co.id from community co where co.name = $1)
		group by u.id, p.period
	
	union all 
	
	select u.id, p.period as period_participation, 
		0 as total_questions, 
		0 as total_answers, 
		count(*) as total_comments ,
		0 as accepted_answers,
		0 as reviews,
		0 as votes_favorite_given,
		0 as votes_bounty_start_given
	from comm_user u
			inner join "comment" p on u.id = p.id_user
		where  p.period is not null
		and u.id_community in (select co.id from community co where co.name = $1)
		group by u.id, p.period
		
	union all 
	
	select * from (
	with QUESTIONS_SOLVED as (
		select * from post p 
			where p.post_type = 1 and p.accepted_answer_comm_id is not null
			and p.id_community in (select co.id from community co where co.name = $1) 
		) select u.id, p.period as period_participation, 
			0 as total_questions, 
			0 as total_answers, 
			0 as total_comments ,
			count(*) as accepted_answers,
			0 as reviews,
			0 as votes_favorite_given,
			0 as votes_bounty_start_given
		from comm_user u
				inner join post p on u.id = p.id_user
				inner join QUESTIONS_SOLVED qs on qs.accepted_answer_comm_id = p.id_post_comm
			where  p.post_type = 2
			and u.id_community in (select co.id from community co where co.name = $1)
			group by u.id, p.period
	)AA 
	
	union all 
	
	select u.id, p.period as period_participation, 
		0 as total_questions, 
		0 as total_answers, 
		0 as total_comments ,
		0 as accepted_answers,
		count(*) as reviews,
		0 as votes_favorite_given,
		0 as votes_bounty_start_given
	from comm_user u
		inner join post_history p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.post_history_type not in (1,2,3)
	group by u.id, p.period

	union all
	
	select u.id, p.period as period_participation, 
		0 as total_questions, 
		0 as total_answers, 
		0 as total_comments ,
		0 as accepted_answers,
		0 as reviews,
		count(*) as votes_favorite_given ,
		0 as votes_bounty_start_given	
	from comm_user u
		inner join vote p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.vote_type = 5
	group by u.id, p.period
	
	union all
	
	select u.id, p.period as period_participation, 
		0 as total_questions, 
		0 as total_answers, 
		0 as total_comments ,
		0 as accepted_answers,
		0 as reviews,
		0 as votes_favorite_given,
		count(*) as votes_bounty_start_given 
	from comm_user u
		inner join vote p on u.id = p.id_user
	where
	u.id_community in (select co.id from community co where co.name = $1)
	and p.vote_type = 8
	group by u.id, p.period
)A 

group by A.id, A.period_participation order by sum(A.total_answers) desc
$_$;


ALTER FUNCTION public.comm_user_participation_by_period(community_name text) OWNER TO postgres;

--
-- Name: comm_user_participation_by_period_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_participation_by_period_with_profile(community_name text) RETURNS TABLE(id bigint, period_participation integer, total_questions numeric, total_answers numeric, total_comments numeric, accepted_answers numeric, reviews numeric, votes_favorite_given numeric, votes_bounty_start_given numeric, top_5 integer, top_5_10 integer, top_10_15 integer, top_15_20 integer, top_20_25 integer, top_25_30 integer, top_30_35 integer, top_35_40 integer, top_40_45 integer, top_45_50 integer, top_50_100 integer, no_participation integer)
    LANGUAGE sql
    AS $_$

with USER_PROFILE as (
	select * from comm_user_ranking_profile($1)
)
select  up.* ,
u.top_5,
u.top_5_10, 
u.top_10_15, 
u.top_15_20, 
u.top_20_25, 
u.top_25_30, 
u.top_30_35, 
u.top_35_40, 
u.top_40_45, 
u.top_45_50, 
u.top_50_100, 
u.no_participation

from comm_user_participation_by_period($1) up
inner join USER_PROFILE u on u.id = up.id

$_$;


ALTER FUNCTION public.comm_user_participation_by_period_with_profile(community_name text) OWNER TO postgres;

--
-- Name: comm_user_ranking_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comm_user_ranking_profile(community_name text) RETURNS TABLE(id bigint, about_me text, age integer, creation_date timestamp without time zone, display_name character varying, down_votes integer, id_user_comm bigint, last_access_date timestamp without time zone, location character varying, period integer, reputation integer, up_votes integer, views integer, website_url character varying, id_community integer, answers bigint, questions bigint, comments bigint, reviews bigint, accepted_answers bigint, votes_favorite_given bigint, votes_bounty_start_given bigint, total_participation bigint, total_participation_with_votes bigint, top_5 integer, top_10 integer, top_15 integer, top_20 integer, top_25 integer, top_30 integer, top_35 integer, top_40 integer, top_45 integer, top_50 integer, top_5_10 integer, top_10_15 integer, top_15_20 integer, top_20_25 integer, top_25_30 integer, top_30_35 integer, top_35_40 integer, top_40_45 integer, top_45_50 integer, top_50_100 integer, no_participation integer)
    LANGUAGE sql
    AS $_$ 
select B.id, 
B.about_me, 
B.age, 
B.creation_date, 
B.display_name, 
B.down_votes, 
B.id_user_comm, 
B.last_access_date, 
B.location, 
B.period,
B.reputation,
B.up_votes, 
B.views, 
B.website_url, 
B.id_community, 
B.answers, 
B.questions, 
B.comments, 
B.reviews, 
B.accepted_answers, 
B.votes_favorite_given, 
B.votes_bounty_start_given, 
B.total_participation, 
B.total_participation_with_votes, 
B.top_5, 
B.top_10, 
B.top_15, 
B.top_20, 
B.top_25, 
B.top_30, 
B.top_35, 
B.top_40, 
B.top_45, 
B.top_50,  
	case when B.top_5 = 0 and B.top_10 = 1  then 1
		 else 0 
		 end as top_5_10,
		 
	case when B.top_10 = 0 and B.top_15 = 1  then 1
		 else 0 
		 end as top_10_15,

	case when B.top_15 = 0 and B.top_20 = 1  then 1
		 else 0 
		 end as top_15_20,

	case when B.top_20 = 0 and B.top_25 = 1  then 1
		 else 0 
		 end as top_20_25,
		 
	case when B.top_25 = 0 and B.top_30 = 1  then 1
		 else 0 
		 end as top_25_30,	 
	
	case when B.top_30 = 0 and B.top_35 = 1  then 1
		 else 0 
		 end as top_30_35,
		
	case when B.top_35 = 0 and B.top_40 = 1  then 1
		 else 0 
		 end as top_35_40,
	
	case when B.top_40 = 0 and B.top_45 = 1  then 1
		 else 0 
		 end as top_40_45,
	
	case when B.top_45 = 0 and B.top_50 = 1  then 1
		 else 0 
		 end as top_45_50,

	case when B.top_50 = 0  then 1
		 else 0 
		 end as top_50_100,
		 
		 0 as no_participation
from (

	select
		A.*,
	
		case
			when A.ranking <= (A.total * 5/100) then 1
			when A.ranking > (A.total * 5/100) then 0
		end as top_5,
	
		case
			when A.ranking <= (A.total * 10/100) then 1
			when A.ranking > (A.total * 10/100) then 0
		end as top_10,
	
		case
			when A.ranking <= (A.total * 15/100) then 1
			when A.ranking > (A.total * 15/100) then 0
		end as top_15,
	
		case
			when A.ranking <= (A.total * 20/100) then 1
			when A.ranking > (A.total * 20/100) then 0
		end as top_20,
	
		case
			when A.ranking <= (A.total * 25/100) then 1
			when A.ranking > (A.total * 25/100) then 0
		end as top_25,
	
		case
			when A.ranking <= (A.total * 30/100) then 1
			when A.ranking > (A.total * 30/100) then 0
		end as top_30,
	
		case
			when A.ranking <= (A.total * 35/100) then 1
			when A.ranking > (A.total * 35/100) then 0
		end as top_35,
	
		case
			when A.ranking <= (A.total * 40/100) then 1
			when A.ranking > (A.total * 40/100) then 0
		end as top_40,
	
		case
			when A.ranking <= (A.total * 45/100) then 1
			when A.ranking > (A.total * 45/100) then 0
		end as top_45,
	
		case
			when A.ranking <= (A.total * 50/100) then 1
			when A.ranking > (A.total * 50/100) then 0
		end as top_50
	
	from
	
	
	(
		SELECT 
			u.*,
		    row_number() OVER (
		            order by u.reputation desc
		    ) as ranking,
		    (select count(*) from comm_user_participation($1)
		    where total_participation > 0) as total
		  FROM comm_user_participation($1) u
		  where u.total_participation > 0
		  order by u.reputation desc
	)A
)B

union all 

select B.id, 
B.about_me, 
B.age, 
B.creation_date, 
B.display_name, 
B.down_votes, 
B.id_user_comm, 
B.last_access_date, 
B.location, 
B.period,
B.reputation,
B.up_votes, 
B.views, 
B.website_url, 
B.id_community, 
B.answers, 
B.questions, 
B.comments, 
B.reviews, 
B.accepted_answers, 
B.votes_favorite_given, 
B.votes_bounty_start_given, 
B.total_participation, 
B.total_participation_with_votes ,
		0 as top_5,
		0 as top_10,
		0 as top_15,
		0 as top_20,
		0 as top_25,
		0 as top_30,
		0 as top_35,
		0 as top_40,
		0 as top_45,
		0 as top_50,
		0 as top_5_10, 
		0 as top_10_15,
		0 as top_15_20,
		0 as top_20_25,
		0 as top_25_30,	 
	 	0 as top_30_35,
		0 as top_35_40,
		0 as top_40_45,
		0 as top_45_50,
		0  as top_50_100,
		1 as no_participation
		 
		 
from (
		SELECT 
			u.*
		  FROM comm_user_participation($1) u
		  where u.total_participation = 0
		  order by u.reputation desc

)B

$_$;


ALTER FUNCTION public.comm_user_ranking_profile(community_name text) OWNER TO postgres;

--
-- Name: count_citation_by_unique_display_name(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_citation_by_unique_display_name(community_name text) RETURNS TABLE(display_name text, count bigint, id_user bigint)
    LANGUAGE sql
    AS $_$


select A.*,
	u.id as id_user

from (

	with USERNAMES as (
		select u.display_name from comm_user u where id_community in (
				select id from community where name in ( $1 )
			) group by display_name having count(*) = 1
	)
	select u.display_name, count(*) from USERNAMES u, find_citation($1) c 
	
	where c.citation like '@' || u.display_name
	or
	c.citation like '@' || u.display_name || ','
	or
	c.citation like '@' || u.display_name || ':'
	or
	c.citation like '@' || u.display_name || '.'
	or
	c.citation like '@' || u.display_name || '''s'
	
	
	group by u.display_name

)A inner join comm_user u on u.display_name = A.display_name

where id_community in (
				select id from community where name in ( $1 )
			)
$_$;


ALTER FUNCTION public.count_citation_by_unique_display_name(community_name text) OWNER TO postgres;

--
-- Name: count_i_usage(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_i_usage(community_name text) RETURNS TABLE(id_user bigint, count_i_usage bigint)
    LANGUAGE sql
    AS $_$

select 	
  A.id_user,
  count(*) as count_I_usage
 
from (
select * from find_tokens($1)
	
)A

where lower(A.token)
in ('i', 'id', 'i''d','i''ll','im','i''m', 'ive', 'i''ve', 'me',
'mine', 'my', 'myself') 

group by A.id_user order by count(*) desc
$_$;


ALTER FUNCTION public.count_i_usage(community_name text) OWNER TO postgres;

--
-- Name: count_i_usage_per_user_and_post(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_i_usage_per_user_and_post(community_name text) RETURNS TABLE(category text, total_category numeric, total numeric, usage_per_user numeric, usage_per_post numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (
	select * from comm_user_participation_by_category($1)

),
count_usage_group as (
	select c.category, sum(c.count_i_usage) as total_category
	from count_i_usage_with_profile($1) c
	group by c.category
),
sum_usage as (
	select sum(c.total_category) as total from count_usage_group c
),
all_usage as (
	select * from count_usage_group, sum_usage
)
 
select a.*,
	(a.total_category / p.total_users_in_category) as usage_per_user,
	(a.total_category / p.ques_ans_comm) as usage_per_post

from all_usage a
inner join participation_by_category p 
on a.category = p.category

$_$;


ALTER FUNCTION public.count_i_usage_per_user_and_post(community_name text) OWNER TO postgres;

--
-- Name: count_i_usage_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_i_usage_with_profile(community_name text) RETURNS TABLE(id_user bigint, count_i_usage bigint, category text)
    LANGUAGE sql
    AS $_$
select c.*, 
 	case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

from count_i_usage($1) c
inner join comm_user_ranking_profile($1) u
on u.id = c.id_user
$_$;


ALTER FUNCTION public.count_i_usage_with_profile(community_name text) OWNER TO postgres;

--
-- Name: count_she_he_usage(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_she_he_usage(community_name text) RETURNS TABLE(id_user bigint, count_she_he_usage bigint)
    LANGUAGE sql
    AS $_$

select 	
  A.id_user,
  count(*) as count_she_he_usage
 
from (
select * from find_tokens($1)
	
)A

where lower(A.token)
in (
'he',
'hed',
'he''d',
'her',
'hers',
'herself',
'hes',
'he''s',
'him',
'himself',
'his',
'oneself',
'she',
'she''d',
'she''ll',
'shes',
'she''s'
) 

group by A.id_user order by count(*) desc
$_$;


ALTER FUNCTION public.count_she_he_usage(community_name text) OWNER TO postgres;

--
-- Name: count_she_he_usage_per_user_and_post(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_she_he_usage_per_user_and_post(community_name text) RETURNS TABLE(category text, total_category numeric, total numeric, usage_per_user numeric, usage_per_post numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (
	select * from comm_user_participation_by_category($1)

),
count_usage_group as (
	select c.category, sum(c.count_she_he_usage) as total_category
	from count_she_he_usage_with_profile($1) c
	group by c.category
),
sum_usage as (
	select sum(c.total_category) as total from count_usage_group c
),
all_usage as (
	select * from count_usage_group, sum_usage
)
 
select a.*,
	(a.total_category / p.total_users_in_category) as usage_per_user,
	(a.total_category / p.ques_ans_comm) as usage_per_post

from all_usage a
inner join participation_by_category p 
on a.category = p.category

$_$;


ALTER FUNCTION public.count_she_he_usage_per_user_and_post(community_name text) OWNER TO postgres;

--
-- Name: count_she_he_usage_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_she_he_usage_with_profile(community_name text) RETURNS TABLE(id_user bigint, count_she_he_usage bigint, category text)
    LANGUAGE sql
    AS $_$
select c.*, 
 	case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

from count_she_he_usage($1) c
inner join comm_user_ranking_profile($1) u
on u.id = c.id_user
$_$;


ALTER FUNCTION public.count_she_he_usage_with_profile(community_name text) OWNER TO postgres;

--
-- Name: count_they_usage(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_they_usage(community_name text) RETURNS TABLE(id_user bigint, count_they_usage bigint)
    LANGUAGE sql
    AS $_$

select 	
  A.id_user,
  count(*) as count_they_usage
 
from (
select * from find_tokens($1)
	
)A

where lower(A.token)
in (
'their',
'them',
'themselves',
'they',
'theyd',
'they''d',
'theyll',
'they''ll',
'theyve',
'they''ve'

) 

group by A.id_user order by count(*) desc
$_$;


ALTER FUNCTION public.count_they_usage(community_name text) OWNER TO postgres;

--
-- Name: count_they_usage_per_user_and_post(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_they_usage_per_user_and_post(community_name text) RETURNS TABLE(category text, total_category numeric, total numeric, usage_per_user numeric, usage_per_post numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (
	select * from comm_user_participation_by_category($1)

),
count_usage_group as (
	select c.category, sum(c.count_they_usage) as total_category
	from count_they_usage_with_profile($1) c
	group by c.category
),
sum_usage as (
	select sum(c.total_category) as total from count_usage_group c
),
all_usage as (
	select * from count_usage_group, sum_usage
)
 
select a.*,
	(a.total_category / p.total_users_in_category) as usage_per_user,
	(a.total_category / p.ques_ans_comm) as usage_per_post

from all_usage a
inner join participation_by_category p 
on a.category = p.category

$_$;


ALTER FUNCTION public.count_they_usage_per_user_and_post(community_name text) OWNER TO postgres;

--
-- Name: count_they_usage_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_they_usage_with_profile(community_name text) RETURNS TABLE(id_user bigint, count_they_usage bigint, category text)
    LANGUAGE sql
    AS $_$
select c.*, 
 	case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

from count_they_usage($1) c
inner join comm_user_ranking_profile($1) u
on u.id = c.id_user
$_$;


ALTER FUNCTION public.count_they_usage_with_profile(community_name text) OWNER TO postgres;

--
-- Name: count_we_usage(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_we_usage(community_name text) RETURNS TABLE(id_user bigint, count_we_usage bigint)
    LANGUAGE sql
    AS $_$

select 	
  A.id_user,
  count(*) as count_we_usage
 
from (
select * from find_tokens($1)
	
)A

where lower(A.token)
in (
'lets',
'let''s',
'our',
'ours',
'ourselves',
'us',
'we',
'we''d',
'we''ll',
'we''re',
'weve',
'we''ve'
) 

group by A.id_user order by count(*) desc
$_$;


ALTER FUNCTION public.count_we_usage(community_name text) OWNER TO postgres;

--
-- Name: count_we_usage_per_user_and_post(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_we_usage_per_user_and_post(community_name text) RETURNS TABLE(category text, total_category numeric, total numeric, usage_per_user numeric, usage_per_post numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (
	select * from comm_user_participation_by_category($1)

),
count_usage_group as (
	select c.category, sum(c.count_we_usage) as total_category
	from count_we_usage_with_profile($1) c
	group by c.category
),
sum_usage as (
	select sum(c.total_category) as total from count_usage_group c
),
all_usage as (
	select * from count_usage_group, sum_usage
)
 
select a.*,
	(a.total_category / p.total_users_in_category) as usage_per_user,
	(a.total_category / p.ques_ans_comm) as usage_per_post

from all_usage a
inner join participation_by_category p 
on a.category = p.category

$_$;


ALTER FUNCTION public.count_we_usage_per_user_and_post(community_name text) OWNER TO postgres;

--
-- Name: count_we_usage_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_we_usage_with_profile(community_name text) RETURNS TABLE(id_user bigint, count_we_usage bigint, category text)
    LANGUAGE sql
    AS $_$
select c.*, 
 	case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

from count_we_usage($1) c
inner join comm_user_ranking_profile($1) u
on u.id = c.id_user
$_$;


ALTER FUNCTION public.count_we_usage_with_profile(community_name text) OWNER TO postgres;

--
-- Name: count_you_usage(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_you_usage(community_name text) RETURNS TABLE(id_user bigint, count_you_usage bigint)
    LANGUAGE sql
    AS $_$

select 	
  A.id_user,
  count(*) as count_you_usage
 
from (
select * from find_tokens($1)
	
)A

where lower(A.token)
in (
'thee',
'thine',
'thou',
'thoust',
'thy',
'ya',
'yall',
'y''all',
'ye',
'you',
'youd',
'you''d',
'youll',
'you''ll',
'your' ,
'youre',
'you''re',
'yours',
'youve',
'you''ve'
) 

group by A.id_user order by count(*) desc
$_$;


ALTER FUNCTION public.count_you_usage(community_name text) OWNER TO postgres;

--
-- Name: count_you_usage_per_user_and_post(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_you_usage_per_user_and_post(community_name text) RETURNS TABLE(category text, total_category numeric, total numeric, usage_per_user numeric, usage_per_post numeric)
    LANGUAGE sql
    AS $_$

with participation_by_category as (
	select * from comm_user_participation_by_category($1)

),
count_usage_group as (
	select c.category, sum(c.count_you_usage) as total_category
	from count_you_usage_with_profile($1) c
	group by c.category
),
sum_usage as (
	select sum(c.total_category) as total from count_usage_group c
),
all_usage as (
	select * from count_usage_group, sum_usage
)
 
select a.*,
	(a.total_category / p.total_users_in_category) as usage_per_user,
	(a.total_category / p.ques_ans_comm) as usage_per_post

from all_usage a
inner join participation_by_category p 
on a.category = p.category

$_$;


ALTER FUNCTION public.count_you_usage_per_user_and_post(community_name text) OWNER TO postgres;

--
-- Name: count_you_usage_with_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION count_you_usage_with_profile(community_name text) RETURNS TABLE(id_user bigint, count_you_usage bigint, category text)
    LANGUAGE sql
    AS $_$
select c.*, 
 	case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

from count_you_usage($1) c
inner join comm_user_ranking_profile($1) u
on u.id = c.id_user
$_$;


ALTER FUNCTION public.count_you_usage_with_profile(community_name text) OWNER TO postgres;

--
-- Name: desc_community(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION desc_community(community_name text) RETURNS TABLE(count bigint, desc_ text)
    LANGUAGE sql
    AS $_$

select count(*), 'users' as desc_ 
from comm_user where id_community in (select id from community where name = $1)
union all 

select count(*), 'questions' as desc_ 
from post where id_community in (select id from community where name = $1)
and post_type = 1

union all 

select count(*), 'answers' as desc_ 
from post where id_community in (select id from community where name = $1)
and post_type = 2

union all 

select count(*), 'comments' as desc_ 
from "comment" where id_community in (select id from community where name = $1)

$_$;


ALTER FUNCTION public.desc_community(community_name text) OWNER TO postgres;

--
-- Name: discussion_analysis(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION discussion_analysis(community_name text) RETURNS TABLE(id_question bigint, period integer, finished integer, thread_length bigint, total_top_5_participation bigint, question_made_by_top_5 bigint, answers_by_top_5 bigint, comments_by_top_5 bigint, question_comment_by_top_5 bigint, answer_comment_by_top_5 bigint, total_top_5_10_participation bigint, question_made_by_top_5_10 bigint, answers_by_top_5_10 bigint, comments_by_top_5_10 bigint, question_comment_by_top_5_10 bigint, answer_comment_by_top_5_10 bigint, total_top_10_15_participation bigint, question_made_by_top_10_15 bigint, answers_by_top_10_15 bigint, comments_by_top_10_15 bigint, question_comment_by_top_10_15 bigint, answer_comment_by_top_10_15 bigint, total_top_15_20_participation bigint, question_made_by_top_15_20 bigint, answers_by_top_15_20 bigint, comments_by_top_15_20 bigint, question_comment_by_top_15_20 bigint, answer_comment_by_top_15_20 bigint, total_top_20_25_participation bigint, question_made_by_top_20_25 bigint, answers_by_top_20_25 bigint, comments_by_top_20_25 bigint, question_comment_by_top_20_25 bigint, answer_comment_by_top_20_25 bigint, total_top_25_30_participation bigint, question_made_by_top_25_30 bigint, answers_by_top_25_30 bigint, comments_by_top_25_30 bigint, question_comment_by_top_25_30 bigint, answer_comment_by_top_25_30 bigint, total_top_30_35_participation bigint, question_made_by_top_30_35 bigint, answers_by_top_30_35 bigint, comments_by_top_30_35 bigint, question_comment_by_top_30_35 bigint, answer_comment_by_top_30_35 bigint, total_top_35_40_participation bigint, question_made_by_top_35_40 bigint, answers_by_top_35_40 bigint, comments_by_top_35_40 bigint, question_comment_by_top_35_40 bigint, answer_comment_by_top_35_40 bigint, total_top_40_45_participation bigint, question_made_by_top_40_45 bigint, answers_by_top_40_45 bigint, comments_by_top_40_45 bigint, question_comment_by_top_40_45 bigint, answer_comment_by_top_40_45 bigint, total_top_45_50_participation bigint, question_made_by_top_45_50 bigint, answers_by_top_45_50 bigint, comments_by_top_45_50 bigint, question_comment_by_top_45_50 bigint, answer_comment_by_top_45_50 bigint, total_top_50_100_participation bigint, question_made_by_top_50_100 bigint, answers_by_top_50_100 bigint, comments_by_top_50_100 bigint, question_comment_by_top_50_100 bigint, answer_comment_by_top_50_100 bigint, total_null_user_participation bigint, question_made_by_null_user bigint, answers_by_null_user bigint, comments_by_null_user bigint, question_comment_by_null_user bigint, answer_comment_by_null_user bigint, total_answer_count integer, total_answer_comment_count bigint, total_question_comment_count bigint)
    LANGUAGE sql
    AS $_$

with QUESTIONS as (
	select *
	from post p
	where
	p.post_type = 1
	and p.id_community in (select id from community where name = $1)
) ,

ANSWER_COMMENTS as (
	select question.id, count(*)  as answer_comment_count from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	group by question.id

),
QUESTION_COMMENTS as (
	select question.id, count(*)  as question_comment_count from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	group by question.id

),
USER_CLASSIFICATION as (
	select * from comm_user_ranking_profile($1)
),
QUESTION_MADE_BY_TOP_5 as (
	select question.id, count(*) as question_made_by_top_5 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5 = 1)
	group by question.id
),
ANSWERS_BY_TOP_5 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_5 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_5 as (
	select question.id, count(*)  as question_comment_by_top_5 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_5 as (
	select question.id, count(*)  as answer_comment_by_top_5 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_5_10 as (
	select question.id, count(*) as question_made_by_top_5_10 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5_10 = 1)
	group by question.id
),
ANSWERS_BY_TOP_5_10 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_5_10 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5_10 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_5_10 as (
	select question.id, count(*)  as question_comment_by_top_5_10 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5_10 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_5_10 as (
	select question.id, count(*)  as answer_comment_by_top_5_10 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_5_10 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_10_15 as (
	select question.id, count(*) as question_made_by_top_10_15 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_10_15 = 1)
	group by question.id
),
ANSWERS_BY_TOP_10_15 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_10_15 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_10_15 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_10_15 as (
	select question.id, count(*)  as question_comment_by_top_10_15 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_10_15 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_10_15 as (
	select question.id, count(*)  as answer_comment_by_top_10_15 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_10_15 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_15_20 as (
	select question.id, count(*) as question_made_by_top_15_20 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_15_20 = 1)
	group by question.id
),
ANSWERS_BY_TOP_15_20 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_15_20 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_15_20 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_15_20 as (
	select question.id, count(*)  as question_comment_by_top_15_20 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_15_20 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_15_20 as (
	select question.id, count(*)  as answer_comment_by_top_15_20 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_15_20 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_20_25 as (
	select question.id, count(*) as question_made_by_top_20_25 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_20_25 = 1)
	group by question.id
),
ANSWERS_BY_TOP_20_25 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_20_25 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_20_25 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_20_25 as (
	select question.id, count(*)  as question_comment_by_top_20_25 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_20_25 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_20_25 as (
	select question.id, count(*)  as answer_comment_by_top_20_25 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_20_25 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_25_30 as (
	select question.id, count(*) as question_made_by_top_25_30 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_25_30 = 1)
	group by question.id
),
ANSWERS_BY_TOP_25_30 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_25_30 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_25_30 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_25_30 as (
	select question.id, count(*)  as question_comment_by_top_25_30 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_25_30 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_25_30 as (
	select question.id, count(*)  as answer_comment_by_top_25_30 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_25_30 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_30_35 as (
	select question.id, count(*) as question_made_by_top_30_35 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_30_35 = 1)
	group by question.id
),
ANSWERS_BY_TOP_30_35 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_30_35 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_30_35 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_30_35 as (
	select question.id, count(*)  as question_comment_by_top_30_35 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_30_35 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_30_35 as (
	select question.id, count(*)  as answer_comment_by_top_30_35 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_30_35 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_35_40 as (
	select question.id, count(*) as question_made_by_top_35_40 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_35_40 = 1)
	group by question.id
),
ANSWERS_BY_TOP_35_40 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_35_40 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_35_40 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_35_40 as (
	select question.id, count(*)  as question_comment_by_top_35_40 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_35_40 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_35_40 as (
	select question.id, count(*)  as answer_comment_by_top_35_40 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_35_40 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_40_45 as (
	select question.id, count(*) as question_made_by_top_40_45 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_40_45 = 1)
	group by question.id
),
ANSWERS_BY_TOP_40_45 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_40_45 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_40_45 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_40_45 as (
	select question.id, count(*)  as question_comment_by_top_40_45 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_40_45 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_40_45 as (
	select question.id, count(*)  as answer_comment_by_top_40_45 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_40_45 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_45_50 as (
	select question.id, count(*) as question_made_by_top_45_50 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_45_50 = 1)
	group by question.id
),
ANSWERS_BY_TOP_45_50 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_45_50 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_45_50 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_45_50 as (
	select question.id, count(*)  as question_comment_by_top_45_50 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_45_50 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_45_50 as (
	select question.id, count(*)  as answer_comment_by_top_45_50 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_45_50 = 1)
	group by question.id
),
QUESTION_MADE_BY_TOP_50_100 as (
	select question.id, count(*) as question_made_by_top_50_100 from QUESTIONS question
	where question.id_user in (select u.id from USER_CLASSIFICATION u where u.top_50_100 = 1)
	group by question.id
),
ANSWERS_BY_TOP_50_100 as (
	select p.parent_post_comm_id, count(*) as answers_by_top_50_100 from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user in (select u.id from USER_CLASSIFICATION u where u.top_50_100 = 1)
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_TOP_50_100 as (
	select question.id, count(*)  as question_comment_by_top_50_100 from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_50_100 = 1)
	group by question.id
),
ANSWER_COMMENTS_BY_TOP_50_100 as (
	select question.id, count(*)  as answer_comment_by_top_50_100 from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user in (select u.id from USER_CLASSIFICATION u where u.top_50_100 = 1)
	group by question.id
),
QUESTION_MADE_BY_NULL_USER as (
	select question.id, count(*) as question_made_by_NULL_USER from QUESTIONS question
	where question.id_user is null
	group by question.id
),
ANSWERS_BY_NULL_USER as (
	select p.parent_post_comm_id, count(*) as answers_by_NULL_USER from post p
	where p.post_type = 2
	and p.id_community in (select id from community where name = $1)
	and p.id_user is null
	group by p.parent_post_comm_id
),
QUESTION_COMMENTS_BY_NULL_USER as (
	select question.id, count(*)  as question_comment_by_NULL_USER from "comment" c
	inner join post question on question.id = c.id_post
	where
	question.post_type = 1
	and c.id_community in (select id from community where name = $1)
	and c.id_community = question.id_community
	and c.id_user is null
	group by question.id
),
ANSWER_COMMENTS_BY_NULL_USER as (
	select question.id, count(*)  as answer_comment_by_NULL_USER from "comment" c
	inner join post answer on answer.id = c.id_post
	inner join post question on answer.parent_post_comm_id = question.id_post_comm
	where
	answer.post_type = 2
	and c.id_community in (select id from community where name = $1)
	and c.id_community = answer.id_community
	and answer.id_community = question.id_community
	and c.id_user is null
	group by question.id
)

select q.id as id_question, q.period,
		case 
			when q.accepted_answer_comm_id is not null then 1
			else 0
		end as finished,
	   (1 + COALESCE(q.answer_count,0) + COALESCE(a.answer_comment_count,0) + COALESCE(qc.question_comment_count,0)) as thread_length,
	   
	   (COALESCE(qtop5.question_made_by_top_5,0) + COALESCE(atop5.answers_by_top_5,0) + COALESCE(qctop5.question_comment_by_top_5,0) + COALESCE(actop5.answer_comment_by_top_5,0)) as total_top_5_participation,
	   
	   
	   COALESCE(qtop5.question_made_by_top_5,0) as question_made_by_top_5,
	   COALESCE(atop5.answers_by_top_5,0) as answers_by_top_5,
	   (COALESCE(qctop5.question_comment_by_top_5,0) + COALESCE(actop5.answer_comment_by_top_5,0)) as comments_by_top_5,
	   COALESCE(qctop5.question_comment_by_top_5,0) as question_comment_by_top_5,
	   COALESCE(actop5.answer_comment_by_top_5,0) as answer_comment_by_top_5,
	   
	   (COALESCE(qtop510.question_made_by_top_5_10,0) + COALESCE(atop510.answers_by_top_5_10,0) + COALESCE(qctop510.question_comment_by_top_5_10,0) + COALESCE(actop510.answer_comment_by_top_5_10,0)) as total_top_5_10_participation,
	   COALESCE(qtop510.question_made_by_top_5_10,0) as question_made_by_top_5_10,
	   COALESCE(atop510.answers_by_top_5_10,0) as answers_by_top_5_10,
	   (COALESCE(qctop510.question_comment_by_top_5_10,0) + COALESCE(actop510.answer_comment_by_top_5_10,0)) as comments_by_top_5_10,
		COALESCE(qctop510.question_comment_by_top_5_10,0) as question_comment_by_top_5_10,
		COALESCE(actop510.answer_comment_by_top_5_10,0) as answer_comment_by_top_5_10,
	 
		(COALESCE(qtop1015.question_made_by_top_10_15,0) + COALESCE(atop1015.answers_by_top_10_15,0) + COALESCE(qctop1015.question_comment_by_top_10_15,0) + COALESCE(actop1015.answer_comment_by_top_10_15,0)) as total_top_10_15_participation,
		COALESCE(qtop1015.question_made_by_top_10_15,0) as question_made_by_top_10_15,
		COALESCE(atop1015.answers_by_top_10_15,0) as answers_by_top_10_15,
		(COALESCE(qctop1015.question_comment_by_top_10_15,0) + COALESCE(actop1015.answer_comment_by_top_10_15,0)) as comments_by_top_10_15,
		COALESCE(qctop1015.question_comment_by_top_10_15,0) as question_comment_by_top_10_15,
		COALESCE(actop1015.answer_comment_by_top_10_15,0) as answer_comment_by_top_10_15,
		
		(COALESCE(qtop1520.question_made_by_top_15_20,0) + COALESCE(atop1520.answers_by_top_15_20,0) + COALESCE(qctop1520.question_comment_by_top_15_20,0) + COALESCE(actop1520.answer_comment_by_top_15_20,0)) as total_top_15_20_participation,
		COALESCE(qtop1520.question_made_by_top_15_20,0) as question_made_by_top_15_20,
		COALESCE(atop1520.answers_by_top_15_20,0) as answers_by_top_15_20,
		(COALESCE(qctop1520.question_comment_by_top_15_20,0) + COALESCE(actop1520.answer_comment_by_top_15_20,0)) as comments_by_top_15_20,
		COALESCE(qctop1520.question_comment_by_top_15_20,0) as question_comment_by_top_15_20,
		COALESCE(actop1520.answer_comment_by_top_15_20,0) as answer_comment_by_top_15_20,
		
		(COALESCE(qtop2025.question_made_by_top_20_25,0) + COALESCE(atop2025.answers_by_top_20_25,0) + COALESCE(qctop2025.question_comment_by_top_20_25,0) + COALESCE(actop2025.answer_comment_by_top_20_25,0)) as total_top_20_25_participation,
		COALESCE(qtop2025.question_made_by_top_20_25,0) as question_made_by_top_20_25,
		COALESCE(atop2025.answers_by_top_20_25,0) as answers_by_top_20_25,
		(COALESCE(qctop2025.question_comment_by_top_20_25,0) + COALESCE(actop2025.answer_comment_by_top_20_25,0)) as comments_by_top_20_25,
		COALESCE(qctop2025.question_comment_by_top_20_25,0) as question_comment_by_top_20_25,
		COALESCE(actop2025.answer_comment_by_top_20_25,0) as answer_comment_by_top_20_25,

		(COALESCE(qtop2530.question_made_by_top_25_30,0) + COALESCE(atop2530.answers_by_top_25_30,0) + COALESCE(qctop2530.question_comment_by_top_25_30,0) + COALESCE(actop2530.answer_comment_by_top_25_30,0)) as total_top_25_30_participation,
		COALESCE(qtop2530.question_made_by_top_25_30,0) as question_made_by_top_25_30,
		COALESCE(atop2530.answers_by_top_25_30,0) as answers_by_top_25_30,
		(COALESCE(qctop2530.question_comment_by_top_25_30,0) + COALESCE(actop2530.answer_comment_by_top_25_30,0)) as comments_by_top_25_30,
		COALESCE(qctop2530.question_comment_by_top_25_30,0) as question_comment_by_top_25_30,
		COALESCE(actop2530.answer_comment_by_top_25_30,0) as answer_comment_by_top_25_30,
		
		(COALESCE(qtop3035.question_made_by_top_30_35,0) + COALESCE(atop3035.answers_by_top_30_35,0) + COALESCE(qctop3035.question_comment_by_top_30_35,0) + COALESCE(actop3035.answer_comment_by_top_30_35,0)) as total_top_30_35_participation,
		COALESCE(qtop3035.question_made_by_top_30_35,0) as question_made_by_top_30_35,
		COALESCE(atop3035.answers_by_top_30_35,0) as answers_by_top_30_35,
		(COALESCE(qctop3035.question_comment_by_top_30_35,0) + COALESCE(actop3035.answer_comment_by_top_30_35,0)) as comments_by_top_30_35,
		COALESCE(qctop3035.question_comment_by_top_30_35,0) as question_comment_by_top_30_35,
		COALESCE(actop3035.answer_comment_by_top_30_35,0) as answer_comment_by_top_30_35,
		
		(COALESCE(qtop3540.question_made_by_top_35_40,0) + COALESCE(atop3540.answers_by_top_35_40,0) + COALESCE(qctop3540.question_comment_by_top_35_40,0) + COALESCE(actop3540.answer_comment_by_top_35_40,0)) as total_top_35_40_participation,
		COALESCE(qtop3540.question_made_by_top_35_40,0) as question_made_by_top_35_40,
		COALESCE(atop3540.answers_by_top_35_40,0) as answers_by_top_35_40,
		(COALESCE(qctop3540.question_comment_by_top_35_40,0) + COALESCE(actop3540.answer_comment_by_top_35_40,0)) as comments_by_top_35_40,
		COALESCE(qctop3540.question_comment_by_top_35_40,0) as question_comment_by_top_35_40,
		COALESCE(actop3540.answer_comment_by_top_35_40,0) as answer_comment_by_top_35_40,
		
		(COALESCE(qtop4045.question_made_by_top_40_45,0) + COALESCE(atop4045.answers_by_top_40_45,0) + COALESCE(qctop4045.question_comment_by_top_40_45,0) + COALESCE(actop4045.answer_comment_by_top_40_45,0)) as total_top_40_45_participation,
		COALESCE(qtop4045.question_made_by_top_40_45,0) as question_made_by_top_40_45,
		COALESCE(atop4045.answers_by_top_40_45,0) as answers_by_top_40_45,
		(COALESCE(qctop4045.question_comment_by_top_40_45,0) + COALESCE(actop4045.answer_comment_by_top_40_45,0)) as comments_by_top_40_45,
		COALESCE(qctop4045.question_comment_by_top_40_45,0) as question_comment_by_top_40_45,
		COALESCE(actop4045.answer_comment_by_top_40_45,0) as answer_comment_by_top_40_45,
		
		(COALESCE(qtop4550.question_made_by_top_45_50,0) + COALESCE(atop4550.answers_by_top_45_50,0) + COALESCE(qctop4550.question_comment_by_top_45_50,0) + COALESCE(actop4550.answer_comment_by_top_45_50,0)) as total_top_45_50_participation,
		COALESCE(qtop4550.question_made_by_top_45_50,0) as question_made_by_top_45_50,
		COALESCE(atop4550.answers_by_top_45_50,0) as answers_by_top_45_50,
		(COALESCE(qctop4550.question_comment_by_top_45_50,0) + COALESCE(actop4550.answer_comment_by_top_45_50,0)) as comments_by_top_45_50,
		COALESCE(qctop4550.question_comment_by_top_45_50,0) as question_comment_by_top_45_50,
		COALESCE(actop4550.answer_comment_by_top_45_50,0) as answer_comment_by_top_45_50,
	   
		(COALESCE(qtop50100.question_made_by_top_50_100,0) + COALESCE(atop50100.answers_by_top_50_100,0) + COALESCE(qctop50100.question_comment_by_top_50_100,0) + COALESCE(actop50100.answer_comment_by_top_50_100,0)) as total_top_50_100_participation,
		COALESCE(qtop50100.question_made_by_top_50_100,0) as question_made_by_top_50_100,
		COALESCE(atop50100.answers_by_top_50_100,0) as answers_by_top_50_100,
		(COALESCE(qctop50100.question_comment_by_top_50_100,0) + COALESCE(actop50100.answer_comment_by_top_50_100,0)) as comments_by_top_50_100,
		COALESCE(qctop50100.question_comment_by_top_50_100,0) as question_comment_by_top_50_100,
		COALESCE(actop50100.answer_comment_by_top_50_100,0) as answer_comment_by_top_50_100,
		
		(COALESCE(qnullUser.question_made_by_NULL_USER,0) + COALESCE(anullUser.answers_by_NULL_USER,0) + COALESCE(qcnullUser.question_comment_by_NULL_USER,0) + COALESCE(acnullUser.answer_comment_by_NULL_USER,0)) as total_NULL_USER_participation,
		COALESCE(qnullUser.question_made_by_NULL_USER,0) as question_made_by_NULL_USER,
		COALESCE(anullUser.answers_by_NULL_USER,0) as answers_by_NULL_USER,
		(COALESCE(qcnullUser.question_comment_by_NULL_USER,0) + COALESCE(acnullUser.answer_comment_by_NULL_USER,0)) as comments_by_NULL_USER,
		COALESCE(qcnullUser.question_comment_by_NULL_USER,0) as question_comment_by_NULL_USER,
		COALESCE(acnullUser.answer_comment_by_NULL_USER,0) as answer_comment_by_NULL_USER,
		
	   COALESCE(q.answer_count,0) as total_answer_count,
	   COALESCE(a.answer_comment_count,0) as total_answer_comment_count,
	   COALESCE(qc.question_comment_count,0) as total_question_comment_count
	from  QUESTIONS q
	left join ANSWER_COMMENTS a on a.id = q.id
	left join QUESTION_COMMENTS qc on qc.id = q.id
	
	left join QUESTION_MADE_BY_TOP_5 qtop5 on qtop5.id = q.id 
	left join ANSWERS_BY_TOP_5 atop5 on atop5.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_5 qctop5 on qctop5.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_5 actop5 on actop5.id = q.id 
	
	left join QUESTION_MADE_BY_TOP_5_10 qtop510 on qtop510.id = q.id 
	left join ANSWERS_BY_TOP_5_10 atop510 on atop510.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_5_10 qctop510 on qctop510.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_5_10 actop510 on actop510.id = q.id 	
	 
	left join QUESTION_MADE_BY_TOP_10_15 qtop1015 on qtop1015.id = q.id 
	left join ANSWERS_BY_TOP_10_15 atop1015 on atop1015.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_10_15 qctop1015 on qctop1015.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_10_15 actop1015 on actop1015.id = q.id 
	
	left join QUESTION_MADE_BY_TOP_15_20 qtop1520 on qtop1520.id = q.id 
	left join ANSWERS_BY_TOP_15_20 atop1520 on atop1520.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_15_20 qctop1520 on qctop1520.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_15_20 actop1520 on actop1520.id = q.id 
	
	left join QUESTION_MADE_BY_TOP_20_25 qtop2025 on qtop2025.id = q.id 
	left join ANSWERS_BY_TOP_20_25 atop2025 on atop2025.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_20_25 qctop2025 on qctop2025.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_20_25 actop2025 on actop2025.id = q.id 
	
	left join QUESTION_MADE_BY_TOP_25_30 qtop2530 on qtop2530.id = q.id 
	left join ANSWERS_BY_TOP_25_30 atop2530 on atop2530.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_25_30 qctop2530 on qctop2530.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_25_30 actop2530 on actop2530.id = q.id
	
	left join QUESTION_MADE_BY_TOP_30_35 qtop3035 on qtop3035.id = q.id 
	left join ANSWERS_BY_TOP_30_35 atop3035 on atop3035.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_30_35 qctop3035 on qctop3035.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_30_35 actop3035 on actop3035.id = q.id	
	
	left join QUESTION_MADE_BY_TOP_35_40 qtop3540 on qtop3540.id = q.id 
	left join ANSWERS_BY_TOP_35_40 atop3540 on atop3540.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_35_40 qctop3540 on qctop3540.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_35_40 actop3540 on actop3540.id = q.id
	
	left join QUESTION_MADE_BY_TOP_40_45 qtop4045 on qtop4045.id = q.id 
	left join ANSWERS_BY_TOP_40_45 atop4045 on atop4045.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_40_45 qctop4045 on qctop4045.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_40_45 actop4045 on actop4045.id = q.id
	
	left join QUESTION_MADE_BY_TOP_45_50 qtop4550 on qtop4550.id = q.id 
	left join ANSWERS_BY_TOP_45_50 atop4550 on atop4550.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_45_50 qctop4550 on qctop4550.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_45_50 actop4550 on actop4550.id = q.id
	
	left join QUESTION_MADE_BY_TOP_50_100 qtop50100 on qtop50100.id = q.id 
	left join ANSWERS_BY_TOP_50_100 atop50100 on atop50100.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_TOP_50_100 qctop50100 on qctop50100.id = q.id
	left join ANSWER_COMMENTS_BY_TOP_50_100 actop50100 on actop50100.id = q.id
	
	left join QUESTION_MADE_BY_NULL_USER qnullUser on qnullUser.id = q.id 
	left join ANSWERS_BY_NULL_USER anullUser on anullUser.parent_post_comm_id = q.id_post_comm
	left join QUESTION_COMMENTS_BY_NULL_USER qcnullUser on qcnullUser.id = q.id
	left join ANSWER_COMMENTS_BY_NULL_USER acnullUser on acnullUser.id = q.id
	
	
	-- order by (COALESCE(qtop5.question_made_by_top_5,0) + COALESCE(atop5.answers_by_top_5,0) + COALESCE(qctop5.question_comment_by_top_5,0) + COALESCE(actop5.answer_comment_by_top_5,0))

	$_$;


ALTER FUNCTION public.discussion_analysis(community_name text) OWNER TO postgres;

--
-- Name: find_citation(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_citation(community_name text) RETURNS TABLE(citation text, id_user bigint, id_post bigint, type_ text)
    LANGUAGE sql
    AS $_$

select 	
 *
from (
	select
		regexp_split_to_table(p.body, E'\\s+') as citation,
		p.id_user  as id_user,
		p.id as id_post,
		case 
			when p.post_type = 1 then 'question'
			when p.post_type = 2 then 'answer'
		end as type_
	 from post p
	where p.id_community in (select id from community where name = $1)
	and p.body is not null
	
	union all 
	
	select 
		regexp_split_to_table(p."text", E'\\s+') as citation,
		p.id_user  as id_user,
		p.id as id_post,
		'comm' as type_
	  from "comment" p
	where p.id_community in (select id from community where name = $1)
	and p."text" is not null
	
)A where A.citation like '@%'

$_$;


ALTER FUNCTION public.find_citation(community_name text) OWNER TO postgres;

--
-- Name: find_tokens(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_tokens(community_name text) RETURNS TABLE(token text, id_user bigint, id_post bigint, type_ text)
    LANGUAGE sql
    AS $_$

select
		regexp_split_to_table(p.body, E'\\s+') as token,
		p.id_user  as id_user,
		p.id as id_post,
		case 
			when p.post_type = 1 then 'question'
			when p.post_type = 2 then 'answer'
		end as type_
	 from post p
	where p.id_community in (select id from community where name = $1)
	and p.body is not null
	
	union all 
	
	select 
		regexp_split_to_table(p."text", E'\\s+') as token,
		p.id_user  as id_user,
		p.id as id_post,
		'comm' as type_
	  from "comment" p
	where p.id_community in (select id from community where name = $1)
	and p."text" is not null
$_$;


ALTER FUNCTION public.find_tokens(community_name text) OWNER TO postgres;

--
-- Name: find_user_activities(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_user_activities(community_name text) RETURNS TABLE(id_user bigint, post_creation_date timestamp without time zone, type_ text)
    LANGUAGE sql
    AS $_$
select A.id_user, A.creation_date as post_creation_date, A.type_  from (
	select p.id, p.id_user, p.creation_date,
		case 
			when p.post_type = 1 then 'question'
			when p.post_type = 2 then 'answer'
		end as type_
		from post p where p.id_community in (select id from community where name = $1)
	union all
	
	select p.id, p.id_user, p.creation_date,
		'comment 'as type_
		from "comment" p where p.id_community in (select id from community where name = $1)
	
	union all 

		select p.id, p.id_user, p.creation_date,
		'post_history 'as type_
		from post_history p where 
		p.id_community in (select id from community where name = $1)
		and p.post_history_type not  in (1,2,3)
	
)A where A.id_user is not null   
order by  A.creation_date asc

$_$;


ALTER FUNCTION public.find_user_activities(community_name text) OWNER TO postgres;

--
-- Name: last_graph_analysis_context(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION last_graph_analysis_context(community_name text) RETURNS TABLE(id bigint, avg_clustering_coef double precision, avg_degree double precision, avg_dist double precision, density double precision, diameter double precision, edges integer, id_community integer, modularity double precision, modularity_with_resolution double precision, nodes integer, number_communities integer, period integer, radius double precision, strongly_component_count integer, weakly_component_count integer)
    LANGUAGE sql
    AS $_$


select 
ctx.id,
ctx.avg_clustering_coef,
ctx.avg_degree,
ctx.avg_dist,
ctx.density,
ctx.diameter,
ctx.edges,
ctx.id_community,
ctx.modularity,
ctx.modularity_with_resolution,
ctx.nodes,
ctx.number_communities,
ctx.period,
ctx.radius,
ctx.strongly_component_count,
ctx.weakly_component_count


from graph_analysis_context ctx 
where ctx.id_community in (select id from community where name = $1)
and ctx.period in (
	select max(ctx.period) from graph_analysis_context ctx 
	where ctx.id_community in (select id from community where name = $1)
)


$_$;


ALTER FUNCTION public.last_graph_analysis_context(community_name text) OWNER TO postgres;

--
-- Name: percent_score_types_per_post_and_user_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION percent_score_types_per_post_and_user_profile(community_name text) RETURNS TABLE(posts_neg_score bigint, posts_zero_score bigint, posts_pos_score bigint, category text, perc_posts_neg double precision, perc_posts_zero double precision, perc_posts_pos double precision)
    LANGUAGE sql
    AS $_$

with USER_PROFILE as (
	select * from comm_user_ranking_profile($1)
),

POST_USER as (
	select p.score,
		   u.id,
		   u.top_5,
		   u.top_5_10,
		   u.top_10_15,
		   u.top_15_20,
		   u.top_20_25,
		   u.top_25_30,
	 	   u.top_30_35,
		   u.top_35_40,
		   u.top_40_45,
		   u.top_45_50,
		   u.top_50_100
	from post p
	inner join USER_PROFILE u on p.id_user = u.id
	where  p.id_community in (select id from community where name = $1)

	union all

	select p.score,
		   u.id,
		   u.top_5,
		   u.top_5_10,
		   u.top_10_15,
		   u.top_15_20,
		   u.top_20_25,
		   u.top_25_30,
	 	   u.top_30_35,
		   u.top_35_40,
		   u.top_40_45,
		   u.top_45_50,
		   u.top_50_100
	from "comment" p
	inner join USER_PROFILE u on p.id_user = u.id
	where  p.id_community in (select id from community where name = $1)
) 

select A.*,
	  ((100 * A.posts_neg_score)/(cast(A.posts_neg_score + A.posts_zero_score + A.posts_pos_score as double precision))) as perc_posts_neg,
	  ((100 * A.posts_zero_score)/(cast(A.posts_neg_score + A.posts_zero_score + A.posts_pos_score as double precision))) as perc_posts_zero,
	  ((100 * A.posts_pos_score)/(cast(A.posts_neg_score + A.posts_zero_score + A.posts_pos_score as double precision))) as perc_posts_pos
	from (
  select
	(select count(*) from POST_USER u where u.top_5 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_5 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_5 = 1 and u.score > 0) as posts_pos_score,
	'top_5' as category 
	
	union all
 
  select
	(select count(*) from POST_USER u where u.top_5_10 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_5_10 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_5_10 = 1 and u.score > 0) as posts_pos_score,
	'top_5_10' as category 
	
	union all
 
  select
	(select count(*) from POST_USER u where u.top_10_15 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_10_15 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_10_15 = 1 and u.score > 0) as posts_pos_score,
	'top_10_15' as category 

	union all
 
  select
	(select count(*) from POST_USER u where u.top_15_20 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_15_20 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_15_20 = 1 and u.score > 0) as posts_pos_score,
	'top_15_20' as category 	

	union all
 
  select
	(select count(*) from POST_USER u where u.top_20_25 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_20_25 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_20_25 = 1 and u.score > 0) as posts_pos_score,
	'top_20_25' as category 	
	
	union all
 
  select
	(select count(*) from POST_USER u where u.top_25_30 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_25_30 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_25_30 = 1 and u.score > 0) as posts_pos_score,
	'top_25_30' as category 		

	union all
 
  select
	(select count(*) from POST_USER u where u.top_30_35 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_30_35 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_30_35 = 1 and u.score > 0) as posts_pos_score,
	'top_30_35' as category	

	union all
 
  select
	(select count(*) from POST_USER u where u.top_35_40 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_35_40 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_35_40 = 1 and u.score > 0) as posts_pos_score,
	'top_35_40' as category		
	
 	union all
 
  select
	(select count(*) from POST_USER u where u.top_40_45 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_40_45 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_40_45 = 1 and u.score > 0) as posts_pos_score,
	'top_40_45' as category		
	
 	union all
 
  select
	(select count(*) from POST_USER u where u.top_45_50 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_45_50 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_45_50 = 1 and u.score > 0) as posts_pos_score,
	'top_45_50' as category			
	
	 	union all
 
  select
	(select count(*) from POST_USER u where u.top_50_100 = 1 and u.score < 0) as posts_neg_score,
	(select count(*) from POST_USER u where u.top_50_100 = 1 and u.score = 0) as posts_zero_score,
	(select count(*) from POST_USER u where u.top_50_100 = 1 and u.score > 0) as posts_pos_score,
	'top_50_100' as category		
	
)A
$_$;


ALTER FUNCTION public.percent_score_types_per_post_and_user_profile(community_name text) OWNER TO postgres;

--
-- Name: post_tags(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION post_tags(community_name text) RETURNS TABLE(id bigint, accepted_answer_comm_id bigint, answer_count integer, ari_text double precision, ari_title double precision, body text, characters_text double precision, characters_title double precision, closed_date timestamp without time zone, coleman_liau_text double precision, coleman_liau_title double precision, comment_count integer, community_owned_date timestamp without time zone, complexwords_text double precision, complexwords_title double precision, creation_date timestamp without time zone, favorite_count integer, flesch_kincaid_text double precision, flesch_kincaid_title double precision, flesch_reading_text double precision, flesch_reading_title double precision, gunning_fog_text double precision, gunning_fog_title double precision, id_post_comm bigint, id_user_community bigint, last_activity_date timestamp without time zone, last_edit_date timestamp without time zone, last_editor_display_name character varying, last_editor_user_community_id bigint, parent_post_comm_id bigint, period integer, post_type integer, score integer, sentences_text double precision, sentences_title double precision, smog_index_text double precision, smog_index_title double precision, smog_text double precision, smog_title double precision, syllables_text double precision, syllables_title double precision, tags character varying, title character varying, view_count integer, words_text double precision, words_title double precision, id_community integer, id_user bigint, tag1 text, tag2 text, tag3 text, tag4 text, tag5 text, tag6 text)
    LANGUAGE sql
    AS $_$
select p.* ,
replace(split_part(p.tags,'>',1 ), '<', '') as tag1,
replace(replace(replace(split_part(p.tags,'>',2), split_part(p.tags,'>',1), ''), '>', '' ), '<', '')
as tag2,
replace(replace(	replace(split_part(p.tags,'>',3), split_part(p.tags,'>',2), ''), '>', '' ), '<', '')
as tag3,
replace(replace(	replace(split_part(p.tags,'>',4), split_part(p.tags,'>',3), ''), '>', '' ), '<', '')
as tag4,
replace(replace(	replace(split_part(p.tags,'>',5), split_part(p.tags,'>',4), ''), '>', '' ), '<', '')
as tag5,
replace(replace(	replace(split_part(p.tags,'>',6), split_part(p.tags,'>',5), ''), '>', '' ), '<', '')
as tag6

from post p 
where p.post_type = 1
and p.id_community in (select c.id from community c where c.name = $1)


$_$;


ALTER FUNCTION public.post_tags(community_name text) OWNER TO postgres;

--
-- Name: summary_indegree(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION summary_indegree(community_name text) RETURNS TABLE(value double precision, desc_ text)
    LANGUAGE sql
    AS $_$

with quartiles as ( 
select indegree, ntile(4) over (order by indegree) as quartile from graph_node 
	where id_graph_analysis_context in (
		select id from last_graph_analysis_context($1)
	) 
)
select min(indegree) as "value", 'min' as desc_ from quartiles
union all
select max(indegree) as "value",  'first_quartile' as desc_ from quartiles  where quartile = 1
union all
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER by indegree) as "value", 'median' as desc_ from graph_node 
	where id_graph_analysis_context in (
		select id from last_graph_analysis_context($1)
	) 

union all
select avg(indegree) as "value", 'mean' as desc_ from quartiles
union all
select max(indegree) as "value",  'third_quartile' as desc_ from quartiles  where quartile = 3
union all
select max(indegree) as "value", 'max' as desc_ from quartiles

$_$;


ALTER FUNCTION public.summary_indegree(community_name text) OWNER TO postgres;

--
-- Name: summary_outdegree(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION summary_outdegree(community_name text) RETURNS TABLE(value double precision, desc_ text)
    LANGUAGE sql
    AS $_$

with quartiles as (
select outdegree, ntile(4) over (order by outdegree) as quartile from graph_node
	where id_graph_analysis_context in (
		select id from last_graph_analysis_context($1)
	)
)
select min(outdegree) as "value", 'min' as desc_ from quartiles
union all
select max(outdegree) as "value",  'first_quartile' as desc_ from quartiles  where quartile = 1
union all
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER by outdegree) as "value", 'median' as desc_ from graph_node
	where id_graph_analysis_context in (
		select id from last_graph_analysis_context($1)
	)

union all
select avg(outdegree) as "value", 'mean' as desc_ from quartiles
union all
select max(outdegree) as "value",  'third_quartile' as desc_ from quartiles  where quartile = 3
union all
select max(outdegree) as "value", 'max' as desc_ from quartiles

$_$;


ALTER FUNCTION public.summary_outdegree(community_name text) OWNER TO postgres;

--
-- Name: summary_reputation(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION summary_reputation(community_name text) RETURNS TABLE(value double precision, desc_ text)
    LANGUAGE sql
    AS $_$

with quartiles as ( 
select reputation, ntile(4) over (order by reputation) as quartile from comm_user 
where id_community in (select id from community where name = $1)
)
select min(reputation) as "value", 'min' as desc_ from quartiles
union all
select max(reputation) as "value",  'first_quartile' as desc_ from quartiles  where quartile = 1
union all
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER by reputation) as "value", 'median' as desc_ FROM comm_user
where id_community in (select id from community where name = $1)
union all
select avg(reputation) as "value", 'mean' as desc_ from quartiles
union all
select max(reputation) as "value",  'third_quartile' as desc_ from quartiles  where quartile = 3
union all
select max(reputation) as "value", 'max' as desc_ from quartiles

$_$;


ALTER FUNCTION public.summary_reputation(community_name text) OWNER TO postgres;

--
-- Name: summary_score_by_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION summary_score_by_profile(community_name text) RETURNS TABLE(min_score integer, max_score integer, avg_score numeric, variance_score numeric, stddev_score numeric, category text)
    LANGUAGE sql
    AS $_$ 
with USER_PROFILE as (
	select * from comm_user_ranking_profile($1)
), 

POST_USER as (
	select p.score,
		   u.id,
		   u.top_5,
		   u.top_5_10,
		   u.top_10_15,
		   u.top_15_20,
		   u.top_20_25,
		   u.top_25_30,
	 	   u.top_30_35,
		   u.top_35_40,
		   u.top_40_45,
		   u.top_45_50,
		   u.top_50_100
	from post p  
	inner join USER_PROFILE u on p.id_user = u.id
	where  p.id_community in (select id from community where name = $1)
	
	union all
	
	select p.score,
		   u.id,
		   u.top_5,
		   u.top_5_10,
		   u.top_10_15,
		   u.top_15_20,
		   u.top_20_25,
		   u.top_25_30,
	 	   u.top_30_35,
		   u.top_35_40,
		   u.top_40_45,
		   u.top_45_50,
		   u.top_50_100
	from "comment" p  
	inner join USER_PROFILE u on p.id_user = u.id
	where  p.id_community in (select id from community where name = $1)
) 
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_5' as category from POST_USER u where u.top_5 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_5_10' as category from POST_USER u where u.top_5_10 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_10_15' as category from POST_USER u where u.top_10_15 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_15_20' as category from POST_USER u where u.top_15_20 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_20_25' as category from POST_USER u where u.top_20_25 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_25_30' as category from POST_USER u where u.top_25_30 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_30_35' as category from POST_USER u where u.top_30_35 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_35_40' as category from POST_USER u where u.top_35_40 = 1
union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_40_45' as category from POST_USER u where u.top_40_45 = 1
	union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_45_50' as category from POST_USER u where u.top_45_50 = 1
	union all
select 
	min(u.score) as min_score,
	max(u.score) as max_score,
	avg(u.score) as avg_score ,
	variance(u.score) as variance_score,
	stddev(u.score) as stddev_score,
	'top_50_100' as category from POST_USER u where u.top_50_100 = 1
$_$;


ALTER FUNCTION public.summary_score_by_profile(community_name text) OWNER TO postgres;

--
-- Name: tag_layer(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tag_layer(community_name text) RETURNS TABLE(tag text, count bigint, pos bigint, layer text)
    LANGUAGE sql
    AS $_$
with TAGS as  (
	select
	id,
	tag1,
	tag2,
	tag3
	from post_tags($1)
),
IMPORTANCE as (
	select count(*), A.tag from (
		select tag1 as tag
		from TAGS t

		union all

		select tag2 as tag
		from TAGS t

		union all

		select tag3 as tag
		from TAGS t

	)A
	where  length(A.tag) >0
	group by A.tag order by count(*) desc
),
RANKING as (
	select tag, "count", rank() over (order by "count" desc) as pos  from IMPORTANCE
)



select *,
	case
		when "count" >= 1000 then '1'
		when "count" >= 500 and "count" < 1000 then '2'
		when "count" >= 100 and "count" < 500 then '3'
		else '4'
	end as layer

from RANKING order by pos asc

$_$;


ALTER FUNCTION public.tag_layer(community_name text) OWNER TO postgres;

--
-- Name: tags_per_user_profile(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tags_per_user_profile(community_name text) RETURNS TABLE(tag text, top_5 numeric, top_5_10 numeric, top_10_15 numeric, top_15_20 numeric, top_20_25 numeric, top_25_30 numeric, top_30_35 numeric, top_35_40 numeric, top_40_45 numeric, top_45_50 numeric, top_50_100 numeric)
    LANGUAGE sql
    AS $_$
with TAGS as (
	select 
		id as id_question,
		tag1,
		tag2,
		tag3
	from post_tags($1) d
),
TAG_PER_QUESTION as (	
	
	select   
		d.id_question,
		d.total_top_5_participation as top_5,
		d.total_top_5_10_participation as top_5_10,
		d.total_top_10_15_participation as top_10_15,
		d.total_top_15_20_participation as top_15_20,
		d.total_top_20_25_participation as top_20_25,
		d.total_top_25_30_participation as top_25_30,
		d.total_top_30_35_participation as top_30_35,
		d.total_top_35_40_participation as top_35_40,
		d.total_top_40_45_participation as top_40_45,
		d.total_top_45_50_participation as top_45_50,
		d.total_top_50_100_participation as top_50_100,
		t.*
	from discussion_analysis($1) d
	inner join TAGS t on t.id_question = d.id_question

) 

select 
	A.tag as tag,
	sum(A.top_5) as top_5,
	sum(A.top_5_10) as top_5_10,
	sum(A.top_10_15) as top_10_15,
	sum(A.top_15_20) as top_15_20,
	sum(A.top_20_25) as top_20_25,
	sum(A.top_25_30) as top_25_30,
	sum(A.top_30_35) as top_30_35,
	sum(A.top_35_40) as top_35_40,
	sum(A.top_40_45) as top_40_45,
	sum(A.top_45_50) as top_45_50,
	sum(A.top_50_100) as top_50_100
		

  from (
	select 
		q.tag1 as tag,
		sum(q.top_5) as top_5,
		sum(q.top_5_10) as top_5_10,
		sum(q.top_10_15) as top_10_15,
		sum(q.top_15_20) as top_15_20,
		sum(q.top_20_25) as top_20_25,
		sum(q.top_25_30) as top_25_30,
		sum(q.top_30_35) as top_30_35,
		sum(q.top_35_40) as top_35_40,
		sum(q.top_40_45) as top_40_45,
		sum(q.top_45_50) as top_45_50,
		sum(q.top_50_100) as top_50_100
	from TAG_PER_QUESTION q where q.tag1 is not null and length(q.tag1) > 1
		group by q.tag1
		
	union all 
	
	select 
		q.tag2 as tag,
		sum(q.top_5) as top_5,
		sum(q.top_5_10) as top_5_10,
		sum(q.top_10_15) as top_10_15,
		sum(q.top_15_20) as top_15_20,
		sum(q.top_20_25) as top_20_25,
		sum(q.top_25_30) as top_25_30,
		sum(q.top_30_35) as top_30_35,
		sum(q.top_35_40) as top_35_40,
		sum(q.top_40_45) as top_40_45,
		sum(q.top_45_50) as top_45_50,
		sum(q.top_50_100) as top_50_100
	from TAG_PER_QUESTION q where q.tag2 is not null and length(q.tag2) > 1
		group by q.tag2
		
	union all 
	
	select 
		q.tag3 as tag,
		sum(q.top_5) as top_5,
		sum(q.top_5_10) as top_5_10,
		sum(q.top_10_15) as top_10_15,
		sum(q.top_15_20) as top_15_20,
		sum(q.top_20_25) as top_20_25,
		sum(q.top_25_30) as top_25_30,
		sum(q.top_30_35) as top_30_35,
		sum(q.top_35_40) as top_35_40,
		sum(q.top_40_45) as top_40_45,
		sum(q.top_45_50) as top_45_50,
		sum(q.top_50_100) as top_50_100
	from TAG_PER_QUESTION q where q.tag3 is not null and length(q.tag3) > 1
		group by q.tag3
)A group by A.tag


$_$;


ALTER FUNCTION public.tags_per_user_profile(community_name text) OWNER TO postgres;

--
-- Name: time_to_first_activity(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION time_to_first_activity(community_name text) RETURNS TABLE(id_user bigint, diff_secs double precision, diff_min double precision, diff interval, category text)
    LANGUAGE sql
    AS $_$

with FIRST_ACTIVITY as (
	select a.id_user, min(a.post_creation_date) as min_post_creation_date 
	from find_user_activities($1) a
	group by a.id_user
)
	
select u.id as id_user,
		(select extract(epoch from(p.min_post_creation_date - u.creation_date ))) as diff_secs,
		(select extract(epoch from(p.min_post_creation_date - u.creation_date ))) / 60 as diff_min,
	   (p.min_post_creation_date - u.creation_date ) as diff,
	   case
	   	when u.top_5 = 1 then 'top_5'
	   	when u.top_5_10 = 1 then 'top_5_10'
	   	when u.top_10_15 = 1 then 'top_10_15'
	   	when u.top_15_20 = 1 then 'top_15_20'
	   	when u.top_20_25 = 1 then 'top_20_25'
	   	when u.top_25_30 = 1 then 'top_25_30'
	   	when u.top_30_35 = 1 then 'top_30_35'
	   	when u.top_35_40 = 1 then 'top_35_40'
	   	when u.top_40_45 = 1 then 'top_40_45'
	   	when u.top_45_50 = 1 then 'top_45_50'
	   	when u.top_50_100 = 1 then 'top_50_100'
	   	when u.no_participation = 1 then 'no_participation'
	   end as category

	   
from comm_user_ranking_profile($1) u
inner join FIRST_ACTIVITY p on u.id = p.id_user

$_$;


ALTER FUNCTION public.time_to_first_activity(community_name text) OWNER TO postgres;

--
-- Name: user_entropy(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION user_entropy(community_name text) RETURNS TABLE(id_user bigint, entropy numeric)
    LANGUAGE sql
    AS $_$

with QUESTION_TAGS as (
	select
			id as id_question,
			tag1 ,
			tag2 ,
			tag3
		from post_tags($1)
), USER_BY_DISCUSSION as (
	select  id_question, id_user from comm_user_by_discussion($1)
),
LAYERS as (
	-- recupera as camadas de cada tag
	select * from tag_layer($1)
),
USER_TAGS as (
	-- liga tags aos usuarios
	select q.*, u.id_user from QUESTION_TAGS q
		inner join USER_BY_DISCUSSION u on q.id_question = u.id_question
	order by u.id_user
),
USER_TAGS_2 as  (
	-- reorganiza a conexao das tags por usuario e adiciona a camada de cada tag
	select A.tag, A.id_user, sum("count") as total_post_tag,
		(select l.layer from LAYERS l where l.tag = A.tag) as 	layer
	from (

		select u.tag1 as tag, u.id_user, count(*) from USER_TAGS u group by u.tag1, u.id_user
		union all
		select u.tag2 as tag, u.id_user, count(*) from USER_TAGS u group by u.tag2, u.id_user
		union all
		select u.tag3 as tag, u.id_user, count(*) from USER_TAGS u group by u.tag3, u.id_user

	)A where length(A.tag) > 0 group by A.tag, A.id_user
),
TOTAL_POST_LAYER as (
	select u.layer, u.id_user, sum(total_post_tag) as total_post_layer from USER_TAGS_2 u group by u.layer, u.id_user
)
select D.id_user, sum(D.partial_entropy) as entropy from (
	select C.id_user, C.layer, (-1* sum(C.partial_entropy)) as partial_entropy from (
		select B.*,
					(B.prob * B.prob_log) as partial_entropy
					from (

			select u.*, t.total_post_layer,
				   (u.total_post_tag/t.total_post_layer) as prob,
				  (ln((u.total_post_tag/t.total_post_layer))) as prob_log

			from USER_TAGS_2 u
			inner join TOTAL_POST_LAYER t on u.id_user = t.id_user and u.layer = t.layer
			order by u.id_user, u.layer
		)B
	)C  group by C.id_user, C.layer
)D group by D.id_user

$_$;


ALTER FUNCTION public.user_entropy(community_name text) OWNER TO postgres;

--
-- Name: when_user_was_created(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION when_user_was_created(community_name text) RETURNS TABLE(period integer, count bigint, category text, category_id integer)
    LANGUAGE sql
    AS $_$

with USERS as (
	select * from comm_user_ranking_profile($1) 
)
select * from (
	select u.period,
		   count(*),
		   'top_5' as category,
		   1 as category_id
	from USERS u where u.top_5 = 1
	group by u.period 

union all

	select u.period,
		   count(*),
		   'top_5_10' as category,
		   2 as category_id
	from USERS u where u.top_5_10 = 1
	group by u.period 
	
union all

	select u.period,
		   count(*),
		   'top_10_15' as category,
		   3 as category_id
	from USERS u where u.top_10_15 = 1
	group by u.period 

union all

	select u.period,
		   count(*),
		   'top_15_20' as category,
		   4 as category_id
	from USERS u where u.top_15_20 = 1
	group by u.period 

union all

	select u.period,
		   count(*),
		   'top_20_25' as category,
		   5 as category_id
	from USERS u where u.top_20_25 = 1
	group by u.period 
	
union all

	select u.period,
		   count(*),
		   'top_25_30' as category,
		   6 as category_id
	from USERS u where u.top_25_30 = 1
	group by u.period 

union all

	select u.period,
		   count(*),
		   'top_30_35' as category,
		   7 as category_id
	from USERS u where u.top_30_35 = 1
	group by u.period

union all

	select u.period,
		   count(*),
		   'top_35_40' as category,
		   8 as category_id
	from USERS u where u.top_35_40 = 1
	group by u.period

union all

	select u.period,
		   count(*),
		   'top_40_45' as category,
		   9 as category_id
	from USERS u where u.top_40_45 = 1
	group by u.period

union all

	select u.period,
		   count(*),
		   'top_45_50' as category,
		   10 as category_id
	from USERS u where u.top_45_50 = 1
	group by u.period

union all

	select u.period,
		   count(*),
		   'top_50_100' as category,
		   11 as category_id
	from USERS u where u.top_50_100 = 1
	group by u.period	

union all

	select u.period,
		   count(*),
		   'no_participation' as category,
		   12 as category_id
	from USERS u where u.no_participation = 1
	group by u.period	
	
	
)A order by A.category_id,  A.period

$_$;


ALTER FUNCTION public.when_user_was_created(community_name text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: badge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE badge (
    id bigint NOT NULL,
    class character varying(255),
    date timestamp without time zone,
    id_badge_comm bigint,
    id_user_community bigint,
    name character varying(255),
    tag_based character varying(255),
    id_community integer,
    id_user bigint
);


ALTER TABLE badge OWNER TO postgres;

--
-- Name: badge_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE badge_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE badge_seq OWNER TO postgres;

--
-- Name: graph_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE graph_node (
    id bigint NOT NULL,
    betweenness double precision,
    closeness double precision,
    clustering_coefficient double precision,
    degree integer,
    eccentricity double precision,
    eigenvector double precision,
    harmonic_closeness double precision,
    id_community integer,
    id_user bigint,
    indegree integer,
    interactions integer,
    modularity_class integer,
    outdegree integer,
    page_rank double precision,
    strongly_component integer,
    weakly_component integer,
    id_graph_analysis_context bigint
);


ALTER TABLE graph_node OWNER TO postgres;

--
-- Name: struct_analysis_context; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE struct_analysis_context (
    id bigint NOT NULL,
    id_graph_analysis_context bigint NOT NULL,
    description character varying(400)
);


ALTER TABLE struct_analysis_context OWNER TO postgres;

--
-- Name: struct_distance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE struct_distance (
    id bigint NOT NULL,
    node1 bigint NOT NULL,
    node2 bigint NOT NULL,
    distance_custom_dtw_0 double precision,
    id_struct_analysis_context bigint NOT NULL,
    distance_custom_dtw_1 double precision,
    distance_custom_dtw_2 double precision
);


ALTER TABLE struct_distance OWNER TO postgres;

--
-- Name: biology_struct_distance_custom_dtw_1; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW biology_struct_distance_custom_dtw_1 AS
 WITH nodes AS (
         SELECT n.id,
            row_number() OVER (ORDER BY n.id) AS alternative_id
           FROM graph_node n
          WHERE (n.id_graph_analysis_context IN ( SELECT last_graph_analysis_context.id
                   FROM last_graph_analysis_context('biology.stackexchange.com'::text) last_graph_analysis_context(id, avg_clustering_coef, avg_degree, avg_dist, density, diameter, edges, id_community, modularity, modularity_with_resolution, nodes, number_communities, period, radius, strongly_component_count, weakly_component_count)))
        )
 SELECT s.id,
    s.node1,
    s.node2,
    s.id_struct_analysis_context,
    s.distance_custom_dtw_1,
    n1.degree AS node1_degree,
    n2.degree AS node2_degree,
    n11.alternative_id AS node1_alternative_id,
    n22.alternative_id AS node2_alternative_id
   FROM ((((struct_distance s
     JOIN graph_node n1 ON ((n1.id = s.node1)))
     JOIN graph_node n2 ON ((n2.id = s.node2)))
     JOIN nodes n11 ON ((n11.id = s.node1)))
     JOIN nodes n22 ON ((n22.id = s.node2)))
  WHERE (s.id_struct_analysis_context IN ( SELECT sac.id
           FROM struct_analysis_context sac
          WHERE (sac.id_graph_analysis_context IN ( SELECT last_graph_analysis_context.id
                   FROM last_graph_analysis_context('biology.stackexchange.com'::text) last_graph_analysis_context(id, avg_clustering_coef, avg_degree, avg_dist, density, diameter, edges, id_community, modularity, modularity_with_resolution, nodes, number_communities, period, radius, strongly_component_count, weakly_component_count)))))
  WITH NO DATA;


ALTER TABLE biology_struct_distance_custom_dtw_1 OWNER TO postgres;

--
-- Name: count_citation_by_unique_display_name_biology; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_citation_by_unique_display_name_biology AS
 SELECT count_citation_by_unique_display_name.display_name,
    count_citation_by_unique_display_name.count,
    count_citation_by_unique_display_name.id_user
   FROM count_citation_by_unique_display_name('biology.stackexchange.com'::text) count_citation_by_unique_display_name(display_name, count, id_user)
  WITH NO DATA;


ALTER TABLE count_citation_by_unique_display_name_biology OWNER TO postgres;

--
-- Name: citation_by_display_name_and_category_biology; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW citation_by_display_name_and_category_biology AS
 WITH profile AS (
         SELECT comm_user_ranking_profile.id,
            comm_user_ranking_profile.about_me,
            comm_user_ranking_profile.age,
            comm_user_ranking_profile.creation_date,
            comm_user_ranking_profile.display_name,
            comm_user_ranking_profile.down_votes,
            comm_user_ranking_profile.id_user_comm,
            comm_user_ranking_profile.last_access_date,
            comm_user_ranking_profile.location,
            comm_user_ranking_profile.period,
            comm_user_ranking_profile.reputation,
            comm_user_ranking_profile.up_votes,
            comm_user_ranking_profile.views,
            comm_user_ranking_profile.website_url,
            comm_user_ranking_profile.id_community,
            comm_user_ranking_profile.answers,
            comm_user_ranking_profile.questions,
            comm_user_ranking_profile.comments,
            comm_user_ranking_profile.reviews,
            comm_user_ranking_profile.accepted_answers,
            comm_user_ranking_profile.votes_favorite_given,
            comm_user_ranking_profile.votes_bounty_start_given,
            comm_user_ranking_profile.total_participation,
            comm_user_ranking_profile.total_participation_with_votes,
            comm_user_ranking_profile.top_5,
            comm_user_ranking_profile.top_10,
            comm_user_ranking_profile.top_15,
            comm_user_ranking_profile.top_20,
            comm_user_ranking_profile.top_25,
            comm_user_ranking_profile.top_30,
            comm_user_ranking_profile.top_35,
            comm_user_ranking_profile.top_40,
            comm_user_ranking_profile.top_45,
            comm_user_ranking_profile.top_50,
            comm_user_ranking_profile.top_5_10,
            comm_user_ranking_profile.top_10_15,
            comm_user_ranking_profile.top_15_20,
            comm_user_ranking_profile.top_20_25,
            comm_user_ranking_profile.top_25_30,
            comm_user_ranking_profile.top_30_35,
            comm_user_ranking_profile.top_35_40,
            comm_user_ranking_profile.top_40_45,
            comm_user_ranking_profile.top_45_50,
            comm_user_ranking_profile.top_50_100,
            comm_user_ranking_profile.no_participation
           FROM comm_user_ranking_profile('biology.stackexchange.com'::text) comm_user_ranking_profile(id, about_me, age, creation_date, display_name, down_votes, id_user_comm, last_access_date, location, period, reputation, up_votes, views, website_url, id_community, answers, questions, comments, reviews, accepted_answers, votes_favorite_given, votes_bounty_start_given, total_participation, total_participation_with_votes, top_5, top_10, top_15, top_20, top_25, top_30, top_35, top_40, top_45, top_50, top_5_10, top_10_15, top_15_20, top_20_25, top_25_30, top_30_35, top_35_40, top_40_45, top_45_50, top_50_100, no_participation)
        )
 SELECT c.display_name,
    c.count,
    c.id_user,
        CASE
            WHEN (p.top_5 = 1) THEN 'top_5'::text
            WHEN (p.top_5_10 = 1) THEN 'top_5_10'::text
            WHEN (p.top_10_15 = 1) THEN 'top_10_15'::text
            WHEN (p.top_15_20 = 1) THEN 'top_15_20'::text
            WHEN (p.top_20_25 = 1) THEN 'top_20_25'::text
            WHEN (p.top_25_30 = 1) THEN 'top_25_30'::text
            WHEN (p.top_30_35 = 1) THEN 'top_30_35'::text
            WHEN (p.top_35_40 = 1) THEN 'top_35_40'::text
            WHEN (p.top_40_45 = 1) THEN 'top_40_45'::text
            WHEN (p.top_45_50 = 1) THEN 'top_45_50'::text
            WHEN (p.top_50_100 = 1) THEN 'top_50_100'::text
            WHEN (p.no_participation = 1) THEN 'no_participation'::text
            ELSE NULL::text
        END AS category
   FROM (count_citation_by_unique_display_name_biology c
     JOIN profile p ON (((p.display_name)::text = c.display_name)))
  ORDER BY c.count DESC;


ALTER TABLE citation_by_display_name_and_category_biology OWNER TO postgres;

--
-- Name: count_citation_by_unique_display_name_chemistry; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_citation_by_unique_display_name_chemistry AS
 SELECT count_citation_by_unique_display_name.display_name,
    count_citation_by_unique_display_name.count,
    count_citation_by_unique_display_name.id_user
   FROM count_citation_by_unique_display_name('chemistry.stackexchange.com'::text) count_citation_by_unique_display_name(display_name, count, id_user)
  WITH NO DATA;


ALTER TABLE count_citation_by_unique_display_name_chemistry OWNER TO postgres;

--
-- Name: citation_by_display_name_and_category_chemistry; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW citation_by_display_name_and_category_chemistry AS
 WITH profile AS (
         SELECT comm_user_ranking_profile.id,
            comm_user_ranking_profile.about_me,
            comm_user_ranking_profile.age,
            comm_user_ranking_profile.creation_date,
            comm_user_ranking_profile.display_name,
            comm_user_ranking_profile.down_votes,
            comm_user_ranking_profile.id_user_comm,
            comm_user_ranking_profile.last_access_date,
            comm_user_ranking_profile.location,
            comm_user_ranking_profile.period,
            comm_user_ranking_profile.reputation,
            comm_user_ranking_profile.up_votes,
            comm_user_ranking_profile.views,
            comm_user_ranking_profile.website_url,
            comm_user_ranking_profile.id_community,
            comm_user_ranking_profile.answers,
            comm_user_ranking_profile.questions,
            comm_user_ranking_profile.comments,
            comm_user_ranking_profile.reviews,
            comm_user_ranking_profile.accepted_answers,
            comm_user_ranking_profile.votes_favorite_given,
            comm_user_ranking_profile.votes_bounty_start_given,
            comm_user_ranking_profile.total_participation,
            comm_user_ranking_profile.total_participation_with_votes,
            comm_user_ranking_profile.top_5,
            comm_user_ranking_profile.top_10,
            comm_user_ranking_profile.top_15,
            comm_user_ranking_profile.top_20,
            comm_user_ranking_profile.top_25,
            comm_user_ranking_profile.top_30,
            comm_user_ranking_profile.top_35,
            comm_user_ranking_profile.top_40,
            comm_user_ranking_profile.top_45,
            comm_user_ranking_profile.top_50,
            comm_user_ranking_profile.top_5_10,
            comm_user_ranking_profile.top_10_15,
            comm_user_ranking_profile.top_15_20,
            comm_user_ranking_profile.top_20_25,
            comm_user_ranking_profile.top_25_30,
            comm_user_ranking_profile.top_30_35,
            comm_user_ranking_profile.top_35_40,
            comm_user_ranking_profile.top_40_45,
            comm_user_ranking_profile.top_45_50,
            comm_user_ranking_profile.top_50_100,
            comm_user_ranking_profile.no_participation
           FROM comm_user_ranking_profile('chemistry.stackexchange.com'::text) comm_user_ranking_profile(id, about_me, age, creation_date, display_name, down_votes, id_user_comm, last_access_date, location, period, reputation, up_votes, views, website_url, id_community, answers, questions, comments, reviews, accepted_answers, votes_favorite_given, votes_bounty_start_given, total_participation, total_participation_with_votes, top_5, top_10, top_15, top_20, top_25, top_30, top_35, top_40, top_45, top_50, top_5_10, top_10_15, top_15_20, top_20_25, top_25_30, top_30_35, top_35_40, top_40_45, top_45_50, top_50_100, no_participation)
        )
 SELECT c.display_name,
    c.count,
    c.id_user,
        CASE
            WHEN (p.top_5 = 1) THEN 'top_5'::text
            WHEN (p.top_5_10 = 1) THEN 'top_5_10'::text
            WHEN (p.top_10_15 = 1) THEN 'top_10_15'::text
            WHEN (p.top_15_20 = 1) THEN 'top_15_20'::text
            WHEN (p.top_20_25 = 1) THEN 'top_20_25'::text
            WHEN (p.top_25_30 = 1) THEN 'top_25_30'::text
            WHEN (p.top_30_35 = 1) THEN 'top_30_35'::text
            WHEN (p.top_35_40 = 1) THEN 'top_35_40'::text
            WHEN (p.top_40_45 = 1) THEN 'top_40_45'::text
            WHEN (p.top_45_50 = 1) THEN 'top_45_50'::text
            WHEN (p.top_50_100 = 1) THEN 'top_50_100'::text
            WHEN (p.no_participation = 1) THEN 'no_participation'::text
            ELSE NULL::text
        END AS category
   FROM (count_citation_by_unique_display_name_chemistry c
     JOIN profile p ON (((p.display_name)::text = c.display_name)))
  ORDER BY c.count DESC;


ALTER TABLE citation_by_display_name_and_category_chemistry OWNER TO postgres;

--
-- Name: comm_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comm_user (
    id bigint NOT NULL,
    about_me text,
    age integer,
    creation_date timestamp without time zone NOT NULL,
    display_name character varying(255) NOT NULL,
    down_votes integer NOT NULL,
    id_user_comm bigint NOT NULL,
    last_access_date timestamp without time zone NOT NULL,
    location character varying(255),
    period integer,
    reputation integer NOT NULL,
    up_votes integer NOT NULL,
    views integer NOT NULL,
    website_url character varying(255),
    id_community integer NOT NULL
);


ALTER TABLE comm_user OWNER TO postgres;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE comment (
    id bigint NOT NULL,
    ari double precision,
    characters double precision,
    coleman_liau double precision,
    complexwords double precision,
    creation_date timestamp without time zone,
    flesch_kincaid double precision,
    flesch_reading double precision,
    gunning_fog double precision,
    id_comment_comm bigint,
    id_post_comm bigint,
    id_user_comm bigint,
    period integer,
    score integer,
    sentences double precision,
    smog double precision,
    smog_index double precision,
    syllables double precision,
    text text,
    words double precision,
    id_community integer,
    id_post bigint,
    id_user bigint
);


ALTER TABLE comment OWNER TO postgres;

--
-- Name: comment_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE comment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE comment_seq OWNER TO postgres;

--
-- Name: community; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE community (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE community OWNER TO postgres;

--
-- Name: community_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE community_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE community_seq OWNER TO postgres;

--
-- Name: count_i_usage_with_profile_biology_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_i_usage_with_profile_biology_view AS
 SELECT count_i_usage_with_profile.id_user,
    count_i_usage_with_profile.count_i_usage,
    count_i_usage_with_profile.category
   FROM count_i_usage_with_profile('biology.stackexchange.com'::text) count_i_usage_with_profile(id_user, count_i_usage, category)
  WITH NO DATA;


ALTER TABLE count_i_usage_with_profile_biology_view OWNER TO postgres;

--
-- Name: count_i_usage_with_profile_chemistry_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_i_usage_with_profile_chemistry_view AS
 SELECT count_i_usage_with_profile.id_user,
    count_i_usage_with_profile.count_i_usage,
    count_i_usage_with_profile.category
   FROM count_i_usage_with_profile('chemistry.stackexchange.com'::text) count_i_usage_with_profile(id_user, count_i_usage, category)
  WITH NO DATA;


ALTER TABLE count_i_usage_with_profile_chemistry_view OWNER TO postgres;

--
-- Name: count_she_he_usage_with_profile_biology_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_she_he_usage_with_profile_biology_view AS
 SELECT count_she_he_usage_with_profile.id_user,
    count_she_he_usage_with_profile.count_she_he_usage,
    count_she_he_usage_with_profile.category
   FROM count_she_he_usage_with_profile('biology.stackexchange.com'::text) count_she_he_usage_with_profile(id_user, count_she_he_usage, category)
  WITH NO DATA;


ALTER TABLE count_she_he_usage_with_profile_biology_view OWNER TO postgres;

--
-- Name: count_she_he_usage_with_profile_chemistry_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_she_he_usage_with_profile_chemistry_view AS
 SELECT count_she_he_usage_with_profile.id_user,
    count_she_he_usage_with_profile.count_she_he_usage,
    count_she_he_usage_with_profile.category
   FROM count_she_he_usage_with_profile('chemistry.stackexchange.com'::text) count_she_he_usage_with_profile(id_user, count_she_he_usage, category)
  WITH NO DATA;


ALTER TABLE count_she_he_usage_with_profile_chemistry_view OWNER TO postgres;

--
-- Name: count_they_usage_with_profile_biology_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_they_usage_with_profile_biology_view AS
 SELECT count_they_usage_with_profile.id_user,
    count_they_usage_with_profile.count_they_usage,
    count_they_usage_with_profile.category
   FROM count_they_usage_with_profile('biology.stackexchange.com'::text) count_they_usage_with_profile(id_user, count_they_usage, category)
  WITH NO DATA;


ALTER TABLE count_they_usage_with_profile_biology_view OWNER TO postgres;

--
-- Name: count_they_usage_with_profile_chemistry_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_they_usage_with_profile_chemistry_view AS
 SELECT count_they_usage_with_profile.id_user,
    count_they_usage_with_profile.count_they_usage,
    count_they_usage_with_profile.category
   FROM count_they_usage_with_profile('chemistry.stackexchange.com'::text) count_they_usage_with_profile(id_user, count_they_usage, category)
  WITH NO DATA;


ALTER TABLE count_they_usage_with_profile_chemistry_view OWNER TO postgres;

--
-- Name: count_we_usage_with_profile_biology_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_we_usage_with_profile_biology_view AS
 SELECT count_we_usage_with_profile.id_user,
    count_we_usage_with_profile.count_we_usage,
    count_we_usage_with_profile.category
   FROM count_we_usage_with_profile('biology.stackexchange.com'::text) count_we_usage_with_profile(id_user, count_we_usage, category)
  WITH NO DATA;


ALTER TABLE count_we_usage_with_profile_biology_view OWNER TO postgres;

--
-- Name: count_we_usage_with_profile_chemistry_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_we_usage_with_profile_chemistry_view AS
 SELECT count_we_usage_with_profile.id_user,
    count_we_usage_with_profile.count_we_usage,
    count_we_usage_with_profile.category
   FROM count_we_usage_with_profile('chemistry.stackexchange.com'::text) count_we_usage_with_profile(id_user, count_we_usage, category)
  WITH NO DATA;


ALTER TABLE count_we_usage_with_profile_chemistry_view OWNER TO postgres;

--
-- Name: count_you_usage_with_profile_biology_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_you_usage_with_profile_biology_view AS
 SELECT count_you_usage_with_profile.id_user,
    count_you_usage_with_profile.count_you_usage,
    count_you_usage_with_profile.category
   FROM count_you_usage_with_profile('biology.stackexchange.com'::text) count_you_usage_with_profile(id_user, count_you_usage, category)
  WITH NO DATA;


ALTER TABLE count_you_usage_with_profile_biology_view OWNER TO postgres;

--
-- Name: count_you_usage_with_profile_chemistry_view; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW count_you_usage_with_profile_chemistry_view AS
 SELECT count_you_usage_with_profile.id_user,
    count_you_usage_with_profile.count_you_usage,
    count_you_usage_with_profile.category
   FROM count_you_usage_with_profile('chemistry.stackexchange.com'::text) count_you_usage_with_profile(id_user, count_you_usage, category)
  WITH NO DATA;


ALTER TABLE count_you_usage_with_profile_chemistry_view OWNER TO postgres;

--
-- Name: graph_analysis_context; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE graph_analysis_context (
    id bigint NOT NULL,
    avg_clustering_coef double precision,
    avg_degree double precision,
    avg_dist double precision,
    density double precision,
    diameter double precision,
    edges integer,
    id_community integer,
    modularity double precision,
    modularity_with_resolution double precision,
    nodes integer,
    number_communities integer,
    period integer,
    radius double precision,
    strongly_component_count integer,
    weakly_component_count integer
);


ALTER TABLE graph_analysis_context OWNER TO postgres;

--
-- Name: graph_ctx_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE graph_ctx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE graph_ctx_seq OWNER TO postgres;

--
-- Name: graph_edge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE graph_edge (
    id bigint NOT NULL,
    id_community integer,
    id_user_dest bigint,
    id_user_source bigint,
    weight integer,
    id_graph_analysis_context bigint,
    id_graph_node_dest bigint,
    id_graph_node_source bigint
);


ALTER TABLE graph_edge OWNER TO postgres;

--
-- Name: graph_edge_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE graph_edge_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE graph_edge_seq OWNER TO postgres;

--
-- Name: graph_node_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE graph_node_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE graph_node_seq OWNER TO postgres;

--
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE post (
    id bigint NOT NULL,
    accepted_answer_comm_id bigint,
    answer_count integer,
    ari_text double precision,
    ari_title double precision,
    body text,
    characters_text double precision,
    characters_title double precision,
    closed_date timestamp without time zone,
    coleman_liau_text double precision,
    coleman_liau_title double precision,
    comment_count integer,
    community_owned_date timestamp without time zone,
    complexwords_text double precision,
    complexwords_title double precision,
    creation_date timestamp without time zone,
    favorite_count integer,
    flesch_kincaid_text double precision,
    flesch_kincaid_title double precision,
    flesch_reading_text double precision,
    flesch_reading_title double precision,
    gunning_fog_text double precision,
    gunning_fog_title double precision,
    id_post_comm bigint,
    id_user_community bigint,
    last_activity_date timestamp without time zone,
    last_edit_date timestamp without time zone,
    last_editor_display_name character varying(255),
    last_editor_user_community_id bigint,
    parent_post_comm_id bigint,
    period integer,
    post_type integer,
    score integer,
    sentences_text double precision,
    sentences_title double precision,
    smog_index_text double precision,
    smog_index_title double precision,
    smog_text double precision,
    smog_title double precision,
    syllables_text double precision,
    syllables_title double precision,
    tags character varying(255),
    title character varying(255),
    view_count integer,
    words_text double precision,
    words_title double precision,
    id_community integer,
    id_user bigint
);


ALTER TABLE post OWNER TO postgres;

--
-- Name: post_hist_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_hist_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_hist_seq OWNER TO postgres;

--
-- Name: post_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE post_history (
    id bigint NOT NULL,
    close_reason integer,
    user_comment text,
    creation_date timestamp without time zone,
    id_post_comm bigint,
    id_post_hist_comm bigint,
    id_user_community bigint,
    revision_guid character varying(255),
    text text,
    post_history_type integer,
    user_display_name character varying(255),
    id_community integer,
    id_post bigint,
    id_user bigint,
    period integer
);


ALTER TABLE post_history OWNER TO postgres;

--
-- Name: post_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE post_link (
    id bigint NOT NULL,
    creation_date timestamp without time zone,
    id_post_comm bigint,
    id_post_link_comm bigint,
    id_related_post_comm bigint,
    period integer,
    post_link_type integer,
    id_community integer,
    id_post bigint,
    id_related_post bigint
);


ALTER TABLE post_link OWNER TO postgres;

--
-- Name: post_link_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_link_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_link_seq OWNER TO postgres;

--
-- Name: post_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE post_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_seq OWNER TO postgres;

--
-- Name: struct_analysis_context_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE struct_analysis_context_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE struct_analysis_context_seq OWNER TO postgres;

--
-- Name: struct_distance_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE struct_distance_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE struct_distance_seq OWNER TO postgres;

--
-- Name: user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_seq OWNER TO postgres;

--
-- Name: vote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE vote (
    id bigint NOT NULL,
    bounty_amount integer,
    creation_date timestamp without time zone,
    id_post_comm bigint,
    id_user_comm bigint,
    id_vote_comm bigint,
    period integer,
    vote_type integer,
    id_community integer,
    id_post bigint,
    id_user bigint
);


ALTER TABLE vote OWNER TO postgres;

--
-- Name: vote_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vote_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vote_seq OWNER TO postgres;

--
-- Name: badge_id_badge_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY badge
    ADD CONSTRAINT badge_id_badge_comm_id_community UNIQUE (id_badge_comm, id_community);


--
-- Name: badge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY badge
    ADD CONSTRAINT badge_pkey PRIMARY KEY (id);


--
-- Name: comm_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comm_user
    ADD CONSTRAINT comm_user_pkey PRIMARY KEY (id);


--
-- Name: comment_id_comment_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_id_comment_comm_id_community UNIQUE (id_comment_comm, id_community);


--
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: community_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY community
    ADD CONSTRAINT community_pkey PRIMARY KEY (id);


--
-- Name: graph_analysis_context_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_analysis_context
    ADD CONSTRAINT graph_analysis_context_pkey PRIMARY KEY (id);


--
-- Name: graph_edge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_edge
    ADD CONSTRAINT graph_edge_pkey PRIMARY KEY (id);


--
-- Name: graph_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_node
    ADD CONSTRAINT graph_node_pkey PRIMARY KEY (id);


--
-- Name: post_hist_id_post_hist_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_history
    ADD CONSTRAINT post_hist_id_post_hist_comm_id_community UNIQUE (id_post_hist_comm, id_community);


--
-- Name: post_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_history
    ADD CONSTRAINT post_history_pkey PRIMARY KEY (id);


--
-- Name: post_id_post_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_id_post_comm_id_community UNIQUE (id_post_comm, id_community);


--
-- Name: post_link_id_post_link_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_link
    ADD CONSTRAINT post_link_id_post_link_comm_id_community UNIQUE (id_post_link_comm, id_community);


--
-- Name: post_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_link
    ADD CONSTRAINT post_link_pkey PRIMARY KEY (id);


--
-- Name: post_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- Name: struct_analysis_context_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY struct_analysis_context
    ADD CONSTRAINT struct_analysis_context_pk PRIMARY KEY (id);


--
-- Name: struct_distance_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY struct_distance
    ADD CONSTRAINT struct_distance_pk PRIMARY KEY (id);


--
-- Name: uk5c8obwpi8162i1066v8pg02i9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_edge
    ADD CONSTRAINT uk5c8obwpi8162i1066v8pg02i9 UNIQUE (id_user_source, id_user_dest, id_graph_analysis_context);


--
-- Name: uk74vha5rnttceyl4jgsxhmfgxq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_node
    ADD CONSTRAINT uk74vha5rnttceyl4jgsxhmfgxq UNIQUE (id_graph_analysis_context, id_user);


--
-- Name: uk_ggi0mfnbrejia9lxku7voffc9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY community
    ADD CONSTRAINT uk_ggi0mfnbrejia9lxku7voffc9 UNIQUE (name);


--
-- Name: ukmvue0xspxtfapwqghjc3eyn33; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_analysis_context
    ADD CONSTRAINT ukmvue0xspxtfapwqghjc3eyn33 UNIQUE (period, id_community);


--
-- Name: user_id_user_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comm_user
    ADD CONSTRAINT user_id_user_comm_id_community UNIQUE (id_user_comm, id_community);


--
-- Name: vote_id_vote_comm_id_community; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_id_vote_comm_id_community UNIQUE (id_vote_comm, id_community);


--
-- Name: vote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT vote_pkey PRIMARY KEY (id);


--
-- Name: fk1ynwldc4qwuvikdk214ami6yt; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT fk1ynwldc4qwuvikdk214ami6yt FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fk2cwssrbwmfbfvvm3n4kg7sbti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_history
    ADD CONSTRAINT fk2cwssrbwmfbfvvm3n4kg7sbti FOREIGN KEY (id_user) REFERENCES comm_user(id);


--
-- Name: fk4gei6jhc6daokg04pxs16y2cw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk4gei6jhc6daokg04pxs16y2cw FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fk572dhkbcvlctsjmla95fl59sb; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_link
    ADD CONSTRAINT fk572dhkbcvlctsjmla95fl59sb FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fk5d3jnie61rlb5an9r4hm9wq9n; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fk5d3jnie61rlb5an9r4hm9wq9n FOREIGN KEY (id_post) REFERENCES post(id);


--
-- Name: fk6mfbj6xa4oosyngan8n519im1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_edge
    ADD CONSTRAINT fk6mfbj6xa4oosyngan8n519im1 FOREIGN KEY (id_graph_node_source) REFERENCES graph_node(id);


--
-- Name: fk81pmjn854enfrvs4ja62e9bcf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fk81pmjn854enfrvs4ja62e9bcf FOREIGN KEY (id_user) REFERENCES comm_user(id);


--
-- Name: fk8mju2m4cod64oxxjdi02cl45d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_history
    ADD CONSTRAINT fk8mju2m4cod64oxxjdi02cl45d FOREIGN KEY (id_post) REFERENCES post(id);


--
-- Name: fk90vvp0nlciawyqdcqufourfiq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT fk90vvp0nlciawyqdcqufourfiq FOREIGN KEY (id_user) REFERENCES comm_user(id);


--
-- Name: fka7uddx0qibi3pl8uaxp06h31b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY badge
    ADD CONSTRAINT fka7uddx0qibi3pl8uaxp06h31b FOREIGN KEY (id_user) REFERENCES comm_user(id);


--
-- Name: fkay7ff7ml1icycosnmk1b81xvm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY badge
    ADD CONSTRAINT fkay7ff7ml1icycosnmk1b81xvm FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fkbp1m1gkcnbmtt2p4ypv7hbq4p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_history
    ADD CONSTRAINT fkbp1m1gkcnbmtt2p4ypv7hbq4p FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fkij72nl5qu52mjrboiouj3uc6h; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_link
    ADD CONSTRAINT fkij72nl5qu52mjrboiouj3uc6h FOREIGN KEY (id_related_post) REFERENCES post(id);


--
-- Name: fkjgknpdw1frggb7jejbfyttymq; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fkjgknpdw1frggb7jejbfyttymq FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fkkbk9evvt57bn5mtben4qjgd80; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comm_user
    ADD CONSTRAINT fkkbk9evvt57bn5mtben4qjgd80 FOREIGN KEY (id_community) REFERENCES community(id);


--
-- Name: fkmlwfag9stcbxg3qd2c27d7dnk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY post_link
    ADD CONSTRAINT fkmlwfag9stcbxg3qd2c27d7dnk FOREIGN KEY (id_post) REFERENCES post(id);


--
-- Name: fknmypjtbw6v7vlwcpew0530p8r; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT fknmypjtbw6v7vlwcpew0530p8r FOREIGN KEY (id_user) REFERENCES comm_user(id);


--
-- Name: fkoxao4yaxwwh1rqpbsr5rcphmk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_node
    ADD CONSTRAINT fkoxao4yaxwwh1rqpbsr5rcphmk FOREIGN KEY (id_graph_analysis_context) REFERENCES graph_analysis_context(id);


--
-- Name: fkqmms2vvgpf936ibt9mknlym7; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_edge
    ADD CONSTRAINT fkqmms2vvgpf936ibt9mknlym7 FOREIGN KEY (id_graph_analysis_context) REFERENCES graph_analysis_context(id);


--
-- Name: fks415guxyqybw75xfeiih6grhr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graph_edge
    ADD CONSTRAINT fks415guxyqybw75xfeiih6grhr FOREIGN KEY (id_graph_node_dest) REFERENCES graph_node(id);


--
-- Name: fkthbwp960a5muw8d5ib4ofkgl0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vote
    ADD CONSTRAINT fkthbwp960a5muw8d5ib4ofkgl0 FOREIGN KEY (id_post) REFERENCES post(id);


--
-- Name: struct_analysis_context_graph_analysis_context_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY struct_analysis_context
    ADD CONSTRAINT struct_analysis_context_graph_analysis_context_fk FOREIGN KEY (id_graph_analysis_context) REFERENCES graph_analysis_context(id);


--
-- Name: struct_distance_struct_analysis_context_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY struct_distance
    ADD CONSTRAINT struct_distance_struct_analysis_context_fk FOREIGN KEY (id_struct_analysis_context) REFERENCES struct_analysis_context(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

