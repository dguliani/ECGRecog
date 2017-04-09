% Test of knn performance and the captured variance from PCA is measured
% from 1 component to n components, where n is the number of components it
% takes to capture 100% of the variance of the original data 
clear all
close all 
clc

% get the data from the dataset and split labels and samples
dataset = csvread('features_wavelet_v2.csv');
labels = dataset(:,1);
featureset = dataset(:,2:size(dataset,2));
% featureset = featureset';

[coeff,score,latent,~,explained] = pca(featureset);

s = round(cumsum(explained),3);
max_components = find(s==100.0000,1,'first');
% max_components = 250;

% Data
knn_time = []; 
variance = [];
knn_test_accuracy = [];
knn_train_accuracy = [];
num_components = [1:max_components]; 

for num_components = 1:max_components
    featureset = score(:,1:num_components);
    variance(num_components) = s(num_components);
    % Breaking the data into 80:20 train:test sets
%     rng default;
    k = randperm(size(dataset,1));
    train_size = int32(size(dataset,1)*0.8); 
    test_size = size(dataset,1) - train_size; 

    % Randomly selected train/test sets
    train_set = featureset(k(1:train_size),:); 
    train_labels = labels(k(1:train_size));
    test_set = featureset(k(train_size+1:end),:); 
    test_labels = labels(k(train_size+1:end));

    % Fitting a K Nearest Model 
    t = tic;
    knn_mdl = fitcknn(train_set,train_labels);
    knn_time(num_components) = toc(t); 

    knn_train_class = predict(knn_mdl,train_set);
    knn_test_class = predict(knn_mdl,test_set);

    knn_train_accuracy(num_components) = length(find(knn_train_class == train_labels))/length(train_labels); 
    knn_test_accuracy(num_components) = length(find(knn_test_class == test_labels))/length(test_labels); 
    
    num_components
end 
num_components = [1:max_components]; 

figure; 
ax1 = subplot(2,1,1); 
plot(num_components, knn_train_accuracy, 'r'); hold on; grid on; 
plot(num_components, knn_test_accuracy, 'b');
xlabel('Number of Principal Components'); 
ylabel('Accuracy (%)')
legend('Training Accuracy', 'Testing Accuracy'); 
title('Accuracy with Increasing Number of Principal Components','FontSize',14); 

% ax2 = subplot(3,1,2); 
% plot(num_components, knn_time, 'r'); hold on; grid on; 
% xlabel('Number of Principal Components'); 
% ylabel('Training Time (s)')
% title('Test Time with Increasing Number of Principal Components'); 

ax3 = subplot(2,1,2); 
plot(num_components, variance, 'r'); hold on; grid on; 
xlabel('Number of Principal Components'); 
ylabel('Variance Captured (%)')
title('Variance Captured with Increasing Number of Principal Components','FontSize',14); 
find(knn_test_accuracy == max(knn_test_accuracy))
max(knn_test_accuracy)
