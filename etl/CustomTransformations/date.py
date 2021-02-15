import datetime
import random

#returns random date between two dates
#Parameter: start_Date, end_Date (type: datetime)
def randomDate(start_Date, end_Date): 
    return start_Date + datetime.timedelta(random.randint(0, (end_Date-start_Date).days))

start_Date = datetime.date(2020, 1, 1)
end_Date = datetime.datetime.now().date()

x = randomDate(start_Date, end_Date)
print(x)