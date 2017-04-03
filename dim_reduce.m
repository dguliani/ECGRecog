clear all
clc

% get the data from the dataset and split labels and samples
dataset = csvread('features.csv');
labels = dataset(:,1);
featureset = dataset(:,2:size(dataset,2));
featureset = featureset';

%% Principle Component Analysis
%http://ufldl.stanford.edu/wiki/index.php/Implementing_PCA/Whitening

% find the average across the rows
% this might be wrong, will need to investigate
avg = mean(featureset,1);
% zero the mean across the rows
featureset = featureset - repmat(avg, size(featureset,1), 1);

% find the standard deviation
sigma = featureset * featureset' / size(featureset,2);

% calculate the Single Value Decomp for the transformation
[U,S,V] = svd(sigma);

% rotate the matrix
xRot = U' * featureset;

% reduce the dimensionality to dimensionality k
k = 30;
xTilde = U(:,1:k)' * featureset;

% get some colours for the 2D component scatter plot
colour = labels/100;
colours = [colour colour-colour/2 colour/colour];

% transpose matrix to form a larger matrix
newX = xTilde';
% scatter plot
% from this scatter plot, we need to fit in elliptoids like she did to
% visualize. it still really doesn't look like hers though
scatter(newX(:,1), newX(:,2), 20,[colours(:,1) colours(:,2) colours(:,3)]);

figure; 
subplot(2,1,1); 
plot(featureset(:,1)); 
subplot(2,1,2); 
plot(xTilde(:,1)); 


