clc, clear;
%     params.F = 0.5;
%     params.CR = 0.5;

domain = [zeros(30, 1) ones(30, 1)];
parDim = size(domain, 1);
jrandom = ceil(rand * parDim);
randomarray = rand(parDim, 1);
deselect = randomarray < 0.5;
~deselect;

lowend  = domain(:,1);
highend =domain(:,2);
sigma = (highend-lowend)./20;
x = rand(30, 1);
newparam = min(max(normrnd(x, sigma), lowend), highend);

x = rand(2,20);
y = rand(2,1);
x.*y;

indsize = 20;
idealpoint = rand(2,1);
idealpoint(:,ones(1, indsize))