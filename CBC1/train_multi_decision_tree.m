function [ trees ] = train_multi_decision_tree( x,y )
%TRAIN_MULTI_DECISION_TREE Summary of this function goes here
%   Detailed explanation goes here
trees =cell(1,6);
[n_row n_col]= size(x);
attributes =1:n_col;
for i=1:6
    new_y = remap_y(y,i);
    trees{i}=Decision_Tree_Learning(x,attributes,new_y);
end
end

