array = (1:45);
tree = DecisionTreeLearning(x, array, emotionY(:,3));

DrawDecisionTree(tree, 'something');