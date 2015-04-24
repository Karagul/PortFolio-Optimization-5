function plotStockA(stock, data2, stockPred, stockStd, currTime)

figure
hold on
plot(data2.(stock).Date, data2.(stock).Close);

plot(data2.(stock).Date,  [data2.(stock).Date ...
    ones(size(data2.(stock).Date,1),1)] * stockPred.(stock)');

plot(data2.(stock).Date, [data2.(stock).Date ...
    ones(size(data2.(stock).Date,1),1)] * stockPred.(stock)' + ...
    ones(length(data2.(stock).Date),1) * stockStd.(stock));
plot(data2.(stock).Date, [data2.(stock).Date ...
    ones(size(data2.(stock).Date,1),1)] * stockPred.(stock)' - ...
    ones(length(data2.(stock).Date),1) * stockStd.(stock));
title(stock);

y = get(gca, 'ylim');
plot([currTime currTime],y);

hold off