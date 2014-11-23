library(RDSTK)
library(geosphere)
library(rjson)


distonplane <- function(point1,point2)
{
  diff <- point1 - point2
  distance <- sqrt(sum(diff^2))
  distance
}

distance.stretch <- function(point1,point2) {
  R <- 3963.1676
  p1rad <- point1 * pi/180
  p2rad <- point2 * pi/180
  distance <- R*distonplane(p1rad, p2rad)
  distance
}


#Address will be taken as input
address <- '6031 S. Ellis, Chicago, Illinois'
coordata <- street2coordinates(address)
coords <- c(coordata$latitude,coordata$longitude)


#Max distance (miles) will be taken as input
maxdist <- 2


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
  
  
  if(distance.stretch(coords,newcoords) < maxdist) {
    closdata$within[i] <- 1
  }
  else {
    closdata$within[i] <- 0
  }
}

within <- subset(closdata,within==1)

json <- toJSON(within)