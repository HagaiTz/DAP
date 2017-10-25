%%%%%%%
function analyzeGroups(folder,depth)

    % Get home directory:
    var = getenv('HOME');

    % Add modules to MATLAB. Do not change the order of these programs:
    fsldir=getenv('FSLDIR');
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    fsllibdir=sprintf('%s/%s', fsldir, 'bin');
    ldlibpath=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH',fsllibdir);

    addpath(genpath(fullfile(var,'Neuro_Analysis')));
    
    % set environment
    text('Interpreter','none');
    global AnalysisFold;
    AnalysisFold = 'Analysis';

    % Check groups
    if (depth == 3), flag = true;
    else, flag = false; end
    
    allTracts = struct('groupName',[],'tractsProp',[],'tractsAvg',[],'tractsName',[],...
        'total',[]);

    % Analyze groups
    if (~flag), allTracts = groupStats(folder,allTracts);
    else
        groups = dir(folder); groups = groups(3:end);
        for ii = 1:length(groups)
            if(strcmp(groups(ii).name,AnalysisFold)), continue; end
            groupFold = fullfile(folder,groups(ii).name);
            allTracts = groupStats(groupFold,allTracts);
        end
        allTracts = totalStats(allTracts);
        writeStats(allTracts.total,fullfile(folder,'Analysis'),allTracts.tractsName');
        plotAll(allTracts,fullfile(folder,'Analysis'));
    end
    
    

    save(fullfile(folder,'Analysis','TractsData.mat'),'allTracts');
    exit;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Calculate all statistics
function allTracts = totalStats(allTracts)
    num = 0;
    for kk = 1:length(allTract.tractsName) 
        allTracts.total.mean.fa{kk} = zeros(1,100);
        allTracts.total.mean.md{kk} = zeros(1,100);
        allTracts.total.mean.rd{kk} = zeros(1,100);
        allTracts.total.mean.ad{kk} = zeros(1,100);
        allTracts.total.mean.cl{kk} = zeros(1,100);
        allTracts.total.std.fa{kk} = zeros(1,100);
        allTracts.total.std.md{kk} = zeros(1,100);
        allTracts.total.std.rd{kk} = zeros(1,100);
        allTracts.total.std.ad{kk} = zeros(1,100);
        allTracts.total.std.cl{kk} = zeros(1,100);
    end
    for ii = 1:length(allTracts.groupName)
        for jj = 1:size(allTracts.tractsProp(ii).fa,1)
            for kk = 1:length(allTract.tractsName) 
                allTracts.total.mean.fa{kk} = allTracts.total.mean.fa{kk} + ...
                    allTracts.tractsProp(ii).fa{jj,kk};
                allTracts.total.mean.md{kk} = allTracts.total.mean.md{kk} + ...
                    allTracts.tractsProp(ii).md{jj,kk};
                allTracts.total.mean.rd{kk} = allTracts.total.mean.rd{kk} + ...
                    allTracts.tractsProp(ii).rd{jj,kk};
                allTracts.total.mean.ad{kk} = allTracts.total.mean.ad{kk} + ...
                    allTracts.tractsProp(ii).ad{jj,kk};
                allTracts.total.mean.cl{kk} = allTracts.total.mean.cl{kk} + ...
                    allTracts.tractsProp(ii).cl{jj,kk};
            end
            num = num + 1;
        end
    end
    allTracts.total.mean.fa{kk} = allTracts.total.mean.fa{kk}/num;
    allTracts.total.mean.md{kk} = allTracts.total.mean.md{kk}/num;
    allTracts.total.mean.rd{kk} = allTracts.total.mean.rd{kk}/num;
    allTracts.total.mean.ad{kk} = allTracts.total.mean.ad{kk}/num;
    allTracts.total.mean.cl{kk} = allTracts.total.mean.cl{kk}/num;

    for ii = 1:length(allTracts.groupName)
        for jj = 1:size(allTracts.tractsProp(ii).fa,1)
            for kk = 1:length(allTract.tractsName) 
                allTracts.total.std.fa{kk} = allTracts.total.std.fa{kk} + ...
                    (allTracts.tractsProp(ii).fa{jj,kk} - allTracts.total.mean.fa{kk}).^2;
                allTracts.total.mean.md{kk} = allTracts.total.std.md{kk} + ...
                    (allTracts.tractsProp(ii).md{jj,kk} - allTracts.total.mean.md{kk}).^2;
                allTracts.total.mean.rd{kk} = allTracts.total.std.rd{kk} + ...
                    (allTracts.tractsProp(ii).rd{jj,kk} - allTracts.total.mean.rd{kk}).^2;
                allTracts.total.mean.ad{kk} = allTracts.total.std.ad{kk} + ...
                    (allTracts.tractsProp(ii).ad{jj,kk} - allTracts.total.mean.ad{kk}).^2;
                allTracts.total.mean.cl{kk} = allTracts.total.std.cl{kk} + ...
                    (allTracts.tractsProp(ii).cl{jj,kk} - allTracts.total.mean.cl{kk}).^2;
            end
        end
    end
    num = num - 1;
    allTracts.total.std.fa{kk} = sqrt(allTracts.total.std.fa{kk}/num);
    allTracts.total.std.md{kk} = sqrt(allTracts.total.std.md{kk}/num);
    allTracts.total.std.rd{kk} = sqrt(allTracts.total.std.rd{kk}/num);
    allTracts.total.std.ad{kk} = sqrt(allTracts.total.std.ad{kk}/num);
    allTracts.total.std.cl{kk} = sqrt(allTracts.total.std.cl{kk}/num);
end

%% Calculate group statistics
function aT = groupStats(group,aT)
    global AnalysisFold;
    subj = dir(group); subj = subj(3:end);
    groupTract = struct('fa',[],'md',[],'rd',[],'ad',[],'cl',[]);
    fiberFlag = true;
    for ii = 1:length(subj)
        if(strcmp(subj(ii).name,AnalysisFold)), continue; end
        load(fullfile(group,subj(ii).name,'dti','AFQ.mat'));
        groupTract.fa = [groupTract.fa ; afq.vals.fa];
        groupTract.md = [groupTract.md ; afq.vals.md];
        groupTract.rd = [groupTract.rd ; afq.vals.rd];
        groupTract.ad = [groupTract.ad ; afq.vals.ad];
        groupTract.cl = [groupTract.cl ; afq.vals.cl];
        if (fiberFlag)
            fg = loadFibers(fullfile(group,subj(ii).name),afq.fgnames);
            b0 = readFileNifti(fullfile(group,subj(ii).name,'dti','bin','b0.nii.gz'));
            fiberFlag = false;
        end
    end

    groupAvg = calcAvg(groupTract);
    writeTracts(groupTract,groupAvg,subj,afq.fgnames,fullfile(group,AnalysisFold));
    writeStats(groupAvg,fullfile(group,AnalysisFold),afq.fgnames,fg,afq.TractProfiles,b0);
    [~,gName] = fileparts(group);
    aT.groupName = [aT.groupName ; {gName}];
    aT.tractsProp = [aT.tractsProp ; groupTract];
    if (isempty(aT.tractsAvg)), aT.tractsAvg = groupAvg; 
    else, aT.tractsAvg = insertProp(aT.tractsAvg, groupAvg); end
    if (isempty(aT.tractsName)), aT.tractsName = afq.fgnames'; end
    
end

%% Calculate group Average
function avg = calcAvg(groupTract)
    avg = struct('mean',[],'std',[]);
    avg.mean = struct('fa',[],'md',[],'rd',[],'ad',[],'cl',[]);
    avg.std = struct('fa',[],'md',[],'rd',[],'ad',[],'cl',[]);
    for ii = 1:size(groupTract.fa,2)
        avg.mean.fa = [avg.mean.fa , {nanmean(cell2mat(groupTract.fa(:,ii)),1)}];
        avg.std.fa = [avg.std.fa , {nanstd(cell2mat(groupTract.fa(:,ii)),1)}];
        avg.mean.md = [avg.mean.md , {nanmean(cell2mat(groupTract.md(:,ii)),1)}];
        avg.std.md = [avg.std.md , {nanstd(cell2mat(groupTract.md(:,ii)),1)}];
        avg.mean.rd = [avg.mean.rd , {nanmean(cell2mat(groupTract.rd(:,ii)),1)}];
        avg.std.rd = [avg.std.rd , {nanstd(cell2mat(groupTract.rd(:,ii)),1)}];
        avg.mean.ad = [avg.mean.ad , {nanmean(cell2mat(groupTract.ad(:,ii)),1)}];
        avg.std.ad = [avg.std.ad , {nanstd(cell2mat(groupTract.ad(:,ii)),1)}];
        avg.mean.cl = [avg.mean.cl , {nanmean(cell2mat(groupTract.cl(:,ii)),1)}];
        avg.std.cl = [avg.std.cl , {nanstd(cell2mat(groupTract.cl(:,ii)),1)}];
    end
end

%% Load loadFibers
function fg = loadFibers(subj,names)
    fiberFold = fullfile(subj,'dti','fibers');
    fg = dtiReadFibers(fullfile(fiberFold,'MoriGroups_clean_D5_L4.mat'));
    for ii = 21:28
        fg = [fg, dtiReadFibers(fullfile(fiberFold,[names{ii} '_clean_D5_L4.mat']))];
    end
end

%% Write group statistics
function writeStats(groupAvg,fileP,names,fg,tractProfile,b0)
    if (~exist(fileP)), mkdir(fileP); end

    for ii = 1:length(names)
        fa_mean = groupAvg.mean.fa{ii}';
        md_mean = groupAvg.mean.md{ii}';
        rd_mean = groupAvg.mean.rd{ii}';
        ad_mean = groupAvg.mean.ad{ii}';
        cl_mean = groupAvg.mean.cl{ii}';
        fa_std = groupAvg.std.fa{ii}';
        md_std = groupAvg.std.md{ii}';
        rd_std = groupAvg.std.rd{ii}';
        ad_std = groupAvg.std.ad{ii}';
        cl_std = groupAvg.std.cl{ii}';
    
        tractProfile(ii).vals.fa = fa_mean;
        tractProfile(ii).vals.md = md_mean;
        tractProfile(ii).vals.rd = rd_mean;
        tractProfile(ii).vals.ad = ad_mean;
        tractProfile(ii).vals.cl = cl_mean;
        
        localP = fullfile(fileP,names{ii});
        if (~exist(localP)), mkdir(localP); end

        f = figure('visible','off');
        ax = gca(f);
        hold(ax,'on');
        set(ax,'ColorOrder',jet(5));
        plot(ax,[fa_mean , md_mean , rd_mean , ad_mean , cl_mean],'linewidth',2);
        obj = xlabel('Node','fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = title([names{ii} ' - Profile'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        legend({'FA','MD','RD','AD','CL'});
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(localP,[names{ii} '_Profile.png'])); 
        hold(ax,'off'); clear f;
        
        f = figure('visible','off');
        ax = gca(f); plotProp(ax,fa_mean,fa_std,'FA Profile');
        saveas(f,fullfile(localP,[names{ii} '_FA_Graph.png'])); 
        clear f; f = figure('visible','off'); 

        ax = gca(f); plotProp(ax,md_mean,md_std,'MD Profile');
        saveas(f,fullfile(localP,[names{ii} '_MD_Graph.png']));
        clear f; f = figure('visible','off');

        ax = gca(f); plotProp(ax,rd_mean,rd_std,'RD Profile');
        saveas(f,fullfile(localP,[names{ii} '_RD_Graph.png']));
        clear f; f = figure('visible','off');

        ax = gca(f); plotProp(ax,ad_mean,ad_std,'AD Profile');
        saveas(f,fullfile(localP,[names{ii} '_AD_Graph.png']));
        clear f; f = figure('visible','off');

        ax = gca(f); plotProp(ax,cl_mean,cl_std,'CL Profile');
        saveas(gcf,fullfile(localP,[names{ii} '_CL_Graph.png']));
        clear f; 
        
        if (nargin > 3)
            res = '-r100'; forma = '-dpng'; numfib = 100;
            AFQ_RenderFibers(fg(ii),'color',[0 0 1],'numfibers',numfib);
            AFQ_AddImageTo3dPlot(b0,[-2, 0, 0]);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            %saveas(gcf,fullfile(localP,[names{ii} '_Tract.png'])); clear gcf;
            print(gcf,fullfile(localP,[names{ii} '_Tract']),forma,res);
            close gcf; clear gcf;

            %range = [min(fa_mean)*0.9 1.1*max(fa_mean)];
            %AFQ_RenderFibers(fg(ii),'tractprofile',tractProfile(ii),'val',['fa'],...,
            %    'crange',range,'numfibers',numfib);
            %saveas(gcf,fullfile(localP,[names{ii} '_FA_Tract.png'])); clear gcf;
            plotTractParams(fg(ii),fa_mean);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            if (contains(names{ii},'CC')||contains(names{ii},'Callosum'))
                view(180,0); lightangle(180,45); end
            print(gcf,fullfile(localP,[names{ii} '_FA_Tract']),forma,res);
            close gcf; clear gcf;
            
            %range = [min(md_mean)*0.9 1.1*max(md_mean)];
            %AFQ_RenderFibers(fg(ii),'tractprofile',tractProfile(ii),'val',['md'],...
            %    'crange',range,'numfibers',numfib); 
            %saveas(gcf,fullfile(localP,[names{ii} '_MD_Tract.png'])); clear gcf;
            plotTractParams(fg(ii),md_mean);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            if (contains(names{ii},'CC')||contains(names{ii},'Callosum'))
                view(180,0); lightangle(180,45); end
            print(gcf,fullfile(localP,[names{ii} '_MD_Tract']),forma,res);
            close gcf; clear gcf;
            
            %range = [min(rd_mean)*0.9 1.1*max(rd_mean)];
            %AFQ_RenderFibers(fg(ii),'tractprofile',tractProfile(ii),'val',['rd'],...
            %    'crange',range,'numfibers',numfib); 
            %saveas(gcf,fullfile(localP,[names{ii} '_RD_Tract.png'])); clear gcf;
            plotTractParams(fg(ii),rd_mean);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            if (contains(names{ii},'CC')||contains(names{ii},'Callosum'))
                view(180,0); lightangle(180,45); end
            print(gcf,fullfile(localP,[names{ii} '_RD_Tract']),forma,res);
            close gcf; clear gcf;
            
            %range = [min(ad_mean)*0.9 1.1*max(ad_mean)];
            %AFQ_RenderFibers(fg(ii),'tractprofile',tractProfile(ii),'val',['ad'],...
            %    'crange',range,'numfibers',numfib); 
            %saveas(gcf,fullfile(localP,[names{ii} '_AD_Tract.png'])); clear gcf;
            plotTractParams(fg(ii),ad_mean);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            if (contains(names{ii},'CC')||contains(names{ii},'Callosum'))
                view(180,0); lightangle(180,45); end
            print(gcf,fullfile(localP,[names{ii} '_AD_Tract']),forma,res);
            close gcf; clear gcf;
            
            %range = [min(cl_mean)*0.9 1.1*max(cl_mean)];
            %AFQ_RenderFibers(fg(ii),'tractprofile',tractProfile(ii),'val',['cl'],...
            %    'crange',range,'numfibers',numfib);
            %saveas(gcf,fullfile(localP,[names{ii} '_CL_Tract.png'])); clear gcf;
            plotTractParams(fg(ii),cl_mean);
            if (contains(names{ii},'Right')), view(90,0); lightangle(90,45); end
            if (contains(names{ii},'CC')||contains(names{ii},'Callosum'))
                view(180,0); lightangle(180,45); end
            print(gcf,fullfile(localP,[names{ii} '_CL_Tract']),forma,res);
            close gcf; clear gcf;
        end
    end

end
 
%% Plot properties
function plotProp(ax,mean,std,name)
    cutZ = norminv([10 90]*0.01);
    cutZ2 = norminv([.25 .75]);
    numNodes = 100;
    hold on;
    x = [1:numNodes fliplr(1:numNodes)];
    y = vertcat(mean+max(cutZ)*std, flipud(mean+min(cutZ)*std));
    fill(ax,x,y, [.6 .6 .6]); clear y;
    y = vertcat(mean+max(cutZ2)*std, flipud(mean+min(cutZ2)*std));
    fill(ax,x,y, [.3 .3 .3]); clear y;
    x = [1:100]';
    z = zeros(size(x));
    surface([x,x],[mean,mean],[z,z],[mean,mean],...
    'facecol','no','edgecol','interp','linew',8);

    %plot(ax,fa_mean,'-','Color','k','LineWidth',2);
    axis([1 numNodes -0.1 max(0.9,max(mean)+0.4)]);
    xlabel('Location','fontName','Times','fontSize',14); 
    ylabel('Fractional Anisotropy','fontName','Times','fontSize',14); 
    obj = title([name ' - Profile'],'fontName','Times','fontSize',14); 
    set(obj,'Interpreter', 'none');
    set(gcf,'Color','w');
    set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
    hold off;
end

%% Write Tables
function writeTracts(groupTracts,groupAvg,subj,fgnames,fold)

    names = [];
    for ii = 1:length(subj)
        if (strcmp(subj(ii).name,'Analysis')), continue; end
        names = [names , {subj(ii).name}];
    end
    names = [names, {'Average'}, {'Std'}];
    nodes = num2cell(1:100);
    nodes = [{'Node\Subj'}; nodes'];
    for ii = 1:length(fgnames)
         if (~exist(fullfile(fold,fgnames{ii}))), mkdir(fullfile(fold,fgnames{ii})); end
        tmp = cell2mat(groupTracts.fa(:,ii));
        tmp = [tmp; groupAvg.mean.fa{ii}];
        tmp = [tmp; groupAvg.std.fa{ii}];
        tmp = num2cell(tmp');
        tmp = vertcat(names,tmp);
        tmp = [nodes, tmp];
        cell2csv(fullfile(fold,fgnames{ii},[fgnames{ii} '_FA.csv']),tmp);
        
        tmp = cell2mat(groupTracts.md(:,ii));
        tmp = [tmp; groupAvg.mean.md{ii}];
        tmp = [tmp; groupAvg.std.md{ii}];
        tmp = num2cell(tmp');
        tmp = vertcat(names,tmp);
        tmp = [nodes, tmp];
        cell2csv(fullfile(fold,fgnames{ii},[fgnames{ii} '_MD.csv']),tmp);
        
        tmp = cell2mat(groupTracts.rd(:,ii));
        tmp = [tmp; groupAvg.mean.rd{ii}];
        tmp = [tmp; groupAvg.std.rd{ii}];
        tmp = num2cell(tmp');
        tmp = vertcat(names,tmp);
        tmp = [nodes, tmp];
        cell2csv(fullfile(fold,fgnames{ii},[fgnames{ii} '_RD.csv']),tmp);
        
        tmp = cell2mat(groupTracts.ad(:,ii));
        tmp = [tmp; groupAvg.mean.ad{ii}];
        tmp = [tmp; groupAvg.std.ad{ii}];
        tmp = num2cell(tmp');
        tmp = vertcat(names,tmp);
        tmp = [nodes, tmp];
        cell2csv(fullfile(fold,fgnames{ii},[fgnames{ii} '_AD.csv']),tmp);
        
        tmp = cell2mat(groupTracts.cl(:,ii));
        tmp = [tmp; groupAvg.mean.cl{ii}];
        tmp = [tmp; groupAvg.std.cl{ii}];
        tmp = num2cell(tmp');
        tmp = vertcat(names,tmp);
        tmp = [nodes, tmp];
        cell2csv(fullfile(fold,fgnames{ii},[fgnames{ii} '_CL.csv']),tmp);
    end
end

%% Plot Groups summary
function plotAll(allTracts,fold)
    for ii = 1:length(allTracts.tractsName)
        f = figure('visible','off'); ax = gca(f); hold(ax,'on');
        set(ax,'ColorOrder',jet(length(allTracts.groupName)));
        plot(ax,cell2mat(allTracts.tractsAvg.mean.fa(:,ii))','linewidth',2);
        xlabel('Node','fontName','Times','fontSize',14);
        obj = title([allTracts.tractsName{ii} ' - FA Compare'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = legend(allTracts.groupName,'location','eastoutside'); set(obj,'Interpreter', 'none');
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(fold,allTracts.tractsName{ii},[allTracts.tractsName{ii} '_FA_Compare.png'])); 
        hold(ax,'off'); clear f;
        
        f = figure('visible','off'); ax = gca(f); hold(ax,'on');
        set(ax,'ColorOrder',jet(length(allTracts.groupName)));
        plot(ax,cell2mat(allTracts.tractsAvg.mean.md(:,ii))','linewidth',2);
        xlabel('Node','fontName','Times','fontSize',14);
        obj = title([allTracts.tractsName{ii} ' - MD Compare'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = legend(allTracts.groupName,'location','eastoutside'); set(obj,'Interpreter', 'none');
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(fold,allTracts.tractsName{ii},[allTracts.tractsName{ii} '_MD_Compare.png'])); 
        hold(ax,'off'); clear f;
        
        f = figure('visible','off'); ax = gca(f); hold(ax,'on');
        set(ax,'ColorOrder',jet(length(allTracts.groupName)));
        plot(ax,cell2mat(allTracts.tractsAvg.mean.rd(:,ii))','linewidth',2);
        xlabel('Node','fontName','Times','fontSize',14);
        obj = title([allTracts.tractsName{ii} ' - RD Compare'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = legend(allTracts.groupName,'location','eastoutside'); set(obj,'Interpreter', 'none');
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(fold,allTracts.tractsName{ii},[allTracts.tractsName{ii} '_RD_Compare.png'])); 
        hold(ax,'off'); clear f;
        
        f = figure('visible','off'); ax = gca(f); hold(ax,'on');
        set(ax,'ColorOrder',jet(length(allTracts.groupName)));
        plot(ax,cell2mat(allTracts.tractsAvg.mean.ad(:,ii))','linewidth',2);
        xlabel('Node','fontName','Times','fontSize',14);
        obj = title([allTracts.tractsName{ii} ' - AD Compare'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = legend(allTracts.groupName,'location','eastoutside'); set(obj,'Interpreter', 'none');
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(fold,allTracts.tractsName{ii},[allTracts.tractsName{ii} '_AD_Compare.png'])); 
        hold(ax,'off'); clear f;
        
       f = figure('visible','off'); ax = gca(f); hold(ax,'on');
        set(ax,'ColorOrder',jet(length(allTracts.groupName)));
        plot(ax,cell2mat(allTracts.tractsAvg.mean.cl(:,ii))','linewidth',2);
        xlabel('Node','fontName','Times','fontSize',14);
        obj = title([allTracts.tractsName{ii} ' - CL Compare'],'fontName','Times','fontSize',14); set(obj,'Interpreter', 'none');
        obj = legend(allTracts.groupName,'location','eastoutside'); set(obj,'Interpreter', 'none');
        set(ax,'Color',[.9 .9 .9],'fontName','Times','fontSize',14);
        saveas(f,fullfile(fold,allTracts.tractsName{ii},[allTracts.tractsName{ii} '_CL_Compare.png'])); 
        hold(ax,'off'); clear f;
    end
end