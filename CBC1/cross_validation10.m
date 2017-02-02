function [ output ] = cross_validation10( x,y, filename_data,...
    learning_function_handle, testing_function_handle)
%CROSS_VALIDATION Summary of this function goes here
%   Detailed explanation goes here
%profile on;
if exist(filename_data,'file')
    load(filename_data, 'xs_train','ys_train','xs_test','ys_test');
else
    [xs_train,ys_train,xs_test,ys_test] = make_cross_validation10_data(x,y);
    save(filename_data, 'xs_train','ys_train','xs_test','ys_test'); 
end

confusion_matrixs=cell(1,10);
res_matrix = zeros(6);
for i=1:10
    models = learning_function_handle(xs_train{i},ys_train{i});
    predicted_y = testing_function_handle(models, xs_test{i});
    confusion_matrixs{i} = construct_confusion_matrix(ys_test{i}, predicted_y);
    disp(confusion_matrixs{i});
    res_matrix = res_matrix+ confusion_matrixs{i};
end
output.matrix = round(res_matrix./10);
[output.precision,output.recall] = PRrates(output.matrix);
output.f1 = fa_measure(1,output.precision, output.recall);
output.rate = classification_rate(output.matrix);

%profile viewer;
end

function out = fa_measure(a,precision, recall)

out = (1+a)*(precision.*recall)./(a*precision+recall);

end


function out = classification_rate(confusion_matrix)

out = sum(diag(confusion_matrix))/(sum(sum(confusion_matrix)));

end

function [precision, recall] = PRrates(confusion_matrix)

precision = zeros(1,6);
recall = zeros(1,6);
for i=1:6
    % tp fn
    % fp tn
    matrix = zeros(2);
    matrix(1,1) = confusion_matrix(i,i);
    matrix(1,2) = sum(confusion_matrix(i,:)) - matrix(1,1);
    matrix(2,1) = sum(confusion_matrix(:,i)) - matrix(1,1);
    recall(i) = matrix(1,1)/(matrix(1,1) + matrix(1,2) +eps);
    precision(i) = matrix(1,1)/(matrix(1,1) + matrix(2,1) +eps);
end
end


function res_matrix = construct_confusion_matrix(true_y, predicted_y)

res_matrix = zeros(6);

for i=1:6
    true_y1 = (true_y == i);
    for j=1:6
        predicted_y1 = (predicted_y == j);
        res_matrix(i,j) = sum(true_y1 & predicted_y1);
    end
end

end


function [xs_train,ys_train,xs_test,ys_test] = make_cross_validation10_data(x,y)

xs_train = {};
ys_train = {};
xs_test = {};
ys_test = {};
for i=1:10
   [xs_train{i},ys_train{i},xs_test{i},ys_test{i}] = rand_partition10(x,y,i);
end
end

function  [x_train y_train x_test y_test] = rand_partition10(x,y,id)
[n_row n_col]= size(x);
rand_index =[];
if exist('rand_index.mat','file')
    load('rand_index.mat','rand_index');
    if length(rand_index) ~= n_row
        rand_index = randperm(n_row);
        save('rand_index.mat', 'rand_index');
    end
else
    rand_index = randperm(n_row);
    save('rand_index.mat', 'rand_index');
end
inteval = round(length(rand_index)./10) ;

id_start = 1+(id-1)*inteval;
id_end = min(id_start+inteval-1, length(rand_index));
test_ids = rand_index(id_start:id_end);

x_train = x;
y_train = y;
x_test = x(test_ids,:);
y_test = y(test_ids);
x_train(test_ids,:) = [];
y_train(test_ids) = [];


end