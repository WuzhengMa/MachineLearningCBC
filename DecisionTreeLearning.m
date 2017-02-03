function tree = DecisionTreeLearning(examples, attributes, binary_targets)
%The input of this function is the testing data, where "examples" stands
%for training data, "attributes" indicates what each column of training data
%represents and "binary_targets" specifies the label of the training data
if all_binary_targets_same(binary_targets)
    tree = treeNode(NaN,{}, binary_targets(1));
    return;
elseif isempty(attributes)
    tree = treeNode(NaN,{}, mode(binary_targets));
    return;
else
    best_attribute_label = CHOOSE_BEST_DECISION_ATTRIBUTE(examples, attributes, binary_targets);
    tree = treeNode(best_attribute_label,{},NaN);
    possible_values = [0 1];
    for i = 1:length(possible_values)
        %find list of index of rows that have 0 and then next iteration 1
        %(:,a) means to extract column a from the matrix
        %find(b) function find the indices of array that has nonzero value
        index_list = find(examples(:,best_attribute_label) == possible_values(i));
        %find examples list for subtree
        %(a,:) extracts the rows that has value a
        kid_examples = examples(index_list,:);
        kid_attributes = attributes;
        %update the new list of remaining attribute
        kid_attributes(find(kid_attributes == best_attribute_label))=[];
        %create binary target for subtree
        kid_binary_targets = binary_targets(index_list);
        if isempty(kid_examples)
            tree = treeNode(NaN,{},mode(binary_targets));
            return;
        else
            kidtree = DecisionTreeLearning(kid_examples,kid_attributes,kid_binary_targets);
        end
        
        tree.kids{end+1} = kidtree;
    end
end
end

function allSame = all_binary_targets_same(binary_targets)
    if all(binary_targets) || all(binary_targets == 0)
        allSame = true;
    else
        allSame = false;
    end
end

function reseult =  entropy(pos, neg)
reseult = -(pos/(pos+neg))*log2(pos/(pos+neg) +eps)-(neg/(pos+neg))*log2(neg/(pos+neg)+eps);
end

function inf_gain = information_gain(examples, attributes,binary_targets)
    t_p = sum(binary_targets == 1);
    t_n = sum(binary_targets == 0);
    negative_targets = binary_targets(find(examples(:,attributes)== 0));
    positive_targets = binary_targets(find(examples(:,attributes)== 1));
    
    p_n = sum(negative_targets == 1);
    n_n = sum(negative_targets == 0);
    p_p = sum(positive_targets == 1);
    n_p = sum(positive_targets == 0);
    inf_gain = entropy(t_p,t_n)-(p_n+n_n)/(t_p+t_n)*entropy(p_n,n_n)-(p_p+n_p)/(t_p+t_n)*entropy(p_p,n_p);
end


function best_attribute_label = CHOOSE_BEST_DECISION_ATTRIBUTE(examples, attributes, binary_targets)
    inf_gain = zeros(length(attributes),1);
    for i = 1: length(inf_gain)
        inf_gain(i) = information_gain(examples, attributes(i),binary_targets);
    end
    [~,Id] = max(inf_gain);
    best_attribute_label = attributes(Id);
end