function output = evaluate(predictionsList, actualList)
    %predictionLength = length(predictionsList)/10;
    %plot total confusionmatrix
    x = reshape(predictionList, 1,[]);
    y = reshape(actualList, 1, []);
    [C, ~] = confusionmat(aList, pList);
    %now calculate PR, recall, class, f1 and confusionmatrix
    precision = calPR(C);
    recall = calRecall(C);
    output.cmatrix = C;
    output.precision = precision;
    output.recall = recall;
    output.f1 = calf1(precision, recall);
    output.classrate = calclassficationrate(x,y);
end


function precision = calPR(C)
    precision = zeros(1,6);
    for i=1:6
        TP = C(i,i);
        FP = sum(C(:,i)) - TP;
        precision(i) = TP/(TP + FP);
    end
end

function recall = calRecall(C)
    recall = zeros(1,6);
    for i=1:6
        TP = C(i,i);
        FN = sum(C(i,:)) - TP;
        recall(i) = TP/(TP + FN);
    end
end

function result = calf1(precision, recall)
    result = 2*((precision.*recall)./(precision+recall));
end

function result = calclassficationrate(C)
    result = sum(diag(C))/(sum(C(:)));
end

