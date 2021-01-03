import petl as etl
import psycopg2 as db
from decouple import config
from faker import Faker

#ETL Script for 'public.payment' table. 

#Extract
#Define database connection paraemters for original database
ODBNAME = config('ORIGINAL_DBNAME')
ODBUSER = config('ORIGINAL_DBUSER')
ODBPASSWORD = config('ORIGINAL_DBPASSWORD')
ODBHOST = config('ORIGINAL_DBHOST')
ODBPORT = config('ORIGINAL_DBPORT')

oConnection = db.connect(database=ODBNAME, user=ODBUSER, password=ODBPASSWORD, 
host = ODBHOST, port = ODBPORT)
table = etl.fromdb(oConnection, 'SELECT * FROM public.payment')

#Since we use target entity table to fill fields in planter table, need target DB. 
#Define database connection paraemters for target database
TDBNAME = config('TARGET_DBNAME')
TDBUSER = config('TARGET_DBUSER')
TDBPASSWORD = config('TARGET_DBPASSWORD')
TDBHOST = config('TARGET_DBHOST')
TDBPORT = config('TARGET_DBPORT')

tConnection = db.connect(database=TDBNAME, user=TDBUSER, password=TDBPASSWORD, 
host = TDBHOST, port = TDBPORT)
entityTable = etl.fromdb(oConnection, 'SELECT id FROM public.entity')

#Transform
#Innerjoin payment table with entity table on 'sender_entity_id'
joinTable = etl.join(table, entityTable, lkey= 'sender_entity_id', rkey='id')

#Remove 'id' field from table. 
joinTable = etl.cutout(joinTable, 'id')

#Innerjoin payment table with entity table on 'receiver_entity_id'
joinTable = etl.join(joinTable, entityTable, lkey='receiver_entity_id', rkey='id')

#Remove 'id' field from table. 
joinTable = etl.cutout(joinTable, 'id')

#Instance of Faker class
fake = Faker(['en_US', 'en_GB']) #Locales: United States/Great Britain
Faker.seed(1234)

#Anonymize values
joinTable = etl.convert(joinTable, {
    'date_paid': lambda row: None, #Some transformation
    'tree_amt': lambda row: None,#Some transformation
    'usd_amt': lambda row: None,#Some transformation
    'local_amt': lambda row: None,#Some transformation
    'paid_by': fake.email()
})

#Load rows into database table. 
etl.todb(joinTable, tConnection, 'planter', 'payment')