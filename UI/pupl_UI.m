function pupl_UI

global userInterface

userInterface = figure('Name', 'Pupillometry',...
    'NumberTitle', 'off',...
    'UserData', struct(...
        'dataCount', 0,...
        'eventLogCount', 0,...
        'activeEyeDataIdx', logical([]),...
        'activeEventLogsIdx', logical([])),...
    'SizeChangedFcn', @preservelayout,...
    'CloseRequestFcn', @savewarning,...
    'MenuBar', 'none',...
    'ToolBar', 'none',...
    'Visible', 'off');

% Active datasets
uibuttongroup('Title', 'Active datasets',...
    'Tag', 'activeEyeDataPanel',...
    'Position',[0.01 0.01 .48 0.95],...
    'FontSize', 10);
uibuttongroup('Title', 'Active event logs',...
    'Tag', 'activeEventLogsPanel',...
    'Position',[0.51 0.01 .48 0.95],...
    'FontSize', 10);

% File menu
fileMenu = uimenu(userInterface,...
    'Tag', 'fileMenu',...
    'Label', '&File');
importMenu = uimenu(fileMenu,...
    'Tag', 'importEyeDataMenu',...
    'Label', '&Import');
uimenu(importMenu,...
    'Label', 'From &XDF',...
    'Callback', @(h, e)...
        updateglobals('eyeData',...
            'append',...
            @() pupl_xdfimport('as', 'eye data'),...
            1));
uimenu(fileMenu,...
    'Label', '&Load',...
    'Callback', @(h, e)...
        updateglobals(...
            'eyeData',...
            'append',...
            @() pupl_load('type', 'eye data'),...
            1));
uimenu(fileMenu,...
    'Label', '&Save',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'eye data', 'data', getactive('eye data')), []));
uimenu(fileMenu,...
    'Label', '&Remove inactive datasets',...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() deleteinactive('eye data'), []));
uimenu(fileMenu,...
    'Label', 'Save processing &history and stop logging',...
    'Separator', 'on',...
    'Callback', @(h, e) eval('warning(''subsequent processing will not be logged''); diary(''off'')'));

% Processing menu
processingMenu = uimenu(userInterface, 'Label', '&Process');
trimmingMenu = uimenu(processingMenu,...
    'Label', '&Trim data');
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &dilation values',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimdiam(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim extreme &gaze values',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimgaze(getactive('eye data')),...
            1));
uimenu(trimmingMenu,...
    'Label', 'Trim &isolated samples',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() trimshort(getactive('eye data')),...
            1));
blinksMenu = uimenu(processingMenu,...
    'Label', '&Blinks');
uimenu(blinksMenu,...
    'Label', 'Identify &blinks',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() identifyblinks(getactive('eye data')),...
            1));
uimenu(blinksMenu,...
    'Label', 'Delete &blink samples',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() deleteblinks(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Label', 'Moving &average filter',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() eyefilter(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Label', '&Interpolate',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() interpeyedata(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Label', '&Merge left and right streams',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() mergelr(getactive('eye data'), 'diamlr'),...
            1));
PFEmenu = uimenu(processingMenu,...
    'Label', 'Pupil foreshortening &error correction');
uimenu(PFEmenu,...
    'Label', '&Linear detrend in gaze y-axis',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEdetrend(getactive('eye data'), 'axis', 'y'),...
            1));
uimenu(PFEmenu,...
    'Label', '&Quadratic detrend in gaze x-axis',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEdetrend(getactive('eye data'), 'axis', 'x'),...
            1));
uimenu(PFEmenu,...
    'Label', 'Automatic PFE correction (beta)',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() PFEcorrection(getactive('eye data')),...
            1));

% Trials menu
trialsMenu = uimenu(userInterface,...
    'Label', '&Trials');
% Event logs sub-menu
eventLogsMenu = uimenu(trialsMenu,...
    'Label', '&Event logs');
uimenu(eventLogsMenu,...
    'Label', '&Write to eye data',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() attachevents(getactive('eye data'),...
                'eventLogs', getactive('event logs')),...
            1));
