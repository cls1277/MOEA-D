function obj = subobjective(weight, ind, idealpoint, method)
%SUBOBJECTIVE function evaluate a point's objective with a given method of
%decomposition. 

%   Two method are implemented by far is Weighted-Sum and Tchebesheff.
%   weight: is the decomposition weight.(column wise vector).
%   ind: is the individual point(column wise vector).
%   idealpoint: the idealpoint for Tchebesheff decomposition.
%   method: is the decomposition method, the default is 'te' when is
%   omitted.
%   
%   weight and ind can also be matrix. in which have two scenairos:
%   When weight is a matrix, then it's treated as a column wise set of
%   weights. in that case, if ind is a size 1 column vector, then the
%   subobjective is computed with every weight and the ind; if ind is also
%   a matrix of the same size as weight, then the subobjective is computed
%   in a column-to-column, with each column of weight computed against the
%   corresponding column of ind. 
%   A row vector of subobjective is return in both case.

    if (nargin==2)
        obj = ws(weight, ind);
    elseif (nargin==3)
        obj = te(weight, ind, idealpoint);
    else
        if strcmp(method, 'ws')
            obj=ws(weight, ind);
        elseif strcmp(method, 'te')
            obj=te(weight, ind, idealpoint);
        else
            obj= te(weight, ind, idealpoint);
        end
    end
end

% 以下判断if其实就是为了两种情况：只传进一个MOP值，传进neighbor size个MOP值
% 对两种情况，分别计算ws和ts，前者为复制neighbot size份之后再计算
% 得到的结果进行比较，前者为newobj，后者为oldobj

function obj = ws(weight, ind)
%     weight是2×20的矩阵
%     disp(size(weight));
% disp(size(weight));
%     disp(size(ind));
%     理解为：当用新的ind替换掉邻域20个邻居之后，如果更好，就交换。
    if size(ind, 2) == 1 
       obj = (weight'*ind)';
    else
       obj = sum(weight.*ind);
    end
end

function obj = te(weight, ind, idealpoint)
%     ind是2乘1的，weight是2乘20的
    s = size(weight, 2); % 邻居的个数20
    indsize = size(ind,2); % indsize = 1
%     disp(indsize);
    weight((weight == 0))=0.00001;
    
    if indsize==s 
%         disp(size(idealpoint));
%         disp(size(idealpoint(:,ones(1, indsize))));
%         disp(size(ind));
%         disp(size(weight));
        part2 = abs(ind-idealpoint(:,ones(1, indsize)));
        obj = max(weight.*part2);
    elseif indsize ==1
%         disp(size(ind));
        part2 = abs(ind-idealpoint);
        obj = max(weight.*part2(:,ones(1, s)));   
    else
        error('individual size must be same as weight size, or equals 1');
    end
end