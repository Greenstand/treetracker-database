import petl as etl
import psycopg2 as db
from decouple import config
from faker import Faker

#ETL Script for 'public.planter' table. 

#Extract
#Define database connection paraemters for original database
ODBNAME = config('ORIGINAL_DBNAME')
ODBUSER = config('ORIGINAL_DBUSER')
ODBPASSWORD = config('ORIGINAL_DBPASSWORD')
ODBHOST = config('ORIGINAL_DBHOST')
ODBPORT = config('ORIGINAL_DBPORT')

oConnection = db.connect(database=ODBNAME, user=ODBUSER, password=ODBPASSWORD, 
host = ODBHOST, port = ODBPORT)

#Since we use target entity table to fill fields in planter table, need target DB. 
#Define database connection paraemters for target database
TDBNAME = config('TARGET_DBNAME')
TDBUSER = config('TARGET_DBUSER')
TDBPASSWORD = config('TARGET_DBPASSWORD')
TDBHOST = config('TARGET_DBHOST')
TDBPORT = config('TARGET_DBPORT')

tConnection = db.connect(database=TDBNAME, user=TDBUSER, password=TDBPASSWORD, 
host = TDBHOST, port = TDBPORT)

table = etl.fromdb(oConnection, """SELECT * FROM public.planter 
WHERE person_id is not NULL OR organization_id is not NULL""")

entityTable = etl.fromdb(tConnection, 'SELECT * FROM public.entity')

#Transform

#Select fields from entityTable
entityTable = etl.cut(entityTable, 'id', 'name', 'first_name', 'last_name', 'email', 'phone')

#Rename fields in entityTable
entityTable = etl.rename(entityTable, {
    'first_name': 'f_name', 
    'last_name': 'l_name', 
    'email': 'email_address', 
    'phone': 'phone_number'})

#Create instance of faker class
fake = Faker(['en_US', 'en_GB']) #Locales: United States/Great Britain
Faker.seed(1234)

#Left join planterTable with entityTable on organization_id
joinTable = etl.leftjoin(table, entityTable, lkey='organization_id', rkey='id')

#Split table based on whether name field is null or not. 
joinTableNull = etl.select(joinTable, 'name', lambda row: row == None)
joinTableNotNull = etl.select(joinTable, 'name', lambda row: row != None)

#Convert values in 'organization' field based on values in 'name' field. 
joinTableNull = etl.convert(joinTableNull, 'organization', lambda org, row: row.name, pass_row=True)
joinTableNotNull = etl.convert(joinTableNotNull, 'organization', lambda org, row: row.name, pass_row=True)

#Combine tables. 
joinTable = etl.cat(joinTableNull, joinTableNotNull)

#Remove fields. 
joinTable = etl.cutout(joinTable, 'name', 'f_name', 'l_name', 'email_address', 'phone_number')

#Left join planter Table on entity Table on person_id
joinTable = etl.leftjoin(joinTable, entityTable, lkey='person_id', rkey='id')

#Split table based on whether 'first name' field is null or not. 
joinTableNotNull = etl.select(joinTable, 'f_name', lambda row: row != None)
joinTableNull = etl.select(joinTable, 'f_name', lambda row: row == None)

#Convert values
#Here, if 'f_name' is not null, we have a planter entity. 
#So, we use values from planter entity to fill in fields.
joinTableNotNull = etl.convert(joinTableNotNull, {
    'first_name': lambda f_name, row: row.f_name, 
    'last_name': lambda l_name, row: row.l_name, 
    'email': lambda email, row: row.email_address, 
    'phone': lambda phone, row: row.phone_number}, pass_row=True)

#Else, we populate fields with random values. 
joinTableNull = etl.convert(joinTableNull, {
    'first_name': lambda f_name: fake.first_name(), 
    'last_name': lambda l_name: fake.last_name(), 
    'email': lambda email: fake.email(), 
    'phone': lambda phone: fake.phone_number()})

#Combine tables
joinTable = etl.cat(joinTableNotNull, joinTableNull)

#Remove fields
joinTable = etl.cutout(joinTable,'name', 'f_name', 'l_name', 'email_address', 'phone_number')

#Anonymize image_url
joinTable = etl.convert(joinTable, 'image_url', lambda row: fake.image_url())

#Select unique rows in table based on email criteria
joinTable = etl.distinct(joinTable, 'email')
etl.tocsv(joinTable, 'planter.csv')

#Load rows into database table. 
etl.todb(joinTable, tConnection, 'planter', 'public')
