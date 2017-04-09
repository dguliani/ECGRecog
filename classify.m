clear all
close all 
clc

% get the data from the dataset and split labels and samples
dataset = csvread('features_wavelet_v2.csv');
labels = dataset(:,1);
featureset = dataset(:,2:size(dataset,2));
% featureset = featureset';
[coeff,score,latent,~,explained] = pca(featureset);
s = cumsum(explained);
num_components = 17; %length(find(s<99.999));

featureset = score(:,1:num_components);

% k = 50;
% estimate = score(:,1:num_components)*(coeffs(:,1:num_components)');
% plot(estimate.');

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

% Fitting a K Nearest Model 
tic;
knn_mdl = fitcknn(train_set,train_labels);
knn_time = toc; 

knn_train_class = predict(knn_mdl,train_set);
knn_test_class = predict(knn_mdl,test_set);

knn_train_accuracy = length(find(knn_train_class == train_labels))/length(train_labels); 
knn_test_accuracy = length(find(knn_test_class == test_labels))/length(test_labels); 

% Fitting SVM 
% tic;
% svm_mdl = fitcecoc(train_set,train_labels);
% svm_time = toc; 
% 
% svm_train_class = predict(svm_mdl,train_set);
% svm_test_class = predict(svm_mdl,test_set);
% 
% svm_train_accuracy = length(find(svm_train_class == train_labels))/length(train_labels); 
% svm_test_accuracy = length(find(svm_test_class == test_labels))/length(test_labels); 
