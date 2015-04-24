function plotStock(stock, data2, stockPred, stockStd)

figure
plot(data2.(stock).Date, data2.(stock).Close - [data2.(stock).Date ...
    ones(size(data2.(stock).Date,1),1)] * stockPred.(stock)');
hold on
plot(data2.(stock).Date, ones(length(data2.(stock).Date),1) * stockStd.(stock));
plot(data2.(stock).Date, - ones(length(data2.(stock).Date),1) * stockStd.(stock));
hold off