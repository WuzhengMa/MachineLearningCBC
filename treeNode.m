classdef treeNode
    %TREENODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        op = NaN;
        kids = {};
        class = NaN;    
        index;
        X;
        Y;
    end
    
    methods
        function res = treeNode(new_op,new_kids,new_class)
            if nargin >0
               res.op = new_op;
               res.kids = new_kids;
               res.class = new_class;
            end
        end
    end
end
