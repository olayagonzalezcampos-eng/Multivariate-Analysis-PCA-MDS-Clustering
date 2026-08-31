%% COMPLETE MULTIVARIATE ANALYSIS
% Variables:
% Numeric: age, uniform, food, books, computer, activities
% Binary : sex, help
% Categorical : nationality, type
clear
clc
close all


%% =========================================================================
% MDS
%==========================================================================

set(0,'DefaultFigureWindowStyle','docked')  % todas las figuras se acoplan
% set(0,'DefaultFigureWindowStyle','normal') % para volver al formato
% normal
%% Import dataset
data = readtable('data/processed/data_cleaning.csv');

numeric_vars     = {'age','uniform','food', 'books', 'computer','activities'};
binary_vars      = {'sex','help'};
categorical_vars = {'nationality','type'};

X_num = table2array(data(:, numeric_vars));
X_bin = table2array(data(:, binary_vars));
X_cat = data(:, categorical_vars);

[n,p] = size(X_num);

%% Log-Transformation of continuous variables
X_num(:, 1) = log(X_num(:, 1) + 2);
X_num(:, 2) = log(X_num(:, 2) + 2);
X_num(:, 4) = log(X_num(:, 4) + 2);
X_num(:, 5) = log(X_num(:, 5) + 2);
X_num(:, 6) = log(X_num(:, 6) + 2);

%% Center and Standardization of continuous variables
H = eye(n) - ones(n)/n;
X_centered = H * X_num;
sdv = std(X_num);
Z = X_centered ./ sdv;

%% Convert categorical variables to numeric indexes

X_cat_num = zeros(n, length(categorical_vars));

for j = 1:length(categorical_vars)
    X_cat.(categorical_vars{j}) = categorical(X_cat.(categorical_vars{j}));
    [G, ~] = findgroups(X_cat.(categorical_vars{j}));
    X_cat_num(:, j) = G;
end

%% ========================================================================
% MDS USING GOWER'S DISTANCE
%--------------------------------------------------------------------------
addpath(genpath("functions"))
X = [Z, X_bin, X_cat_num];   % final numeric matrix

p1 = size(Z, 2);           % numeric variables
p2 = size(X_bin, 2);       % binary variables
p3 = size(X_cat_num, 2);   % categorical variables

D_Gower = 2*(ones(n) - gower2(X, p1, p2, p3));
[Y, vaps, percent, accum] = coorp(D_Gower);

%Eigenvalues of Gram matrix
disp(vaps(1:6))
%Percentge of variation explained by each principal coordinate
disp(percent(1:6))
%Cumulated percentage of explained variability 
disp(accum(1:6))

%Mean of coordinates
meanY = mean(Y);

fprintf('\n--- Mean(Y) (first 6 coordinates) ---\n');
disp(meanY(1:6));


var_cols = (vaps/n);
disp(var_cols(1:6));
varY = var(Y);
disp(varY(1:6));

%% Geometric variability
vgeom = sum(sum(D_Gower)) / n^2;
fprintf("\n--- Geometric Variability ---\n");
disp(vgeom);

%% Cross correlation / associations (Pearson, Cramer, Spearman)
pcuant   = p1;        % quantitative variables
pnominal = p2 + p3;   % binary + categorical = nominal

fprintf("\n--- Correlations/Associations Table ---\n");
corr_table = correlaciones2(X, Y(:,1:3), pcuant, pnominal);

%% ========================================================================
% MDS using RelMS distance
%--------------------------------------------------------------------------
Dquant  = squareform(pdist(Z,'mahal')).^2;
X_qual  = X(:, p1+1:end);          % == [X_bin, X_cat_num]
Dqual   = ones(n) - coincidencias(X_qual);
Djoint  = relms2(Dquant, Dqual);
[Y_r, vaps_r, percent_r, accum_r] = coorp(Djoint);

%Eigenvalues of Gram matrix
disp(vaps_r(1:6))
%Percentge of variation explained by each principal coordinate
disp(percent_r(1:6))
%Cumulated percentage of explained variability 
disp(accum_r(1:6))

%Mean of coordinates
meanY_r = mean(Y_r);

fprintf('\n--- Mean(Y) (first 6 coordinates) ---\n');
disp(meanY_r(1:6));

var_cols_r= (vaps_r/n);
disp(var_cols_r(1:6));
varY_r = var(Y_r);
disp(varY_r(1:6));

%% Cross correlation / associations (Pearson, Cramer, Spearman)
pcuant   = p1;        % quantitative variables
pnominal = p2 + p3;   % binary + categorical = nominal

