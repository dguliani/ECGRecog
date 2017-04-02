clear all
clc

% get the data from the dataset and split labels and samples
dataset = csvread('features.csv');
labels = dataset(:,1);
featureset = dataset(:,2:size(dataset,2));
% featureset = featureset';

% Breaking the data into 80:20 train:test sets
k = randperm(size(dataset,1));
train_size = int32(size(dataset,1)*0.8); 
test_size = size(dataset,1) - train_size; 

train_set = featureset(k(1:train_size),:); 
train_labels = labels(k(1:train_size));
test_set = featureset(k(train_size+1:end),:); 
test_labels = labels(k(train_size+1:end));

% Fitting LDA model 
Mdl = fitcdiscr(train_set, train_labels); 
class = predict(Mdl,test_set);

lda_accuracy = length(find(class == test_labels))/length(test_labels); 

% Fitting a K Nearest Model 

% Mdl = fitcdiscr(featureset, labels,'KFold',5)
