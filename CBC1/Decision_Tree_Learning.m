function [ tree ] = Decision_Tree_Learning( examples, attributes, binary_targets )
%DECISION-TREE-LEARNING(examples,attributes,binary_targets) returns a 
%decision tree for a given target label. a matrix of examples, 
%where each row is one example and each column is one attribute, 
%a row vector of attributes, and the target vector which contains 
%the binary targets.
if the_same_binary_targets(binary_targets)
    tree = TreeNode(NaN,{},binary_targets(1),{});
    return;   
elseif isempty(attributes)
    tree = TreeNode(NaN,{},mode(binary_targets),{});
    return ;   
else
    best_attribute = choose_best_attribute(examples, attributes, binary_targets);
    tree = TreeNode(best_attribute,{},NaN,{});
    values_best_attribute = [0 1];
    for i = 1:length(values_best_attribute)    
        
        t = (examples(:,best_attribute) == values_best_attribute(i));  
        new_idx = find(t);
        new_examples = examples(new_idx,:);
        new_targets = binary_targets(new_idx);   
        new_attributes = attributes;
        new_attributes(find(new_attributes == best_attribute)) = [];
        
        if isempty(new_examples)
            tree = TreeNode(NaN,{},mode(binary_targets),{});
            return;
        else
            subtree = Decision_Tree_Learning(new_examples,new_attributes, new_targets);
        end
        tree.kids{end+1} = subtree;
        tree.attribute_values{end+1} = values_best_attribute(i);
    end
    
end
end

function res = choose_best_attribute(examples, attributes, binary_targets)
ig = zeros(length(attributes),1);
for i = 1: length(attributes)
    ig(i) = information_gain(examples, attributes(i),binary_targets);
end
[maxV,maxId] = max(ig);
res = attributes(maxId);
end

function res =  information_entropy(positive, negative)
res =  -(positive/(positive+negative) )*log2(positive/(positive+negative) +eps)...
    - (negative/(positive+negative) )*log2(negative/(positive+negative) +eps);
end

function res = information_gain(examples, one_attribute, binary_targets)
p = sum(binary_targets == 1);
n = sum(binary_targets == 0);

t0 = (examples(:,one_attribute)== 0);
idx_remainder0 = find(t0);
t1 = (examples(:,one_attribute)== 1);

idx_remainder1 = find(t1);
new_targets0 = binary_targets(idx_remainder0);
new_targets1 = binary_targets(idx_remainder1);
p0 = sum(new_targets0 == 1);
n0 = sum(new_targets0 == 0);
p1 = sum(new_targets1 == 1);
n1 = sum(new_targets1 == 0);
res = information_entropy(p,n) - (p0+n0)/(p+n) *information_entropy(p0,n0)...
       - (p1+n1)/(p+n)*information_entropy(p1,n1);
end

function res = the_same_binary_targets(binary_targets)
res = 0;
if all(binary_targets == 1)
    res = 1;
    return ;
elseif all(binary_targets == 0) 
    res = 1;
    return;
end
end