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
for i = 6:6
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


function predictions = testTrees(T, x)
    
end


