clear all
clc

% get the data from the dataset and split labels and samples
dataset = csvread('features_wavelet_v2.csv');
labels = dataset(:,1);
featureset = dataset(:,2:size(dataset,2));
% featureset = featureset';

% Breaking the data into 80:20 train:test sets
k = randperm(size(dataset,1));
train_size = int32(size(dataset,1)*0.8); 
test_size = size(dataset,1) - train_size; 

% train_set = featureset(1:train_size,:); 
% train_labels = labels(1:train_size);
% test_set = featureset(train_size+1:end,:); 
% test_labels = labels(train_size+1:end);

% Randomly selected train/test sets
train_set = featureset(k(1:train_size),:); 
train_labels = labels(k(1:train_size));
test_set = featureset(k(train_size+1:end),:); 
test_labels = labels(k(train_size+1:end));

% Fitting LDA model 
tic;
lda_mdl = fitcdiscr(train_set, train_labels); 
lda_time = toc; 

lda_train_class = predict(lda_mdl,train_set);
lda_test_class = predict(lda_mdl,test_set);

lda_train_accuracy = length(find(lda_train_class == train_labels))/length(train_labels); 
lda_test_accuracy = length(find(lda_test_class == test_labels))/length(test_labels); 

% Fitting QDA model:  did not work because one or more classes have
% singular covariance matrices
% tic;
% qda_mdl = fitcdiscr(train_set,train_labels,'DiscrimType','quadratic');
% 
% qda_time = toc; 
% qda_class = predict(qda_mdl,test_set);
% 
% qda_accuracy = length(find(qda_class == test_labels))/length(test_labels);

% Fitting a K Nearest Model 
tic;
knn_mdl = fitcknn(train_set,train_labels);
knn_time = toc; 

knn_train_class = predict(knn_mdl,train_set);
knn_test_class = predict(knn_mdl,test_set);

knn_train_accuracy = length(find(knn_train_class == train_labels))/length(train_labels); 
knn_test_accuracy = length(find(knn_test_class == test_labels))/length(test_labels); 

