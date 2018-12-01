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
    'Text', '&File');
uimenu(fileMenu,...
    'Text', '&Import',...
    'MenuSelectedFcn', @(h, e)...
        updateglobals('eyeData',...
            'append',...
            @() pupl_format('type', 'eye data'),...
            1));
uimenu(fileMenu,...
    'Text', '&Load',...
    'MenuSelectedFcn', @(h, e)...
        updateglobals(...
            'eyeData',...
            'append',...
            @() pupl_load('type', 'eye data'),...
            1));
uimenu(fileMenu,...
    'Text', '&Save',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals(...
            'eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() pupl_save('type', 'eye data', 'data', getactive('eye data')),...
            0));
uimenu(fileMenu,...
    'Text', '&Remove active datasets',...
    'Separator', 'on',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals([], [],...
            @() deleteactive('eye data'), []));

% Processing menu
processingMenu = uimenu(userInterface, 'Text', '&Process');
uimenu(processingMenu,...
    'Text', 'Identify &blinks',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() identifyblinks(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Text', '&Moving average filter',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() eyefilter(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Text', '&Interpolate',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() interpeyedata(getactive('eye data')),...
            1));
uimenu(processingMenu,...
    'Text', '&Merge left and right streams',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() mergelr(getactive('eye data')),...
            1));

% Epoching menu
trialsMenu = uimenu(userInterface,...
    'Text', '&Trials');
uimenu(trialsMenu,...
    'Text', '&Separate into trials',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() epoch(getactive('eye data')),...
            1));
uimenu(trialsMenu,...
    'Text', '&Merge trials',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() binepochs(getactive('eye data')),...
            1));
% Event logs sub-menu
eventLogsMenu = uimenu(trialsMenu,...
    'Text', '&Event logs');
uimenu(eventLogsMenu,...
    'Text', '&Write to eye data',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() attachevents(getactive('eye data'),...
                'eventLogs', getactive('event logs')),...
            1));
uimenu(eventLogsMenu,...
    'Text', '&Import',...
    'Separator', 'on',...
    'Interruptible', 'off',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eventLogs',...
            'append',...
            @() pupl_format('type', 'event logs'),...
            1));
uimenu(eventLogsMenu,...
    'Text', '&Load',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eventLogs',...
            'append',...
            @() pupl_load('type', 'event logs'),...
            1));
uimenu(eventLogsMenu,...
    'Text', '&Save',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals([], [],...
            @() pupl_save('type', 'event logs', 'data', getactive('eye data')), []));
uimenu(eventLogsMenu,...
    'Text', '&Remove active event logs',...
    'Separator', 'on',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals([], [],...
            @() deleteactive('event logs'), []));
    
% Experiment menu
experimentMenu = uimenu(userInterface,...
    'Text', '&Experiment');
uimenu(experimentMenu,...
    'Text', '&Assign datasets to conditions',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() pupl_condition(getactive('eye data')),...
            1));
uimenu(experimentMenu,...
    'Text', '&Merge conditions',...
    'MenuSelectedFcn', @(src, event)...
        updateglobals('eyeData',...
            userInterface.UserData.activeEyeDataIdx,...
            @() pupl_merge(getactive('eye data')),...
            1));

% Plotting menu
plottingMenu = uimenu(userInterface,...
    'Text', 'P&lot');
uimenu(plottingMenu,...
    'Text', 'Plot &continuous',...
    'MenuSelectedFcn', @(src, event)...
        plotcontinuous(getactive('eye data')));
plotTrialsMenu = uimenu(plottingMenu,...
    'Text', 'Plot &trials');
uimenu(plotTrialsMenu,...
    'Text', '&Line plot',...
    'MenuSelectedFcn', @(src, event)...
        plottrials(getactive('eye data')));
uimenu(plotTrialsMenu,...
    'Text', '&Heatmap',...
    'MenuSelectedFcn', @(src, event)...
        eyeheatmap(getactive('eye data')));
uimenu(plottingMenu,...
    'Text', 'Pupil &foreshortening error surface',...
    'MenuSelectedFcn', @(h, e)...
        PFEplot(getactive('eye data')));

% Spreadsheet menu
spreadSheetMenu = uimenu(userInterface,...
    'Text', '&Spreadsheet');
uimenu(spreadSheetMenu,...
    'Text', '&Write eye data to spreadsheet',...
    'MenuSelectedFcn', @(src, event)...
        writetospreadsheet(getactive('eye data')));
    
userInterface.Visible = 'on';
    
end