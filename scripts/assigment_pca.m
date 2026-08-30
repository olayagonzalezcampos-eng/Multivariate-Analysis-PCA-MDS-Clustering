%% COMPLETE MULTIVARIATE ANALYSIS
% Variables:
% Numeric: age, uniform, food, books, computer, activities
% Binary : sex, help
% Categorical : nationality, type
clear
clc
close all

%% Import dataset
data = readtable('data_cleaning.csv');

numeric_vars     = {'age','uniform','food', 'books', 'computer','activities'};
binary_vars      = {'sex','help'};
categorical_vars = {'nationality','type'};

X_num = table2array(data(:, numeric_vars));
X_bin = table2array(data(:, binary_vars));
X_cat = data(:, categorical_vars);

[n,p] = size(X_num);

%% Basic descriptive statistics orginal data
means = mean(X_num);
medians = median(X_num);
vars = var(X_num);
stds = std(X_num);
mins = min(X_num);
maxs = max(X_num);

disp('Sample mean vector = ')
disp(means)
disp('Sample median vector = ')
disp(medians)
disp('Sample variance vector = ')
disp(vars)

%% Boxplot (to see variance of variables)
boxplot(X_num);

%% Covariance and correlation matrices original data
S = cov(X_num);       % Covariance matrix
R = corrcoef(X_num);  % Correlation matrix

disp('Covariance matrix S =')
disp(S)

disp('Correlation matrix R =')
disp(R)

disp('Generalized sample variance =')
disp(det(S))

disp('Total sample variance =')
disp(trace(S))

%% Scatterplot matrix original data 
figure
plotmatrix(X_num)
title('Scatterplot Matrix – Orginial Numeric Variables')

%% 4. Intercorrelation measures q1–q6
addpath(genpath("functions"))

q = intercorrelations(X_num);
fprintf('\nIntercorrelation measures q1–q6:\n');
disp(q);

figure
plot(q', 'LineWidth', 2, 'Marker', 'o')
title('Intercorrelation Measures q1–q6')
xlabel('q index')
ylabel('q-value')
grid on

%% Variance original data
format long g
v = var(X_num);
disp('Variance of numeric variables:')
disp(v)
disp(mean(X_num))

%% Transformation
X_num(:, 1) = log(X_num(:, 1)+2);
X_num(:, 2) = log(X_num(:, 2)+2);
X_num(:, 4) = log(X_num(:, 4)+2);
X_num(:, 5) = log(X_num(:, 5)+2);
X_num(:, 6) = log(X_num(:, 6)+2);
q_trans = intercorrelations(X_num);
%% Center data and compute covariance

H = eye(n) - ones(n)/n;
X_centered = H * X_num;
%standarize
sdv = std(X_num);  
Z = (X_centered)./ sdv;
figure
plotmatrix(Z)
title(' Scaled Scatterplot Matrix')

S = cov(Z);       % Covariance matrix
R = corrcoef(Z);  % Correlation matrix

disp('Covariance matrix S =')
disp(S)

disp('Correlation matrix R =')
disp(R)


%% Correlation heatmap transformed data
figure
myheatmap(R)
title('Correlation Heatmap')

h=heatmap(R);
mymap=[0 0 0.5
0 0.2 0.6
0 0.4 1
0.4 0.8 1
1 1 1
1 0.6 1
1 0.2 0.8
0.5 0 0.5
0.4 0 0.4];
h.ColorLimits = [-1 1];
h.Colormap=mymap;

%% 7. Intercorrelation by Nationality transformed data
nat = X_cat{:,1};     % categorical → numeric codes
q_nat = zeros(3, 6);

for g = 1:3
    idx = (nat == g);
    q_nat(g,:) = intercorrelations(Z(idx,:));
end
disp(q_nat);
figure
plot(q_nat', 'LineWidth', 2, 'Marker', 'o')
legend({'Nationality 1','Nationality 2','Nationality 3'}, ...
        'Location', 'best')
title('Intercorrelation Measures by Nationality')
xlabel('q index')
ylabel('q-value')
grid on


%% 8. Intercorrelation by Education Type
type = X_cat{:,2};    % categorical → numeric codes
q_type = zeros(3, 6);

for g = 1:3
    idx = (type == g);
    q_type(g,:) = intercorrelations(Z(idx,:));
end
disp(q_type);

figure
plot(q_type', 'LineWidth', 2, 'Marker', 'o')
legend({'Type 1','Type 2','Type 3'}, 'Location', 'best')
title('Intercorrelation Measures by Education Type')
xlabel('q index')
ylabel('q-value')
grid on

%% PCA with S
format bank
S = cov(Z)
[T_S, lambda_S] = eigsort(S)  % T = eigenvectors, lambda = eigenvalues column vector
disp('T = Eigenvectors')
disp(T_S)
disp('Lambda = eigenvalues column vector');
disp(lambda_S');

%% Variance percentages
percentages = lambda_S / sum(lambda_S) * 100;  
disp('Percentage of variance explained:')
disp(percentages')

%% Scatter plot 
[T1,Y1,acum1,T2,Y2,acum2]=comp2(Z)

%% Weights
h = bar(T_S(:,1:4));   
legend(h, {'PC1','PC2','PC3','PC4'}, 'Location','bestoutside');
xlabel('Variables');
ylabel('Loadings');
title('PCA Weights (from S)');
grid on;

%% Hypothesis test
D = sort(eig(S), 'descend');
for k=p-2:-1:0
    u(p-k-1) = (n-(2*p+11)/6)*((p-k)*log(sum(D(k+1:p))/(p-k))-sum(log(D(k+1:p))));
    df(p-k-1) = (p-k-1)*(p-k+2)/2;
    pvalue(p-k-1) = chi2cdf(u(p-k-1),df(p-k-1),'upper');
end
[u' df' pvalue']

%% Analyses of stability
rowsummary = PCAcovstability(S)
rowsummary
