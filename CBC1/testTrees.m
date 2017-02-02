function y = testTrees( T,x2,opt )
% y = testTrees( T,x2,opt ) takes your trained trees (all six) T and the 
%features x2 and produces a vector of label predictions y.
%parameter 'opt' determin the way of combining decision trees. if opt ==1 ,when more
%than one emotion is assigned to a test instance,the algorithm will always
%choose the emotion label that has the smallest depth in decision trees. if
%opt ~= 1, then the algorithm will randomly choose a emotion label when
%abiguity happens.
if nargin == 2
    opt = 1;
end

[n_row n_col]= size(x2);
y = zeros(n_row,1);

labels = zeros(length(T),1);
level_labels = zeros(length(T),1);

n_ambiguity=0;
n_allzero=0;
for i = 1:n_row
    
    
    
    for j = 1:length(T)
        [labels(j),level_labels(j)] = testTree(T{j},x2(i,:),1);
    end
    
    
    if(max(labels) == 0)
        
        %y(i) =r(1);
        
        y(i) = deal_with_all_zeros(T,x2(i,:));
        %y(i)=4;
        %fprintf('0000\n');
        %fprintf('r1: %d   ', r(1));
        n_allzero = n_allzero+1;
        
        %fprintf('y(i): %d \n', y(i));
        
    else
        if(opt == 1)
            for j = 1:length(labels)
                if labels(j) == 0
                    level_labels(j) = inf;
                end
            end
            [minlevel,minId] = min(level_labels);
            y(i) = minId;
            n_ambiguity =n_ambiguity+1;
        else
            [com,comLabels,com0]=intersect(labels,[0]);
            labels(comLabels) = [];
            r = randperm(length(labels));
            y(i) =r(1);
            n_ambiguity =n_ambiguity+1;
        end
    end
end

fprintf('ambiguity rate:%f , all zero rate: %f\n',n_ambiguity/n_row,n_allzero/n_row);
end


function y = deal_with_all_zeros(T,x)

r = randperm(length(T));
new_labels=[];
new_levels=[];
labels = zeros(length(T),1);
level_labels = zeros(length(T),1);
for i = 1:length(x)
    new_x =x;
    new_x(i) = bitxor(new_x(i),1);
    for k = 1:length(T)
        [labels(k),level_labels(k)] = testTree(T{k},new_x,1);
    end
    if(max(labels) == 0)
        continue;
    else
        for  j= 1:length(labels)
            if labels(j) == 0
                level_labels(j) = inf;
            end
        end
        [minlevel,minId] = min(level_labels);
        new_labels(end+1) = minId;
        new_levels(end+1) = minlevel;
    end
end

if( isempty(new_labels))
    y = r(1);
    fprintf('random: y = %d\n ',y);
else
    [minlevel,minId] = min(new_levels);
    y=new_labels(minId);
end


end


function [y,level] = testTree(tree,x, p_level)
%use DFS to search the decision tree for label.
    if ( isnan(tree.class) == 0 )
        y = tree.class;
        level = p_level;
        return
    else
        attribute = tree.op;
        values = tree.attribute_values;
        for i = 1: length(values)
           if x(attribute) == values{i}
               [y,level] = testTree(tree.kids{i},x,p_level+1);
               return
           end
        end
    end
end