fprintf("\n--- Correlations/Associations Table ---\n");
corr_table = correlaciones2(X, Y_r(:,1:3), pcuant, pnominal);

%% ========================================================================
% Influence original variables on the principal coordinates
% Profile identification (conditional scatterplots)
% =========================================================================
% Most influential continuous variables: 2 (uniform) and 3 (food)
%identif_cuantis(X(:,[2,3]),Y)
%grupo=X(:,j);
%
   figure
   colormap("cool") 
   scatter(Y_r(:,1),Y_r(:,2),[],X(:,2),"filled")
   colorbar
   title('X2: uniform')

   figure
   colormap("cool") 
   scatter(Y_r(:,1),Y_r(:,2),[],X(:,3),"filled")
   colorbar
   title('X3: food')
%% Most influential binary variables: 7 (sex) and 8 (help)
% Scatterplot of just the first 2 principal coordinates
   identif_cualis(X(:,[7,8]),Y_r)
   figure
   gplotmatrix(Y_r(:,1),Y_r(:,2),X(:,7),'','+o*.xsd^v><ph',[],'on','')
   title('First 2 Principal Components grouped by variable 2')
   figure
   gplotmatrix(Y_r(:,1),Y_r(:,2),X(:,8),'','+o*.xsd^v><ph',[],'on','')
   title('First 2 Principal Components grouped by variable 3')

   %% Most influential binary variables: 7 (sex) and 8 (help)
   % Multiscatterplot of 3 Principal Coordinates 
   % grouped by variables 7 and 8

groupLabels7 = categorical(X(:,7), [0 1], {'Male', 'Female'});
figure;
gplotmatrix(Y_r(:,1:3),[],groupLabels7)
title('Variable 7: Sex');

groupLabels8 = categorical(X(:,8), [0 1], {'No', 'Yes'});
figure;
gplotmatrix(Y_r(:,1:3),[],groupLabels8)
title('Variable 8: Help');


%% Most influential categorical variable: 10 (type)

groupLabels10 = categorical(X(:,10), [1 2 3], {'Public', 'State-Funded Private', 'Private'});
figure;
gplotmatrix(Y_r(:,1:3),[],groupLabels10)
title('Variable 10: Type of Schooling');

%% ========================================================================
% 10. VARIABLE PARTIAL INFLUENCE ON THE PRINCIPAL COORDINATES 
% =========================================================================
influence(X,p1,p2)   % without colors
%%
% influence2 is a modification of function influence.m that adds colors, markers and legend to the plots
influence2(X,p1,p2)  

%% ========================================================================
% Stability of the MDS configuration: using Gower's projection
%==========================================================================
% we are analyzing the influence of the observations/units on the MDS
% configuration
sensitividad_Gower(X,p1,p2)


%% ========================================================================
% CLUSTERING
%==========================================================================

Xclust = Z;   % only standarized quantitative variables

%% CLUSTER JERARQUICO single (Gower)
%complete
d = squareform(D_Gower);
Umin = linkage(d, 'single');

figure;
dendrogram(Umin,0, 'orientation', 'left', 'colorthreshold', 0.2528)
title('Single linkage (Gower distance)')
ylabel('Individuals')
xlabel('Dissimilarity')


%% CLUSTER JERARQUICO complete (Gower)
% como son datos mixtos usamos matriz de distancias de gower

%complete
Umax = linkage(d, 'complete');

figure;
dendrogram(Umax,0, 'orientation', 'left', 'colorthreshold', 1.35)
title('Complete linkage (Gower distance)')
ylabel('Individuals')
xlabel('Dissimilarity')



%% CLUSTER JERARQUICO average (Gower)
% como son datos mixtos usamos matriz de distancias de gower
d = squareform(D_Gower);
%complete
Uave = linkage(d, 'average');

figure;
dendrogram(Uave,0, 'orientation', 'left', 'colorthreshold', 0.65)
title('Average linkage (Gower distance)')
ylabel('Individuals')
xlabel('Dissimilarity')

%% COPHENETICS
%cophenetic correlation
cmax=cophenet(Umax,d);
cmin=cophenet(Umin,d);
cave=cophenet(Uave,d);
[cmin cmax cave]



%% (k-means clustering)
kmax = 6; % xq es el numero de vbles cuantitativas
[C,s,IDX] = kmedias2(Xclust, kmax);

disp('WCSS costs for each k:')
disp(C)

disp('Average silhouette for each k:')
disp(s)

