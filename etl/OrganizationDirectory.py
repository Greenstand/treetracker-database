from faker import Faker
import petl as etl

#Creates organization directory. 

fake = Faker(['en_US', 'en_GB']) #Locales: United States/Great Britain
Faker.seed(1234)

OrganizationDirectory = [['name', 'website', 'logo_url']]
for x in range(10):
    TempRow = [fake.company(), fake.url(), fake.image_url()] #company name, website, image url
    OrganizationDirectory.append(TempRow)

etl.tocsv(OrganizationDirectory, 'OrganizationDirectory.csv', write_header=True)