function y = remap_y(y, selected)
% y = remap_y(y, selected)  remap a muti-labeled vector 'y' into binary label by only using one selected
% atribute  'selected'. For example, if 'selected' == 3, all numbers in y
% with value 3 will be setted to 1, otherwise setted to 0.

for i=1:length(y)
    if y(i) == selected
        y(i) = 1;
    else
        y(i) = 0;
    end
end
 
end