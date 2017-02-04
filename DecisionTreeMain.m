%Part I, Loading Data
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

%Part II Construct trees
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
        
        if all(labelPred == 0) == 1 %No emotion is catagorized
            
        elseif MinimumLengthPrinciple == true 
            %Use minimum length principle if multiple labels has been 
            %catagorized from different trees
            for j = 1:numOfTrees
                if labelPred(j) == 0
                    levelOfDecision(j) = inf;
                end
            end
            predictions(eachRow) = min(level_labels,2);
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

function prediction = testEachTree(tree, row, layer)

end


