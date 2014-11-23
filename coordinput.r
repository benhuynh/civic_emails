library(RDSTK)
library(geosphere)
library(rjson)


#Address will be taken as input
address <- '6031 S. Ellis, Chicago, Illinois'
coordata <- street2coordinates(address)
coords <- c(coordata$latitude,coordata$longitude)


#Max distance (miles) will be taken as input
maxdist <- 5



##############################################################################################################
#                                         Crime Data                                                         #
##############################################################################################################
frame <- read.csv('http://plenar.io/v1/api/detail/?dataset_name=crimes_2001_to_present&obs_date__le=2014%2F11%2F15&obs_date__ge=2014%2F11%2F01&agg=day&dataset_name=crimes_2001_to_present&data_type=csv&offset=100000000000000000')
today <- 22
year <- 2014
month <- 11
dayend <- today-10
daystart <- dayend-7
offset = 0
while(today) {
  dita <- read.csv(paste0('http://plenar.io/v1/api/detail/?dataset_name=crimes_2001_to_present&obs_date__le=',year,
                          '%2F',month,'%2F',dayend,'&obs_date__ge=',year,'%2F',month,'%2F',daystart,
                          '&agg=day&dataset_name=crimes_2001_to_present&data_type=csv&offset=',offset))
  if(nrow(dita) ==0) {
    break
  }
  row.names(dita) <- NULL
  frame <- rbind(frame,dita)
  offset = offset+1000
}

data <- frame
data <- data[c('date','block','primary_type','description','location_description','arrest','domestic','latitude','longitude')]
data <- na.omit(data)
row.names(data) <- NULL


for(i in 1:dim(data)[1]) {
  if(distHaversine(coords,c(data$latitude[i],data$longitude[i]),r=3963.1676) < maxdist) {
    data$within[i] <- 1
  }
  else {
    data$within[i] <- 0
  }
}
withindist <- subset(data,within==1)

#dist <- distHaversine(coords,r=3963.1676)


##############################################################################################################
#                                         Street Closure Data                                                #
##############################################################################################################

closdata <- read.csv('https://data.cityofchicago.org/api/views/avwc-kf7i/rows.csv?accessType=DOWNLOAD')
closdata <- closdata[-1,]
row.names(closdata) <- NULL

for(i in 1:dim(closdata)[1]) {
  sname <- closdata$STREET.NAME[i]
  direction <- closdata$DIRECTION[i]
  from <- closdata$FROM.DIRECTION.NUMBER[i]
  to <- closdata$TO.DIRECTION.NUMBER[i]
  from <- as.numeric(as.character(from))
  to <- as.numeric(as.character(to))

  mid <- ceiling((from+to)/2)
  sfx <- closdata$STREET.SUFFIX[i]
  newcoordsdata <- street2coordinates(paste(mid,direction,sname,sfx,'Chicago, Illinois',sep=' '))
  newcoords <- c(newcoordsdata$latitude,newcoordsdatafrom$longitude)
  
  
  if(distHaversine(coords,newcoords,r=3963.1676) < maxdist) {
    closdata$within[i] <- 1
  }
  else {
    closdata$within[i] <- 0
  }
}




