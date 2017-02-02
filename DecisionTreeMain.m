load cleandata_students.mat;
emotionY = zeros(1004,6);
for i = 1:6
    for j=1:length(y)
        if y(i) == i
            emotionY(j,i) = 1;
        else
            emotionY(j,i) = 0;
        end
    end
end


