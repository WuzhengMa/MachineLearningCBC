%% Part I, Loading Data
load cleandata_students.mat;
clean_x = x;
clean_y = y;
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
C = cvpartition(zeros(1004, 1), 'KFold', k);  %perform KFold
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
emotionPredictions = zeros(101, 10);
for fold = 1:1
    test_data = clean_x(test(C, fold), :);
    %test_label = eachEmotionY(test(C, fold), :);
    test_size = size(test_data, 1);
    emotionPredictions(:,fold) = testTrees(emotionTree(:,fold), test_data);
end

MinimumLengthPrinciple = true;
function predictions = testTrees(T, x)
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
            %Repeat for all attributes and assign the label of the adjusted data for which the 
            %depth of the decision tree is minimal, to the test data. 
            currentRow = x(eachRow,:);
            adjustedDataLabels = zeros(1,size(currentRow));
            adjustedDataLevels = zeros(1,size(currentRow));

            for i = 1:size(currentRow)  %For each attributes within a test data
                adjustedRow = currentRow;
                adjustedRow(i) = bitxor(currentRow(i),1);   %Toggle the attribute
                
                %Perform test process on adjusted data
                for j = 1:numOfTrees
                    [labelPred(j),levelOfDecision(j)] = testTree(T{j},adjustedRow,1);
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
                    %according to minimum length principle
                    [minlevel,minId] = min(levelOfDecision);
                    adjustedDataLabels(i) = minId;
                    adjustedDataLevels(i) = minlevel;
                end
            end
            
            %Randomly assign a label for the test data if all adjusted data
            %return all zeros
            if all(adjustedDataLabels == 0) == 1
                predictions(eachRow) = randi(length(labelPred));
            else
                %Else return the label which the layer number is minimal
                predictions(eachRow) = adjustedDataLabels(min(adjustedDataLevels, 2));
            end
            
        elseif MinimumLengthPrinciple == true 
            %Use minimum length principle if multiple labels has been 
            %catagorized from different trees
            for j = 1:numOfTrees
                if labelPred(j) == 0
                    levelOfDecision(j) = inf;
                end
            end
            predictions(eachRow) = min(levelOfDecision,2);
        else
            %Or randomly assigned a label from multiple labels
            for j = 1:numOfTrees
                if labelPred(j) == 0
                    labelPred(comLabels) = [];
                end
            end
            predictions(eachRow) = randi(length(labelPred));
        end
    end
end

function [labelPred,levelOfDecision] = testEachTree(tree, row, layer)
    if isnan(tree.class) == 0
        labelPred = tree.class;
        levelOfDecision = p_level;
        return;
    else
        for i = 1:size(tree.op)
           if row(tree.op) == tree.attributeValue{i}
               [labelPred, levelOfDecision] = testEachTree(tree.kids{i}, row, layer+1);
               return
           end
        end
    end
end


