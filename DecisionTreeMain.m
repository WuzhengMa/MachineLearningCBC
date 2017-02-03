load cleandata_students.mat;
%Part I, Loading Data
[numRow, numCol] = size(x);
emotionY = zeros(numRow,6);
for j=1:length(y)
    emotionY(j,y(j)) = 1;
end

%Construct trees
emotionTree = cell(1,6);
for i=1:6
    emotionTree{i} = DecisionTreeLearning(x, 1:numCol, emotionY(:,i));
end



