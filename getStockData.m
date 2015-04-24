function data = getStockData(allData, beginTime, endTime, format)
minTime = datenum(beginTime,format);
maxTime = datenum(endTime,format);
data = structfun(@(x) (x(x.Date>=minTime, :)), allData, 'UniformOutput', false);
data = structfun(@(x) (x(x.Date<=maxTime, :)), data, 'UniformOutput', false);