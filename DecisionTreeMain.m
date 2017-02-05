%% Part I, Loading Data
load cleandata_students.mat;
%Only 1000 data was used because 1004 is non-divisible by 10 in cross-validation
clean_x = x(1:1000,:);  
clean_y = y(1:1000,:);
load noisydata_students.mat;
noisy_x = x;
noisy_y = y;

[numRow, numCol] = size(clean_x);
emotionY = zeros(numRow,6);
for j=1:length(clean_y)
    emotionY(j,clean_y(j)) = 1;
end

%% Part II Training trees
k = 10;
emotionTree = cell(6,10);
C = cvpartition(zeros(1000, 1), 'KFold', k);  %perform KFold cross validation split
for i = 1:6
    eachEmotionY = emotionY(:,i);
    for fold = 1:1  
        training_data = clean_x(training(C, fold), :);
        training_label = eachEmotionY(training(C, fold), :);
        training_size = size(training_data, 1);
        emotionTree{i, fold} = DecisionTreeLearning(training_data, 1:numCol, training_label);    
    end
end

%% Testing trees
emotionPredictions = zeros(100, 10);    %predicted label
emotionLabel = zeros(100, 10);  %Actual label

for fold = 1:1
    test_data = clean_x(test(C, fold), :);
    emotionLabel = clean_y(test(C, fold), :);
    test_size = size(test_data, 1);
    emotionPredictions(:,fold) = testTrees(emotionTree(:,fold), test_data, false);   %Apply test data to the trees for each fold
end

function predictions = testTrees(T, x, MinimumLengthPrinciple)
    rows = size(x,1);
    numOfTrees = size(T,1);
    predictions = zeros(rows, 1);
    labelPred = zeros(1, numOfTrees);
    levelOfDecision = zeros(1, numOfTrees);
    
    for eachRow = 1:rows
        for i = 1:numOfTrees
            %Test each row with each emotion tree
            [labelPred(i),levelOfDecision(i)] = testEachTree(T{i},x(eachRow,:),1);
        end
        
        if all(labelPred == 0) == 1 
            %When no emotion is catagorized, adjust one attribute at a time and perform the test process.
            %This is based on Nearest Neiborgh Concept
            %Repeat for all attributes and assign the label of the adjusted data for which the 
            %depth of the decision tree is minimal, to the test data. 
            currentRow = x(eachRow,:);
            
            adjustedDataLabels = [];
            adjustedDataLevels = [];

            for i = 1:size(currentRow, 2)  %For each attributes within a test data
                adjustedRow = currentRow;
                adjustedRow(i) = bitxor(currentRow(i),1);   %Toggle the attribute
                
                %Perform test process on adjusted data
                for j = 1:numOfTrees
                    [labelPred(j),levelOfDecision(j)] = testEachTree(T{j},adjustedRow,1);
                end
                if all(labelPred == 0) == 1 %Continue if the adjusted Data still returns all zeros
                    continue;
                else
                    for j = 1:numOfTrees
                        if labelPred(j) == 0
                            levelOfDecision(j) = inf;
                        end
                    end
                    %Determine and store the label of each adjusted data
                    %according to minimum length principle (choose the label for which the depth of the tree is the smallest)
                    [minlevel,minId] = min(levelOfDecision);
                    adjustedDataLabels(end+1) = minId;
                    adjustedDataLevels(end+1) = minlevel;
                end
            end
            
            %Randomly assign a label for the test data if all adjusted data
            %still return all zeros
            if isempty(adjustedDataLabels)
                predictions(eachRow) = randi(length(labelPred));
            else
                %Else return the label which the depth of the tree is the
                %minimum
                [minlevel,minId] = min(adjustedDataLevels);
                predictions(eachRow) = adjustedDataLabels(minId);
            end
            
        elseif MinimumLengthPrinciple == true 
            %Use minimum length principle (choose the label for which the depth of the tree is the smallest)
            %if multiple labels has been catagorized from different trees     
            for j = 1:numOfTrees
                if labelPred(j) == 0
                    levelOfDecision(j) = inf;
                end
            end
            [minlevel,minId] = min(levelOfDecision);
            predictions(eachRow) = minId;
        else
            %Or randomly assigned a label from multiple labels
            j = 1;
            predIndex = 1:6;
            for i = 1:numOfTrees
                if labelPred(i) == 0
                    predIndex(j) = [];
                else
                    j = j + 1;
                end
            end
            predictions(eachRow) = predIndex(randi(length(predIndex)));
        end
    end
end

%Test each row of test data in certain emotion tree
function [labelPred,levelOfDecision] = testEachTree(tree, row, layer)
    if isnan(tree.class) == 0   %Leaf node
        labelPred = tree.class;
        levelOfDecision = layer;
        return;
    else
        %Go to kid branch according to it's attribute value 
       [labelPred, levelOfDecision] = testEachTree(tree.kids{row(tree.op)+1}, row, layer+1);
       return;
    end
end


