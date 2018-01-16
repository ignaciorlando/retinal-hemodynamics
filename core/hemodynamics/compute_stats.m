function [ stats ] = compute_stats( data, scenario, variable, coeff )
%COMPUTE_STATS Compute several statistics on the specified data.
%   The data argument is a cell array, each position correspond to a
%   certain patient. For each patient a cell matrix with the data for each
%   hemodynamic scenario is given. 
%   The coefficients array indicates the values that multiply (ceff(1)) and
%   sum (ceff(2)) to each data sample.
%
% Parameters:
% data: The data to be used in the statistics computation.
% scenario:  An array with two values indicating the row and column of the 
%            hemodynamic scenario of each patient to be used. If a zero is 
%            used in the row argument, all rows are used, the same with the
%            column.
% variable:  The column of thedata for each scenario that will be used.
% coeff:     The coefficients array indicates the values that multiply 
%            (ceff(1)) and sum (ceff(2)) to each data sample.
%
% Return:
% stats.n         The size of the Data used to compute the statistics.
% stats.mean      The mean of the data.
% stats.std       The standard deviation of the data.
% stats.coefOfVar The coefficient of variation, defined as the absolute
%                 value fo the ratio between the standard deviation and the
%                 mean of the Data.
% stats.min       The minimum value of the data.
% stats.max       The maximum value of the data.
% stats.median    The median of the data.
% stats.quantiles The quantiles for [0, 0.25, 0.50, 0.75].
% stats.Data      The Data array used to compute statistics.
%

% Construct the array to be used for statistics.
nSCol  = size(data{1},2);
nSRow  = size(data{1},1);
nVar   = size(data{1}{1},2);

if (scenario(1)==0);
    scRIni = 1;
    scREnd = nSRow;
else
    scCIni = scenario(1);
    scREnd = scenario(1);
end;

if (scenario(2)==0);
    scCIni = 1;
    scCEnd = nSCol;
else
    scCIni = scenario(2);
    scCEnd = scenario(2);
end;

Data = [];
for p = 1 : numel(data);
    for sci = scRIni : scREnd;
        for scj = scCIni : scCEnd;
            Data = [Data; data{p}{sci,scj}(:,variable)];
        end;
    end;
end;

Data = Data*coeff(1) + coeff(2);

stats.n         = numel(Data);
stats.mean      = mean(Data);
stats.std       = std(Data);
stats.coefOfVar = abs(stats.std / stats.mean);
stats.min       = min(Data);
stats.max       = max(Data);
stats.median    = median(Data);
stats.quantiles = quantile(Data, [0, 0.25, 0.50, 0.75]);
stats.Data      = Data;

end
