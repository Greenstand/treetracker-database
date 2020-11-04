import random
import petl as etl

#Functions related to the Organization Directory

#Return random company from directory
#Parameter: companyName (type CSVView), row
def CompanyName(companyName, row):
    return companyName[row][1]

#Return random website from directory
#Parameters: table (type dictionary), CompanyName (type string)
def randomWebsite(table, CompanyName):
    companyRow = table[CompanyName] #Returns list with a tuple
    return companyRow[0][1] #Get actual row. Website is second value in row.

#Return random image_url from directory
#Paraemters: table (type dictionary), CompanyName (type string)
def randomImage(table, CompanyName):
    companyRow = table[CompanyName]
    return companyRow[0][2] #logo_url is third value in row. 