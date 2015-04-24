#################################################
# A DEMO ON HOW TO DOWNLOAD STOCK PRICE ONLINE  #
# AND CREATE A TIME SERIES PLOT WITH R          #
#################################################

library(chron)
library(zoo)

dir <- "C:/Users/yxie/Documents/Portfolio Optimization/"

fundList <- read.csv('C:/Users/yxie/Documents/Portfolio Optimization/fund list.csv')

# DEFINE STARTING DATE
start.date  <- 1
start.month <- 1
start.year  <- 2010

# DEFINE ENDING DATE
end.date  <- 31
end.month <- 12
end.year  <- 2012


# Download all data in fundList

for (i in 1:nrow(fundList)){
  
  stock <- fundList[i,]
  
  
  # DEFINE URL LINK
  link <- paste("http://real-chart.finance.yahoo.com/table.csv?s=", stock,
                "&a=", as.character(start.month - 1),
                "&b=", as.character(start.date),
                "&c=", as.character(start.year),
                "&d=", as.character(end.month - 1),
                "&e=", as.character(end.date),
                "&f=", as.character(end.year),
                "&g=d&ignore=.csv", sep = '')
  
  # DOWNLOAD STOCK PRICE AS CSV FILE
  tryCatch(
    download.file(link, paste("C:/Users/yxie/Documents/Portfolio Optimization/", stock, ".csv",sep='')),
    error = function(e) e, finally = print(stock)
  )
  
}


cash <- 25000

portfolio <- c()

for (i in 1) {
  stock.value <- fundList[i,]
  if (file.exists(paste(dir,stock,".csv",sep=''))) {
    stock.data <- read.csv(paste(dir,stock,".csv",sep=''))
    dt <- dates(as.character(stock.data[,1]), format = "y-m-d")
  }
}


# READ THE CSV FILE INTO R
data <- read.csv("C:/Users/yxie/Documents/Portfolio Optimization/data.csv")

# CONVERT CHARACTER INTO DATE
dt <- dates(as.character(data[, 1]), format = "y-m-d")

# CONVERT DATA FRAME INTO TS OBJECT
ts <- zoo(data[, 2:5], dt)

# CREATE A PLOT FOR OPEN/CLOSE/HIGH/LOW PRICES
plot(ts, main = stock)

