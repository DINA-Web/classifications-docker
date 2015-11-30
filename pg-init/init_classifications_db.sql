-- Create application specific user (w password) and database
-- these settings need to match the settings.py file for the app

create role taxonomy with superuser password 'taxonomy' login;
create database taxonomy with owner taxonomy encoding = 'UTF8';
