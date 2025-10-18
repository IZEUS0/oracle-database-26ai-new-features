/* ===============================================================
 Reviewer: Ollear Mena
   Company: ELITEDATA S.L. 
   Script:      Exploring_JSON_Relational_Duality_Views.sql  
   Lab Title:   Exploring JSON-Relational Duality Views in Oracle Database 26ai  
   Description: Demonstrates how to create, query, and manage JSON Relational 
                Duality Views, enabling unified access to data in both 
                relational and JSON document formats.  
                Includes table creation, data insertion, duality view 
                definition, and query examples with error handling.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */

select sysdate;

create table attendee(
aid      number,
aname    varchar2(128),
extras   JSON (object),
constraint attendee primary key (aid)
);

create table speaker(
sid    number,
name   varchar2(128),
email  varchar2(64),
rating number,
constraint pk_speaker primary key (sid)
);

create table sessions(
sid number,
name varchar2(128),
room varchar2(128),
speakerId number,
constraint pk_session primary key (sid),
constraint fk_session foreign key (speakerId) references speaker(sid)
);

create table schedule (
schedule_id number,
session_id  number,
attendee_id number,
constraint pk_schedule primary key (schedule_id),
constraint fk_schedule_attendee foreign key (attendee_id) references attendee(aid),
constraint fk_schedule_session foreign key (session_id) references sessions(sid)
);

-- insert data
insert into attendee(aid, aname) values(1, 'Shashank');
insert into attendee(aid, aname) values(2, 'Doug');

insert into speaker values(1, 'Bodo', 'beda@university.edu', 7);
insert into speaker values(2, 'Tirthankar','mr.t@univerity.edu', 10);

insert into sessions values (1, 'JSON and SQL', 'Room 1', 1);
insert into sessions values (2, 'PL/SQL or Javascript', 'Room 2', 1);
insert into sessions values (3, 'Oracle on IPhone', 'Room 1', 2);

insert into schedule values (1,1,1);
insert into schedule values (2,2,1);
insert into schedule values (3,2,2);
insert into schedule values (4,3,1);
commit;

--Create your JSON Relational Duality View
create or replace JSON Duality view attendeeV as 
attendee @update @insert @delete{
_id   : aid,
name  : aname,
extras @flex 
};


create or replace JSON Duality view speakerV as 
speaker  @update @insert @delete {
_id       : sid,
name      : name,
rating    : rating @noupdate
};

create or replace JSON Duality view ScheduleV AS
attendee 
{
_id      : aid
name       : aname
schedule   : schedule  @insert @update @delete
{
    scheduleId : schedule_id
    sessions @unnest
    {
    sessionId : sid
    name      : name
    location  : room
    speaker @unnest
    {
        speakerId : sid
        speaker   : name
    }
    } 
}
} ;

--Work with your JSON Relational Duality Views
select * from attendee;
select * from attendeeV;

insert into attendeeV values ('{"_id":3, "name":"Hermann"}');
commit;

select * from attendee;

select data from scheduleV;

-- extract some fields from the JSON
select v.data.name, v.data.schedule[*].speaker
from scheduleV v;

select data
from speakerV v
where v.data."_id" = 1;

update speakerV v
set data = '{"_id":1,"name":"Beda","rating":7}'
where v.data."_id" = 1;

commit;

select data
from speakerV v
where v.data."_id" = 1;

select v.data.name, v.data.schedule[*].speaker
from scheduleV v;

update speakerV v
set data = '{"_id":1,"name":"Beda","rating":11}'
where v.data."_id" = 1;

update attendeeV v
set v.data = '{"_id":3, "name":"Hermann", "lastName":"B"}'
where v.data."_id" = 3;

select v.data
from attendeeV v
where v.data."_id" = 3;

select * from attendee;

create or replace JSON Duality view speakerV as 
speaker @update @insert @delete {
_id         : sid,
name        : name,
rating      : rating @noupdate,
sessions    : sessions {
    sessionId   : sid,
    sessionName : name
},
numSessions @generated (path : "$.sessions.size()")
};

select json_serialize(data pretty) from speakerV;

--Optimistic locking with Duality Views
select json_serialize(data pretty) 
from attendeeV v
where v.data."_id" = 2;

update ATTENDEE
set aname = 'Douglas'
where aid = 2;

update attendeeV v
set data = '{
        "_id" : 2,
        "_metadata" :
        {
            "etag" : "2B377C5A9C42B219CBD9A557C5F53847",
            "asof" : "000000004B1CC2FC"
        },
        "name" : "Doug",
        "job" : "Product Manager"
        }'
where v.data."_id" = 2;

--Clean up
DROP TABLE schedule purge;
DROP TABLE sessions purge;
DROP TABLE speaker purge;
DROP TABLE attendee purge;

DROP VIEW attendeev;
DROP VIEW speakerv;
DROP VIEW schedulev;
DROP VIEW speakerv;


