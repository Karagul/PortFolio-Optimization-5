function popt()
% portfolio optimization
% Yao Xie, 4/23/15

%% Parameters
warning('off', 'all')
warning
ratio = 0.0075;

%% Download stock training data
[~,~,fundList] = xlsread('Fund list.xlsx');
% allData = getYahooDailyData(fundList(1:300), '01/01/2011', '12/31/2014', 'mm/dd/yyyy');
load allData
% load 300fund

%% rm stocks that has short history
stocks = fieldnames(allData);
n = size(allData.FFNOX,1);
for i = 1:length(stocks)
    stock = stocks{i};
    if size(allData.(stock),1) ~= n  
       allData = rmfield(allData, stock);
    end
end

%% Create training and testing data
data = getStockData(allData, '01/01/2011', '12/31/2013', 'mm/dd/yyyy');
data2 = getStockData(allData, '01/01/2014', '12/31/2014', 'mm/dd/yyyy');


%% Get stock average performance
stockPred = structfun(@(x) (polyfit(x.Date, x.Close,1)), data, 'UniformOutput',false);
stockStd = structfun(@(x) std((x.Close - [x.Date ones(size(x.Date,1),1)] ...
    * polyfit(x.Date, x.Close,1)')), data, 'UniformOutput',false);
% hist(data.FFNOX.Close - [data.FFNOX.Date ones(size(data.FFNOX.Date,1),1)] * stockPred.FFNOX');
% plot(data.FFNOX.Date, data.FFNOX.Close - [data.FFNOX.Date ones(size(data.FFNOX.Date,1),1)] * stockPred.FFNOX');

stocks = fieldnames(data);
% data2 = getYahooDailyData(stocks, '01/01/2014', '12/31/2014', 'dd/mm/yyyy');
n2 = size(data2.FFNOX,1); % total # of days
 
%% Control 
cash = 25000;
stockMin = 2500;
controlExp(data2,stockPred,cash,stockMin);



%% Model
P = structfun(@(x) (0), data2, 'UniformOutput',false); % portfolio holds
vP = structfun(@(x) (0), data2, 'UniformOutput', false); % value of portfolio 
buyInP = structfun(@(x) (0), data2, 'UniformOutput', false); % buy in price

% stock = 'FGRTX';
% plotStockA(stock,data,stockPred, stockStd);

for day = 1:n2
%     % print
%     fprintf('%d ',day);
%     totalV = cash;
%     for i = 1:length(stocks)
%         stock = stocks{i};
%         if P.(stock) > 0
%             fprintf([stock ' ']);
%             totalV = totalV + P.(stock) * data2.(stock){day,'Close'};
%         end
%     end
    
%     fprintf('%4f ', totalV);
%     fprintf('\n');
    
    % Update prediction 
    maxTimeNum = datenum('12/31/2013','mm/dd/yyyy') + day;
    timeWindow = 180;
    minTimeNum = maxTimeNum - timeWindow; 
    maxTime = datestr(datetime(maxTimeNum,'ConvertFrom','datenum'),'mm/dd/yyyy');
    minTime = datestr(datetime(minTimeNum,'ConvertFrom','datenum'),'mm/dd/yyyy');
    tmpData = getStockData(allData, minTime, maxTime, 'mm/dd/yyyy');
    stockPred = structfun(@(x) (polyfit(x.Date, x.Close,1)), tmpData, 'UniformOutput',false);
    stockStd = structfun(@(x) std((x.Close - [x.Date ones(size(x.Date,1),1)] ...
    * polyfit(x.Date, x.Close,1)')), data, 'UniformOutput',false);

    % Initialize rewarding index every day
    rIndex = zeros(length(stocks),1);
    rP = table(stocks, rIndex);
    
    % Update value of portfolio based on the current price
    for i = 1:length(stocks)
        stock = stocks{i};
        if P.(stock)
            vP.(stock) = P.(stock) * data2.(stock){day,'Close'};
        end
    end
    
    % Go through each stock 
    for i = 1:length(stocks)
        stock = stocks{i};
        currTime = data2.(stock){day,'Date'};
        currPrice = data2.(stock){day,'Close'};
        predPrice = [data2.(stock){day,'Date'} 1] * stockPred.(stock)';
        if P.(stock) % stock is in the portfolio 
            
            if currPrice > predPrice + stockStd.(stock) || (currPrice - buyInP.(stock))/buyInP.(stock) > 0.2 % 
                % sell the fund
                fprintf(['%d Sell ' stock ':%.2f @ %.2f\n'], day, vP.(stock), currPrice);
                
                
                plotStockA(stock,allData,stockPred, stockStd, currTime);
                pause
                
                cash = cash + vP.(stock) - vP.(stock)*ratio;
                P.(stock) = 0;
                vP.(stock) = 0;
                buyInP.(stock) = 0;
            end
        else % stock is not in the portfolio
            if currPrice < predPrice - 2 * stockStd.(stock) %&& stockPred.(stock)(1) > 0
%                 currPrice = data2.(stock){day,'Close'};
                rP.rIndex(i) = (predPrice - currPrice)/currPrice; 
            end
        end
    end
    
%     fprintf(rP);
    
    % Buy funds with the best rewarding index
    rP = sortrows(rP,'rIndex','descend');
    for i = 1: min(((cash - mod(cash,stockMin))/stockMin), size(rP,1))
        stock = rP.stocks{i};
        if rP.rIndex(i) > 0% && stockPred.(stock)(1) > 0
            P.(rP.stocks{i}) = P.(rP.stocks{i}) + stockMin/data2.(rP.stocks{i}){day,'Close'}; % # of holds
            buyInP.(rP.stocks{i}) = data2.(rP.stocks{i}){day,'Close'};
            fprintf(['%d: Buy ' rP.stocks{i} ':2500 @ %.2f \n'], day, buyInP.(rP.stocks{i}));
            cash = cash - stockMin;
            
            plotStockA(rP.stocks{i},allData,stockPred, stockStd, currTime);
            pause
                
        end
    end
    
end

    % print
    fprintf('%d ',day);
    totalV = cash;
    for i = 1:length(stocks)
        stock = stocks{i};
        if P.(stock) > 0
            fprintf([stock ' ']);
            totalV = totalV + P.(stock) * data2.(stock){day,'Close'};
        end
    end
    
    fprintf('%.2f ', totalV);
    fprintf('\n');




