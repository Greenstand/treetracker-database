import petl as etl
import psycopg2 as db
from decouple import config
from faker import Faker

from CustomTransformations import entity

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

#Since we use target entity table to fill values in planter table, need target DB. 
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
entityTable = etl.cut(entityTable, 'id', 'name', 'first_name', 'last_name')

#Rename fields in entityTable
entityTable = etl.rename(entityTable, {'first_name': 'f_name', 'last_name': 'l_name'})

#Join planterTable with entityTable on organization_id
joinTable = etl.leftjoin(table, entityTable, lkey='organization_id', rkey='id')

# #Split table based on whether name field is null or not. 
joinTableNull = etl.select(joinTable, 'name', lambda row: row == None)
joinTableNotNull = etl.select(joinTable, 'name', lambda row: row != None)

# #Convert values in organization field based on values in name field. 
joinTableNull = etl.convert(joinTableNull, 'organization', lambda org, row: row.name, pass_row=True)
joinTableNotNull = etl.convert(joinTableNotNull, 'organization', lambda org, row: row.name, pass_row=True)

# #Combine tables. 
joinTable = etl.cat(joinTableNull, joinTableNotNull)

# #Remove values
joinTable = etl.cutout(joinTable, 'name', 'f_name', 'l_name')

# #Join planter Table on entity Table on person_id
joinTable = etl.leftjoin(joinTable, entityTable, lkey='person_id', rkey='id')

# # #Split table based on whether name field is null or not. 
joinTableNotNull = etl.select(joinTable, 'f_name', lambda row: row != None)
joinTableNull = etl.select(joinTable, 'f_name', lambda row: row == None)

# # #Convert values
fake = Faker(['en_US', 'en_GB']) #Locales: United States/Great Britain
Faker.seed(1234)

joinTableNotNull = etl.convert(joinTable, {
    'first_name': lambda f_name, row: row.f_name, 
    'last_name': lambda l_name, row: row.l_name}, pass_row=True)

joinTableNull = etl.convert(joinTableNull, {
    'first_name': lambda f_name: fake.first_name(), 
    'last_name': lambda l_name: fake.last_name()
})

joinTable = etl.cat(joinTableNotNull, joinTableNull)

# #Remove values
joinTable = etl.cutout(joinTable, 'name', 'f_name', 'l_name')

#Load rows into database table. 
etl.todb(joinTable, tConnection, 'planter', 'public')

# for row in joinTableNotNull[1:20]:
#     print(row)