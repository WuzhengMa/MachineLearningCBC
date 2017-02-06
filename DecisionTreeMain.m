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
    emotionPredictions(:,fold) = testTrees(emotionTree(:,fold), test_data, false);   %Apply test data to the trees for each fold
end


%% Evaluate Result
for fold = 1:k
    emotionLabel(:,fold) = clean_y(test(C, fold), :);
end
EvaluationResults = evaluation(emotionPredictions, emotionLabel)   %Get the average evaluation results for all folds

