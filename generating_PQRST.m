clear all;
close all;
clc
%% Variable Definition
P_duration = 110; % ms
PR_duration = 40; % ms
QRS_duration = 100; % ms
ST_duration = 90; %ms
T_duration = 150; %ms
TP_duration = 250; %ms time in between T wave and P wave

sum = cumsum([P_duration PR_duration QRS_duration ST_duration T_duration TP_duration]);

num_samples = P_duration + PR_duration + QRS_duration + ST_duration + T_duration + TP_duration; %Total time in ms to complete one heatbeat 
ecgLeads = 0; %angle of lead I
repeat = 10; %Number of complexes
ECG = zeros(num_samples*repeat,1); %initializing ECG matrix
mean = 0;
std_dev = 0.1;

%% Wave building
% wave axis
PWave_axis = -55*pi/180;
QRS_axis = -45*pi/180;
T_axis = -45*pi/180;

%QRS cardiac loop
theta = linspace(0,2*pi,QRS_duration);
a = 4;
b = 1/3;
x = a*(cos(theta)-1).*cos(theta);
y = b*a*(cos(theta)-1).*sin(theta);

QRS_Loop_x = a*(cos(theta)-1).*cos(theta)*cos(QRS_axis) - b*a*(cos(theta)-1).*sin(theta)*sin(QRS_axis); 
QRS_Loop_y = a*(cos(theta)-1).*cos(theta)*sin(QRS_axis) + b*a*(cos(theta)-1).*sin(theta)*cos(QRS_axis);

%P cardiac loop
a_P = 1;
b_P = 1/3;
theta_p = linspace(pi,3*pi,P_duration);

x_P = a_P+a_P*cos(theta_p);
y_P = b_P*sin(theta_p);

P_Loop_x = a_P+a_P*cos(theta_p)*cos(PWave_axis) - b_P*sin(theta_p)*sin(PWave_axis)-(a_P-a_P*cos(PWave_axis));
P_Loop_y = a_P*cos(theta_p)*sin(PWave_axis)+b_P*sin(theta_p)*cos(PWave_axis)+a_P*sin(PWave_axis);

%T cardiac loop
a_T = 1.5;
b_T = 1/2;
theta_t = linspace(pi,3*pi,T_duration);

x_T = a_T+a_T*cos(theta_t);
y_T = b_T*sin(theta_t);

T_Loop_x = a_T+a_T*cos(theta_t)*cos(T_axis) - b_T*sin(theta_t)*sin(T_axis)-(a_T-a_T*cos(T_axis));
T_Loop_y = a_T*cos(theta_t)*sin(T_axis)+b_T*sin(theta_t)*cos(T_axis)+a_T*sin(T_axis);


%%
    
for i= 1:repeat

    ECG(1+((i-1)*num_samples):sum(1)+((i-1)*num_samples)) = P_Loop_x*cos(ecgLeads) - P_Loop_y*sin(ecgLeads); 
    ECG(sum(1)+1+((i-1)*num_samples):sum(2)+((i-1)*num_samples)) = zeros(PR_duration,1);
    ECG(sum(2)+1+((i-1)*num_samples):sum(3)+((i-1)*num_samples)) = QRS_Loop_x*cos(ecgLeads) - QRS_Loop_y*sin(ecgLeads);
    ECG(sum(3)+1+((i-1)*num_samples):sum(4)+((i-1)*num_samples)) = zeros(ST_duration,1);
    ECG(sum(4)+1+((i-1)*num_samples):sum(5)+((i-1)*num_samples)) = T_Loop_x*cos(ecgLeads) - T_Loop_y*sin(ecgLeads);
    ECG(sum(5)+1+((i-1)*num_samples):sum(6)+((i-1)*num_samples)) = zeros(TP_duration,1);
end

ECG = ECG + normrnd(mean, std_dev, num_samples*repeat,1); %adding noise to ECG recording

plot(ECG(:,1));
title('I');
xlabel('Sample Number');
ylabel('Voltage');
