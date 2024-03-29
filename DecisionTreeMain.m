%% Part I, Loading Data
load cleandata_students.mat;
%load noisydata_students.mat;
%Only 1000 data was used because 1004 is non-divisible by 10 in cross-validation
clean_x = x(1:1000,:);  
clean_y = y(1:1000,:);

%% Store trained tree data
for j=1:length(y)
    tempY(j,y(j)) = 1;
end
for i = 1:6
    eachEmotionY = tempY(:,i);
    for fold = 1:1  
        training_data = x;
        training_label = eachEmotionY;
        training_size = size(training_data, 1);
        tempTree{i, fold} = DecisionTreeLearning(training_data, 1:45, training_label);    
    end
end

tree = tempTree(:,1);
save('trainedTrees.mat','tree');


%% Part II Training trees
[numRow, numCol] = size(clean_x);
emotionY = zeros(numRow,6);
for j=1:length(clean_y)
    emotionY(j,clean_y(j)) = 1;
end

k = 10;
emotionTree = cell(6,10);
C = cvpartition(zeros(1000, 1), 'KFold', k);  %perform KFold cross validation split
for i = 1:6
    eachEmotionY = emotionY(:,i);
    for fold = 1:k  
        training_data = clean_x(training(C, fold), :);
        training_label = eachEmotionY(training(C, fold), :);
        training_size = size(training_data, 1);
        emotionTree{i, fold} = DecisionTreeLearning(training_data, 1:numCol, training_label);    
    end
end

%% Testing trees
emotionPredictions = zeros(100, 10);    %predicted label
emotionLabel = zeros(100, 10);  %Actual label

for fold = 1:k
    test_data = clean_x(test(C, fold), :);
    test_size = size(test_data, 1);
    emotionPredictions(:,fold) = testTrees(emotionTree(:,fold), test_data, true);   %Apply test data to the trees for each fold
end


%% Evaluate Result
for fold = 1:k
    emotionLabel(:,fold) = clean_y(test(C, fold), :);
end
EvaluationResults = evaluation(emotionPredictions, emotionLabel)   %Get the average evaluation results for all folds
imagesc(EvaluationResults.cmatrix);
xlabel('Actual label');
ylabel('Predicted label');
title('Confusion Matrix');

