import petl as etl
import psycopg2 as db
from decouple import config
from faker import Faker

from CustomTransformations import organization
from CustomTransformations import word
import string

#ETL Script for 'public.entity' table. 

#Extract
#Define database connection paraemters for original database
ODBNAME = config('ORIGINAL_DBNAME')
ODBUSER = config('ORIGINAL_DBUSER')
ODBPASSWORD = config('ORIGINAL_DBPASSWORD')
ODBHOST = config('ORIGINAL_DBHOST')
ODBPORT = config('ORIGINAL_DBPORT')

oConnection = db.connect(database=ODBNAME, user=ODBUSER, password=ODBPASSWORD, 
host = ODBHOST, port = ODBPORT)
table = etl.fromdb(oConnection, 'SELECT * FROM public.entity')

#Also extract from Organization Directory file.
OrgDirectory = etl.fromcsv('OrganizationDirectory.csv')
#OrgDirectory = dict(OrgTable)


#Transform
#Filter out rows where first & last name are null or organization name is null
table = etl.select(table, lambda row: row.name != None and row.name != ""
and row.first_name != None and row.last_name != None)

#Lowercase type, capitalize first & last name
table = etl.convert(table, {
    'type': lambda entityType: entityType.lower(),
    'first_name': lambda fName: fName.capitalize(),
    'last_name': lambda lName: lName.capitalize()
})

#Replace with fake information. 
fake = Faker(['en_US', 'en_GB'])
Faker.seed(1234)
stringArray = string.digits + string.ascii_letters

#Need to extract organization names into a list for randomization. 
OrgLength = len(OrgDirectory) #Number of rows in Organization Directory.
OrgNameList = []
for row in range(1, OrgLength): #Start at 1 since first row is header row.
    OrgNameList.append(OrgDirectory[row][0])

table = etl.convert(table, {
    'name': lambda name: organization.randomCompany(OrgNameList),
    'first_name': lambda fname: fake.first_name(), 
    'last_name': lambda lname: fake.last_name(), 
    'email': lambda email: fake.email(), 
    'phone': lambda phone: fake.phone_number(), 
    'password': lambda password: word.secretWord(stringArray, password), 
    'salt': lambda salt: word.secretWord(stringArray, salt)
})

#Determine website string, using organiztion directory and name as parameters. 
table = etl.convert(table, 'website', lambda web, row: organization.randomWebsite(OrgDirectory, row.name), 
pass_row = True)

#Determine image url, using organiztion directory and name as parameters. 
table = etl.convert(table, 'logo_url', lambda image, row: organization.randomImage(OrgDirectory, row.name), 
pass_row = True)

#Combine first name and last name to get wallet name. 
table = etl.convert(table, 'wallet', lambda wallet, row: word.combineWords(row.first_name, row.last_name), 
pass_row = True)

#Load
#Define database connection paraemters for target database
TDBNAME = config('TARGET_DBNAME')
TDBUSER = config('TARGET_DBUSER')
TDBPASSWORD = config('TARGET_DBPASSWORD')
TDBHOST = config('TARGET_DBHOST')
TDBPORT = config('TARGET_DBPORT')

tConnection = db.connect(database=TDBNAME, user=TDBUSER, password=TDBPASSWORD, 
host = TDBHOST, port = TDBPORT)

#Append inserts new rows into database table. 
etl.appenddb(table, tConnection, 'entity', 'public')
