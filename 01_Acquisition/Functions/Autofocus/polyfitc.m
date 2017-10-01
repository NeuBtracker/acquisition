function P = polyfitc(X, Y, N, varargin)
% POLYFITC allows the user to provide the polynomial fitting
% procedure with constraints regarding the polynomial degree.
% Note, that this function does not provide the centering and scaling
% transformations option as the original polyfit function does.
%
% Usage:
% P = polyfitc(X, Y, N)
% where:
%   X : a vector containing the x data
%   Y : a vector containing the y data
%   N : a vector containing the desired polynomial degrees (see examples)
%       Note, that N can only contain unique positive integers
%   P : a vector with the resulting coefficients
%
% P = polyfitc(X, Y, N, option)
% where option can be:
%   'raw' {default}: coefficients will be in the order as given in N
%   'asc'          : coefficients will be returned in ascending order
%                    (lowest order first)
%   'desc'         : coefficients will be returned in descending order
%                    (highest order first)
%   'polyval'      : coefficients will be returned such that they can be
%                    used in the MATLAB polyval function
%
% Example:
% Suppose you know that the data you want to fit is purely quadratic in
% nature and may have an offset, but you are sure that there is no linear
% term present in the equation. The regular polyfit function will give you
% a linear term. POLYFITC offers the choice which orders to fit and return
% the result in a vector which can be used in polyval if desired:
%
% X = -9:9;
% Y = -sqrt(1i^1i)*X.^2 + 10; % dummy function
% X = X + rand(1,19) - 0.5; % add some noise to X
% Y = Y + 3*(rand(1,19)-.5); % add some noise to Y
% Pnormal = polyfit(X, Y, 2) % normal MATLAB polyfit result (linear term)
% Pmimic = polyfitc(X, Y, 0:2, 'desc') % mimic the MATLAB polyfit
% Ppolyval = polyfitc(X, Y, [0 2], 'polyval') % force linear term to zero.
%
% (C) M. van Dijk, FOCAL, 2014-09


%% input checks

% check 1: X and Y must be vectors
if ~isvector(X)
    error('X-data must be a vector');
end
if ~isvector(Y)
    error('Y-data must be a vector');
end

% check 2: X and Y should be of equal length
if numel(X) ~= numel(Y)
    error('X and Y must contain an equal number of elements')
end

% check 3: N must be a vector
if ~isvector(N)
    error('N must be a vector');
end

% check 4: N must be unique, positive and integer
if numel(N) ~= numel(unique(N))
    error('N contains non-unique values')
end
if prod(N == abs(N)) ~= 1
    error('N contains negative values')
end
if prod(N == ceil(N)) ~= 1
    error('N contains non-integer values')
end

% check option
if nargin == 4
    option = varargin{1};
elseif nargin > 4
    error('Too many input arguments')
else
    option = 'raw';
end
switch option
    case 'raw'
        % do nothing
    case 'asc'
        N = sort(N, 'ascend');
    case 'desc'
        N = sort(N, 'descend');
    case 'polyval'
        % do nothing
    otherwise
        % invalid input
        warning('invalid option entered, default ''raw'' is used')
end

% make sure Y-data is in column vectors
if isrow(Y)
    Y = Y';
end
        

%% calculations
lsqM = ones(numel(X), numel(N));
for n = 1:numel(N)
    lsqM(:, n) = X.^N(n);
end
P = (lsqM \ Y)';

if strcmp(option, 'polyval')
    Ppv = zeros(1, max(N)+1);
    Ppv(N+1) = P;
    P = Ppv(end:-1:1);
end


