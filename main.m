clc;
clear all;
data_name = 'flare.data2';
data = load(data_name);
display(data_name)
fold_accuracy = NB_MRmD(data);
avg_acc = mean(fold_accuracy);
std_acc = std(fold_accuracy);