importEventLogsMenu = uimenu(eventLogsMenu,...
    'Tag', 'importEventLogsMenu',...
    'Label', '&Import',...
    'Separator', 'on');
uimenu(importEventLogsMenu,...
    'Label', 'From &XDF',...
    'Interruptible', 'off',...
    'Callback', @(h, e)...
        updateglobals('eventLogs',...
            'append',...
            @() pupl_xdfimport('as', 'event logs', 'manual', false),...
            1));
uimenu(eventLogsMenu,...
    'Label', '&Load',...
    'Callback', @(src, event)...
        updateglobals('eventLogs',...
            'append',...
            @() pupl_load('type', 'event logs'),...
            1));
uimenu(eventLogsMenu,...
    'Label', '&Save',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'event logs', 'data', getactive('eye data')), []));
uimenu(eventLogsMenu,...
    'Label', '&Remove inactive event logs',...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals([], [],...
            @() deleteinactive('event logs'), []));
% The rest of the trials menu
uimenu(trialsMenu,...
    'Label', '&Fragment continuous data into trials',...
    'Interruptible', 'off',...
    'Separator', 'on',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() epoch(getactive('eye data')),...
            1));
trialRejectionMenu = uimenu(trialsMenu,...
    'Label', 'Trial &rejection');
% Rejection sub-menu
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &missing data',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejecttrialsbymissingppn(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', 'Reject by &blink proximity',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejecttrialsbyblinkproximity(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', 'Reject by e&xtreme values',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() rejectbyextremevalues(getactive('eye data')),...
            1));
uimenu(trialRejectionMenu,...
    'Label', '&Un-reject trials',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() unreject(getactive('eye data')),...
            1));

uimenu(trialsMenu,...
    'Label', '&Merge trials into sets',...
    'Interruptible', 'off',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() binepochs(getactive('eye data')),...
            1));
    
% Experiment menu
experimentMenu = uimenu(userInterface,...
    'Label', '&Experiment');
uimenu(experimentMenu,...
    'Label', '&Assign datasets to conditions',...
    'Callback', @(src, event)...
        updateglobals('eyeData',...
            'append',...
            @() pupl_condition(getactive('eye data')),...
            1));

% Plotting menu
plottingMenu = uimenu(userInterface,...
    'Label', 'P&lot');
scrollMenu = uimenu(plottingMenu,...
    'Label', 'Plot &continuous');
uimenu(scrollMenu,...
    'Label', 'P&upil dilation',...
    'Callback', @(src, event)...
        plotcontinuous(getactive('eye data'), 'type', 'dilation'));
uimenu(scrollMenu,...
    'Label', 'Ga&ze',...
    'Callback', @(src, event)...
        plotcontinuous(getactive('eye data'), 'type', 'gaze'));
uimenu(plottingMenu,...
    'Label', 'Plot &trials',...
    'Callback', @(src, event)...
        plottrials(getactive('eye data')));
plotTrialSetsMenu = uimenu(plottingMenu,...
    'Label', 'Plot trial &sets');
uimenu(plotTrialSetsMenu,...
    'Label', '&Line plot',...
    'Callback', @(src, event)...
        plottrialaverages(getactive('eye data')));
uimenu(plotTrialSetsMenu,...
    'Label', '&Heatmap',...
    'Callback', @(src, event)...
        eyeheatmap(getactive('eye data')));
uimenu(plottingMenu,...
    'Label', 'Pupil &foreshortening error surface',...
    'Callback', @(h, e)...
        UI_getPFEsurfaceparams(getactive('eye data')));

% Spreadsheet menu
spreadSheetMenu = uimenu(userInterface,...
    'Label', '&Spreadsheet');
uimenu(spreadSheetMenu,...
    'Label', '&Write eye data to spreadsheet',...
    'Callback', @(src, event)...
        writetospreadsheet(getactive('eye data')));
    
userInterface.Visible = 'on';
    
end