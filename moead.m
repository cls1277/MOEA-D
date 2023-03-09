function pareto = moead(mop, varargin)

    %MOEAD runs moea/d algorithms for the given mop.
    %   Detailed explanation goes here
    %   The mop must to be minimizing.
    %   The parameters of the algorithms can be set through varargin. including
    %   popsize: The subproblem's size.
    %   niche: the neighboursize, must less then the popsize.
    %   iteration: the total iteration of the moead algorithms before finish.
    %   method: the decomposition method, the value can be 'ws' or 'ts'.

    % 定义开始时间
    starttime = clock;
    % global variable definition.
    % 定义全局变量
    global params idealpoint objDim parDim itrCounter;
    % set the random generator.
    % 定义随机生成器
    rand('state', 10);

    %Set the algorithms parameters.
    % 定义算法的参数，将输入的参数通过init函数导入
    paramIn = varargin;
    [objDim, parDim, idealpoint, params, subproblems] = init(mop, paramIn);

    % 初始化循环编号
    itrCounter = 1;

    % 主循环
    while ~terminate(itrCounter)
        tic;
        subproblems = evolve(subproblems, mop, params);
%         disp(sprintf('iteration %u finished, time used: %u', itrCounter, toc));
        itrCounter = itrCounter + 1;
    end 

    %display the result.
    pareto = [subproblems.curpoint];
    pp = [pareto.objective];
%     scatter(pp(1, :), pp(2, :));
%     disp(sprintf('total time used %u', etime(clock, starttime)));
end 

function [objDim, parDim, idealp, params, subproblems] = init(mop, propertyArgIn)
    %Set up the initial setting for the MOEA/D.
    objDim = mop.od; % 获取目标的维度
    parDim = mop.pd; % 获取参数的维度
    idealp = ones(objDim, 1) * inf; % ?

    %the default values for the parameters.
    % 其他参数的默认值
    params.popsize = 100; params.niche = 30; params.iteration = 100;
    params.dmethod = 'ts';
    params.F = 0.5;
    params.CR = 0.5;

    % handle the parameters, mainly about the popsize
    % 处理输入的参数
    while length(propertyArgIn) >= 2
        prop = propertyArgIn{1}; 
        val = propertyArgIn{2}; 
        propertyArgIn = propertyArgIn(3:end);

        switch prop
        case 'popsize'
            % 种群规模
            params.popsize = val;
        case 'niche'
            %相邻种群规模
            params.niche = val;
        case 'iteration'
            % 迭代次数
            params.iteration = val;
        case 'method'
            % 方法
            params.dmethod = val;
        otherwise  
            warning('moea doesnot support the given parameters name');
        end 

    end 

    % 初始化权向量，将问题分解成多个单目标问题
    subproblems = init_weights(params.popsize, params.niche, objDim);
%     disp(subproblems(1));
    params.popsize = length(subproblems); %　这一句好像是多余的,把100变成了101
%     disp(subproblems(10).neighbour);

    %initial the subproblem's initital state.
    % 初始化初始点
    inds = randompoint(mop, params.popsize);
    
%     disp(size(inds));
    
%     disp(V{1,1});
%     disp(inds(1,1));

    %　对初始化的点进行评价，并且吧最优点保存在idealp中。
    %  之所以实现了“INDS是赋了objective值的inds”的功能，是因为匿名函数evaluate的返回值就是两个值啊
    [V, INDS] = arrayfun(@evaluate, repmat(mop, size(inds)), inds, 'UniformOutput', 0);
    
%     disp(V{1,1});
%     disp(INDS{1,1});
    
    v = cell2mat(V);
%     disp(v);
    idealp = min(idealp, min(v, [], 2));
    
%     disp(idealp);

    %indcells = mat2cell(INDS, 1, ones(1,params.popsize));
    [subproblems.curpoint] = INDS{:};
%     disp(subproblems(1));
    clear inds INDS V indcells;
end 

function subproblems = evolve(subproblems, mop, params)
    global idealpoint;

    for i = 1:length(subproblems)
        %new point generation using genetic operations, and evaluate it.
        ind = genetic_op(subproblems, i, mop.domain, params);
%         disp(ind);
%         ind的30个参数是差分进化生成的 objective是下面求得的
        [obj, ind] = evaluate(mop, ind);
%         disp(ind);
        %update the idealpoint.
        idealpoint = min(idealpoint, obj);

        %update the neighbours.
        neighbourindex = subproblems(i).neighbour;
        subproblems(neighbourindex) = update(subproblems(neighbourindex), ind, idealpoint);
        %clear ind obj neighbourindex neighbours;

        clear ind obj neighbourindex;
    end 

end 

function subp = update(subp, ind, idealpoint)
%     在差分进化之后更新一下邻居
%     ind是一个新的解向量
%     调用方式：subproblems(neighbourindex) = update(subproblems(neighbourindex), ind, idealpoint);
    global params

%     subp是一行二十列的矩阵，所以后面的.weight就是的2×20的
%     disp(size(subp));
%     理解为：当用新的ind替换掉邻域20个邻居之后，如果更好，就交换。
    newobj = subobjective([subp.weight], ind.objective, idealpoint, params.dmethod);
    oops = [subp.curpoint];
%     disp(size(oops));
    oldobj = subobjective([subp.weight], [oops.objective], idealpoint, params.dmethod);

    C = newobj < oldobj;
    [subp(C).curpoint] = deal(ind);
    clear C newobj oops oldobj;
end 

function y = terminate(itrcounter)
    global params;
    y = itrcounter > params.iteration;
end 
