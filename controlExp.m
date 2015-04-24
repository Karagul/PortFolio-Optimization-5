function controlExp(data2, stockPred,cash,stockMin)
stocks = fieldnames(data2);
rIndex = zeros(length(stocks),1);
rP = table(stocks, rIndex);
for i = 1:length(stocks)
    stock = stocks{i};
    rP{i,'rIndex'} = stockPred.(stock)(1);
end
P = structfun(@(x) (0), data2, 'UniformOutput',false); % portfolio holds
vP = structfun(@(x) (0), data2, 'UniformOutput', false); % value of portfolio 
day = 1;
for i = 1: min(((cash - mod(cash,stockMin))/stockMin), size(rP,1))
    if rP.rIndex(i) > 0
        P.(rP.stocks{i}) = stockMin/data2.(rP.stocks{i}){day,'Close'}; % # of holds
        cash = cash - stockMin;
    end
end
n2 = size(data2.FFNOX,1);
day = n2; 
totalV = cash;
for i = 1:length(stocks)
    stock = stocks{i};
    if P.(stock) > 0
        fprintf([stock ' ']);
        totalV = totalV + P.(stock) * data2.(stock){day,'Close'};
    end
end
fprintf('total value: %.2f \n', totalV);