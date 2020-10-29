import random
import petl as etl

#Functions related to the Organization Directory

#Return random company from directory
#Parameter: companyName (type list)
def randomCompany(companyName):
    return random.choice(companyName)

#Return random website from directory
#Paraemters: table (type CSVView), CompanyName (type string)
def randomWebsite(table, CompanyName):
    companyRow = etl.selecteq(table, 'name', CompanyName) #Returns both header and row
    return companyRow[1][1] #Get actual row. Website is second value in row.

#Return random image_url from directory
#Paraemters: table (type CSVView), CompanyName (type string)
def randomImage(table, CompanyName):
    companyRow = etl.selecteq(table, 'name', CompanyName)
    return companyRow[1][2] #logo_url is third value in row. 