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
OrgDictionary = etl.lookup(OrgDirectory, 'name') #Dictionary format

#Transform
#Generic transforms: Lowercase type, capitalize first & last name
table = etl.convert(table, 'type', lambda entityType: entityType.lower())

#Seperate into two tables, organizations and planters
orgTable = etl.select(table, lambda row: row.type == 'o')
planterTable = etl.select(table, lambda row: row.type == 'p' or row.type == 'c')

#Replace with fake information. 
fake = Faker(['en_US', 'en_GB'])
Faker.seed(1234)
stringArray = string.digits + string.ascii_letters

#Add row #s to make lookup easier
orgTable = etl.addrownumbers(orgTable)
OrgDirectory = etl.addrownumbers(OrgDirectory)

#Fill in organization values based on organization directory.
orgTable = etl.convert(orgTable, 'name', lambda name, row: organization.CompanyName(OrgDirectory, row.row), pass_row = True)

orgTable = etl.convert(orgTable, {
    'first_name': lambda fname: None, #Set to null for name
    'last_name': lambda lname: None, 
    'email': lambda email: fake.email(), 
    'phone': lambda phone: fake.phone_number(), 
    'password': lambda password: word.secretWord(stringArray, password), 
    'salt': lambda salt: word.secretWord(stringArray, salt)
})

#Determine website string, using organiztion directory and name as parameters. 
orgTable = etl.convert(orgTable, 'website', lambda web, row: organization.randomWebsite(OrgDictionary, row.name), 
pass_row = True)

#Determine image url, using organiztion directory and name as parameters. 
orgTable = etl.convert(orgTable, 'logo_url', lambda image, row: organization.randomImage(OrgDictionary, row.name), 
pass_row = True)

#Wallet name for organization based on organization name
orgTable = etl.convert(orgTable, 'wallet', lambda wallet, row: row.name, pass_row = True)

planterTable = etl.convert(planterTable, {
    'name': lambda name: None, #Set organization to null
    'first_name': lambda fname: fake.first_name(), 
    'last_name': lambda lname: fake.last_name(), 
    'email': lambda email: fake.email(), 
    'phone': lambda phone: fake.phone_number(), 
    'password': lambda password: word.secretWord(stringArray, password), 
    'salt': lambda salt: word.secretWord(stringArray, salt), 
    'website': lambda web: None, #Null
    'logo_url': lambda logo: None
})

#Combine first name and last name to get wallet name. 
planterTable = etl.convert(planterTable, 'wallet', lambda wallet, row: word.combineWords(row.first_name, row.last_name), 
pass_row = True)

#Remove row field from orgTable. 
orgTable = etl.cutout(orgTable, 'row')

#Combine organization and planter tables
finalTable = etl.cat(orgTable, planterTable)

#Load

#Define database connection paraemters for target database
TDBNAME = config('TARGET_DBNAME')
TDBUSER = config('TARGET_DBUSER')
TDBPASSWORD = config('TARGET_DBPASSWORD')
TDBHOST = config('TARGET_DBHOST')
TDBPORT = config('TARGET_DBPORT')

tConnection = db.connect(database=TDBNAME, user=TDBUSER, password=TDBPASSWORD, 
host = TDBHOST, port = TDBPORT)

#Load rows into database table. 
etl.todb(finalTable, tConnection, 'entity', 'public')
