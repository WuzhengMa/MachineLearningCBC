classdef TreeNode
    %TREENODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        op = NaN;
        kids = {};
        attribute_values = {};
        class = NaN;
        
        
        index;
        X;
        Y;
    end
    
    methods
        function res = TreeNode(op1,kids1,class1,av)
            if nargin >0
               res.op = op1;
               res.kids = kids1;
               res.class = class1;
               res.attribute_values = av;
            end
            
        end
    end
    
end

