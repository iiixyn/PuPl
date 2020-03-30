
function out = pupl_alignbysync(EYE, varargin)

if nargin == 0
    out = @getargs;
else
    out = sub_alignbysync(EYE, varargin{:});
end

end

function args = parseargs(varargin)

args = pupl_args2struct(varargin, {
    'eyesync' []
    'elogsync' []
    'attach' []
    'overwrite' []
});

end

function outargs = getargs(EYE, varargin)

outargs = [];
args = parseargs(varargin{:});

if isempty(args.eyesync)
    args.eyesync = pupl_event_UIget([EYE.event], 'Which events in the eye data are sync markers?');
    if isempty(args.eyesync)
        return
    end
end

if isempty(args.elogsync)
    [~, args.elogsync] = listdlgregexp(...
        'PromptString', 'Which events in the event logs are sync markers?',...
        'ListString', unique(mergefields(EYE, 'eventlog', 'event', 'name')),...
        'AllowRegexp', true);
    if isempty(args.elogsync)
        return
    end
end

if isempty(args.attach)
    [~, args.attach] = listdlgregexp(...
        'PromptString', 'Which events from the event log should be attached to the eye data?',...
        'ListString', unique(mergefields(EYE, 'eventlog', 'event', 'name')),...
        'AllowRegexp', true);
    if isempty(args.attach)
        return
    end
end

if isempty(args.overwrite)
    q = 'Overwrite events already in eye data?';
    a = questdlg(q, q, 'Yes', 'No', 'Cancel', 'No');
    switch a
        case 'Yes'
            args.overwrite = true;
        case 'No'
            args.overwrite = false;
        otherwise
            return
    end
end

outargs = args;

end

function EYE = sub_alignbysync(EYE, varargin)

args = parseargs(varargin{:});

eye_sync = pupl_event_sel(EYE.event, args.eyesync);
elog_sync = pupl_event_sel(EYE.eventlog.event, args.elogsync);

eye_synctimes = [EYE.event(eye_sync).time];
elog_synctimes = [EYE.eventlog.event(elog_sync).time];

[offset_params, err] = findoffset(eye_synctimes, elog_synctimes);

if isempty(offset_params)
    EYE = [];
    error('Could not align sync markers');
else
    fprintf('Sync markers aligned with MSE %f s^2\n', err);
    fprintf('Offset: %f s\n', offset_params(2));
    fprintf('Drift parameter: %f s\n', offset_params(1));
end

attach_idx = pupl_event_sel(EYE.eventlog.event, args.attach);
elog_events = EYE.eventlog.event(attach_idx);
elog_events = fieldconsistency(elog_events, EYE.event);
elog_times = [elog_events.time];
new_times = num2cell(elog_times * offset_params(1) + offset_params(2));
[elog_events.time] = new_times{:};

EYE.event = [EYE.event(:)' elog_events(:)'];

[~, I] = sort([EYE.event.time]);
EYE.event = EYE.event(I);

end