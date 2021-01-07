from faker import Faker
import petl as etl

#Creates organization directory. 

fake = Faker(['en_US', 'en_GB']) #Locales: United States/Great Britain
Faker.seed(1234)

NumberOrganizations = 25 # # of organizations based on entity table
OrganizationDirectory = [['name', 'website', 'logo_url']]
for x in range(NumberOrganizations):
    TempRow = [fake.company(), fake.url(), fake.image_url()] #company name, website, image url
    OrganizationDirectory.append(TempRow)

etl.tocsv(OrganizationDirectory, 'OrganizationDirectory.csv', write_header=True)