%% K-means based on PCA
[T1,Y1,acum1,T2,Y2,acum2]=comp2(Z);
[C2,s2,IDX2]=kmedias2(Y2,kmax);
disp('Average silhouette for each k:')
disp(s2)
format short g
grpstats(X_num, IDX2, {'mean','median'})
%% Mean of the clusters

format short g
disp(mean * 1000)

%% K-medoids clustering

X_std = zscore(X_num);  
k = 2;
[idx, C, sumd, D, midx, info] = kmedoids(X_std, k, ...
                                        'Distance','mahalanobis');
medoids = X_num(midx, :);

%% -------------------  PLOTS (RAW DATA)  ----------------------

figure

% ---- (1) X1 vs X2 ----
subplot(1,3,1)
hold on
plot(X_num(idx==1,1), X_num(idx==1,2), 'r.', 'MarkerSize',10)
plot(X_num(idx==2,1), X_num(idx==2,2), 'b.', 'MarkerSize',10)
plot(medoids(:,1), medoids(:,2), 'co', 'MarkerSize',12, 'LineWidth',2)
legend('Cluster 1','Cluster 2','Medoids','Location','best')
title('Cluster assignments and medoids')
xlabel('X1'); ylabel('X2')
hold off


% ---- (2) X1 vs X3 ----
subplot(1,3,2)
hold on
plot(X_num(idx==1,1), X_num(idx==1,3), 'r.', 'MarkerSize',10)
plot(X_num(idx==2,1), X_num(idx==2,3), 'b.', 'MarkerSize',10)
plot(medoids(:,1), medoids(:,3), 'co', 'MarkerSize',12, 'LineWidth',2)
legend('Cluster 1','Cluster 2','Medoids','Location','best')
title('Cluster assignments and medoids')
xlabel('X1'); ylabel('X3')
hold off


% ---- (3) X2 vs X3 ----
subplot(1,3,3)
hold on
plot(X_num(idx==1,2), X_num(idx==1,3), 'r.', 'MarkerSize',10)
plot(X_num(idx==2,2), X_num(idx==2,3), 'b.', 'MarkerSize',10)
plot(medoids(:,2), medoids(:,3), 'co', 'MarkerSize',12, 'LineWidth',2)
legend('Cluster 1','Cluster 2','Medoids','Location','best')
title('Cluster assignments and medoids')
xlabel('X2'); ylabel('X3')
hold off


%% ============================================================
%   MDS visualization (PCoA) using Mahalanobis distance
% ============================================================

D = pdist2(X_std, X_std, 'mahalanobis');
[Y, eigvals] = cmdscale(D);

PCo1 = Y(:,1);
PCo2 = Y(:,2);
PCo3 = Y(:,3);

med = Y(midx, :);

figure

% --------- (1) PCo1 vs PCo2 ---------
subplot(1,3,1); hold on
plot(PCo1(idx==1), PCo2(idx==1), 'r.', 'MarkerSize', 10)
plot(PCo1(idx==2), PCo2(idx==2), 'b.', 'MarkerSize', 10)
plot(med(:,1), med(:,2), 'co', 'MarkerSize', 12, 'LineWidth', 2)

title('K-medoids clustering in MDS space')
xlabel('PCo1'); ylabel('PCo2')
legend('Cluster 1','Cluster 2','Medoids','Location','best')
hold off


% --------- (2) PCo1 vs PCo3 ---------
subplot(1,3,2); hold on
plot(PCo1(idx==1), PCo3(idx==1), 'r.', 'MarkerSize', 10)
plot(PCo1(idx==2), PCo3(idx==2), 'b.', 'MarkerSize', 10)
plot(med(:,1), med(:,3), 'co', 'MarkerSize', 12, 'LineWidth', 2)

title('K-medoids clustering in MDS space')
xlabel('PCo1'); ylabel('PCo3')
legend('Cluster 1','Cluster 2','Medoids','Location','best')
hold off


% --------- (3) PCo2 vs PCo3 ---------
subplot(1,3,3); hold on
plot(PCo2(idx==1), PCo3(idx==1), 'r.', 'MarkerSize', 10)
plot(PCo2(idx==2), PCo3(idx==2), 'b.', 'MarkerSize', 10)
plot(med(:,2), med(:,3), 'co', 'MarkerSize', 12, 'LineWidth', 2)

title('K-medoids clustering in MDS space')
xlabel('PCo2'); ylabel('PCo3')
legend('Cluster 1','Cluster 2','Medoids','Location','best')
hold off

