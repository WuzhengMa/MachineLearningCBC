function[tree] = DecisionTreeLearning(examples, attributes, binary_targets)
%The input of this function is the testing data, where "examples" stands
%for training data, "attributes" indicates what each column of training data
%represents and "binary_targets" specifies the label of the training data

if all_binary_targets_same(binary_targets)
    tree = create_node(examples, attributes, binary_targets);
    return;
elseif attributes_empty
    tree = MAJORITY_VALUE(binary_targets);
    return;
else
    best_attribute_label = CHOOSE_BEST_DECISION_ATTRIBUTE(examples, attributes, binary_targets)
    tree = CreateTree(best_attribute_label,{},NaN)
    possible_values = [0 1];
    for i = 1:length(possible_values)
        %find list of index of rows that have 0 and then next iteration 1
        %(:,a) means to extract column a from the matrix
        %find(b) function find the indices of array that has nonzero value
        index_list = find(possible_values(i)==examples(:,best_attribute_label));
        %find examples list for subtree
        %(a,:) extracts the rows that has value a
        kid_examples = (index_list,:);
        kid_attributes = attributes;
        %update the new list of remaining attribute
        kid_attributes(best_attribute_label)=[];
        %create binary target for subtree
        kid_binary_targets(index_list);
        if isempty(kid_examples)
            tree = CreateTree(NaN,{},mode(kid_binary_targets));
            return;
        else
            kidtree = DecisionTreelearning(kid_examples,kid_attributes,kid_binary_targets);
        end
        
        tree.kids{end+1} = kidtree;
        tree.attribute_values{end+1} = possible_values(i);
    end
end
end

function allSame = all_binary_targets_same(all_binary_targets_same)
    if all(all_binary_targets_same) || all(all_binary_targets_same == 0)
        allSame = true;
    else
        allSame = false;
    end
end

