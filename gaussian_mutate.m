function ind = gaussian_mutate( ind, prob, domain)
% 调用格式：gaussian_mutate(ind, 1 / parDim（参数的个数30）, domain)
%GAUSSIAN_MUTATE Summary of this function goes here
%   Detailed explanation goes here

if isstruct(ind)
    x = ind.parameter;
else
    x  = ind;
end

   parDim = length(x);
   lowend  = domain(:,1);
   highend =domain(:,2);
   sigma = (highend-lowend)./20;
   %    高斯变异为什么要除20？
   
%    产生高斯概率分布的矩阵，并限制在定义域内
   newparam = min(max(normrnd(x, sigma), lowend), highend);
%    这个条件其实并不想很多位置都实现高斯变异
   C = rand(parDim, 1)<prob;
%    disp(C);
   x(C) = newparam(C);
   
if isstruct(ind)
    ind.parameter = x;
else
    ind = x;
end
    