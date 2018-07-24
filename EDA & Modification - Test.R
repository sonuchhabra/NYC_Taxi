###
##
# Getting Envrionment Ready and Reading Data (Will have read and output test data as well in this code)
##
###


# clear environment space
rm(list=ls())


# read the data from the test file
local_test <- read.csv("C:/Users/sonuc/Desktop/PM Project/original/test.csv")
local_test$original <- 'test'
str(local_test)

# storing local_test in df, keeping local_test as backup for now
df <- local_test
# rm(local_test)

###
##
# Exploratory Data Analysis and Data Cleaning
##
###


# checking structure of data
str(df)


# 01. id
length(unique(df$id))
## shows that all IDs are unique
## no data cleaning required


# 02. pickup_datetime
range(as.Date(df$pickup_datetime))
# shows range of data, doesn't seems to have outliers
# no data cleaning required just based on this variable


# 03. drop_datetime
range(as.Date(df$dropoff_datetime))
# shows range of data, doesn't seems to have outliers
# no data cleaning required just based on this variable


# 04. vendor id
table(df$vendor_id) # shows we have 2 vendors, vendor 1 and 2
## checking % of rides with vendor 1 and 2
prop.table(table(df$vendor_id))*100
## no data cleaning required


# 05. passenger count variable
summary(df$passenger_count)
table(df$passenger_count)
## checking % of people in every category
prop.table(table(df$passenger_count))*100

## -- Data Cleaning --
## imputing
df[df$passenger_count = 0 & df$passenger_count > 6,] = 1
## checking cleaned data
prop.table(table(df$passenger_count))*100


# 06. pickup longitude
summary(df$pickup_longitude)
boxplot(df$pickup_longitude) # not of much use because of such large dataset and so many outliers
range(df$pickup_longitude) # already covered in summary function
max(df$pickup_longitude) - min(df$pickup_longitude) # 60 seems too much


# 07. pickup latitude
summary(df$pickup_latitude)
max(df$pickup_latitude) - min(df$pickup_latitude) # 17 might be reasonable


# 08. drop longitude
summary(df$dropoff_longitude)
max(df$dropoff_longitude) - min(df$dropoff_longitude) # 60 seems too much


# 09. drop latitude
summary(df$dropoff_latitude)
max(df$dropoff_latitude) - min(df$dropoff_latitude) # 11 might be reasonable


# 10. store_and_fwd_flg
summary(df$store_and_fwd_flag)
## its categorical variable with values in one of the two categories
## no data cleaning required


# 11. trip_duration
## Prediction Variable, we will use for data cleaning for test data


###
##
# Variable Transformations
##
###


# checking df structure
str(df)


# split data and time
df$pickup_date <- as.Date(df$pickup_datetime)
df$pickup_time <- format(as.POSIXct(df$pickup_datetime,format="%Y-%m-%d %H:%M:%S"),"%H:%M:%S")


# converting date to days for pickupdatetime
df$pickup_day <- weekdays(as.Date(df$pickup_date,'%Y-%m-%d'))


# computing weekday and weekends
df$day_type <- 'Weekday'
df$day_type[df$pickup_day == 'Saturday' | df$pickup_day == 'Sunday'] <- 'Weekend'


# hour of the day
df$pickup_hour <- as.numeric(format(as.POSIXct(df$pickup_time,format="%H:%M:%S"),"%H"))


# day time like, morning, afternoon, evening, night
df$pickup_daytime <- 'Not Assigned'
df$pickup_daytime[df$pickup_hour >= 0 & df$pickup_hour < 6] <- 'Night'
df$pickup_daytime[df$pickup_hour >= 6 & df$pickup_hour < 12] <- 'Morning'
df$pickup_daytime[df$pickup_hour >= 12 & df$pickup_hour < 18] <- 'Afternoon'
df$pickup_daytime[df$pickup_hour >= 18 & df$pickup_hour < 24] <- 'Evening'


# pickup quadrants
vector_compare <- df$pickup_latitude >= 40.75435066
df$NSPU[vector_compare] <- 'North'
vector_compare <- df$pickup_latitude < 40.75435066
df$NSPU[vector_compare] <- 'South'
vector_compare <- df$pickup_longitude >= -73.98073197
df$EWPU[vector_compare] <- 'East'
vector_compare <- df$pickup_longitude < -73.98073197
df$EWPU[vector_compare] <- 'West'
df$Pickup_Cuadrant<- paste(df$NSPU,df$EWPU)
df$NSPU<-NULL
df$EWPU<-NULL
rm(vector_compare)


# dropoff quadrants
vector_compare <- df$dropoff_latitude >= 40.75435066
df$NSDO[vector_compare] <- 'North'
vector_compare <- df$dropoff_latitude < 40.75435066
df$NSDO[vector_compare] <- 'South'
vector_compare <- df$dropoff_longitude >= -73.98073197
df$EWDO[vector_compare] <- 'East'
vector_compare <- df$dropoff_longitude < -73.98073197
df$EWDO[vector_compare] <- 'West'
df$Dropoff_Cuadrant<- paste(df$NSDO,df$EWDO)
df$NSDO<-NULL
df$EWDO<-NULL
rm(vector_compare)


# distance between pickup and drop
# install.packages("geosphere")
library("geosphere")
# ?distm()
pickup_locality <- data.frame(df$pickup_longitude,df$pickup_latitude)
drop_locality <- data.frame(df$dropoff_longitude,df$dropoff_latitude)
# ?matrix()
df$distance <- distVincentyEllipsoid(pickup_locality, drop_locality)
rm(drop_locality, pickup_locality)


# holidays
holidays_2016 <- c('2016-01-01', '2016-01-18', '2016-05-30', '2016-02-15')
df$holiday <- 'No'
df$holiday[df$pickup_date == as.Date(holidays_2016,'%Y-%m-%d')] <- 'Yes'
rm(holidays_2016)


# holiday week
library(lubridate)
df$week <- week(df$pickup_date)
holiday_weeks <- unique(df$week[df$holiday == 'Yes'])
for (i in holiday_weeks) {
  df$week[df$week == i] <- 'Holiday Week'}
df$week[!(df$week == 'Holiday Week')] <- 'Non Holiday Week'
rm(i, holiday_weeks)


###
##
# Variable Transformations
##
###


# log transformation for distance variable
hist(df$distance)
hist(log(df$distance))
df$log_distance <- log(df$distance)


###
##
# Generating Final Output File/s
##
###


# writing data to final file
write.csv(df, "C:/Users/sonuc/Desktop/PM Project/Processed Train and Test/test_output.csv")


###
##
# Extra Variables Code, couldn't use thus commented
##
###


# # zipcodes
# ## install.packages("revgeo")
# library(revgeo)
# df$pickup_zipcode <- revgeo(longitude = df$pickup_longitude,latitude = df$pickup_latitude ,output='hash', item='zip')
# df$drop_zipcode <- revgeo(longitude = df$pickup_longitude,latitude = df$pickup_latitude ,output='hash', item='zip')


# # weather
# # install.packages("rnoaa")
# library(rnoaa)
# isd_stations_search(lat =  40.785091, lon = -73.968285, radius = NULL, bbox = NULL)
# climateData <- (res <- isd(usaf=99999, wban=94728, year=2016))
# date <- climateData$date
# temperature <- as.numeric(climateData$temperature)
# climate <- data.frame(date, temperature)
# summary(climate$temperature)
# daywise_temp1 <- aggregate(temperature ~ date, climate, mean)
# daywise_temp2 <- tapply(temperature,date, mean)