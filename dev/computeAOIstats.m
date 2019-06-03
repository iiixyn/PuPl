
function EYE = computeAOIstats(EYE, varargin)

% Populates EYE.aoi.stats field

p = inputParser;
addParameter(p, 'stats', []);
parse(p, varargin{:});
callstr = sprintf('eyeData = %s(eyeData, ', mfilename);

statOptions = {
    'Time to first fixation' @(isinaoi, srate, datalabel) find(isinaoi, 1)*srate;
    'Time spent' @(isinaoi, srate, datalabel) (sum(isinaoi) - 1)*srate;
    'N. fixations' @(isinaoi, srate, datalabel) sum(isinaoi & [false diff(datalabel == 'f') == 1 false])
    'N. visits' @(isinaoi, varargin) sum(diff(isinaoi) == 1);
    'First fixation duration' @(isinaoi, srate, datalabel)...
        srate*(find(isinaoi & datalabel == 's', 1) - find(isinaoi, 1))
    'Average fixation duration' @afd
};
if isempty(p.Results.stats)
    stats = allEventTypes(listdlgregexp('PromptString', sprintf('Compute which stats?', p.Results.spanName),...
            'ListString', statOptions(:, 1)));
else
    stats = p.Results.stats;
end
callstr = sprintf('%s''stats'', %s)', callstr, all2str(stats));

for dataidx = 1:numel(EYE)
    x = EYE(dataidx).gaze.x;
    y = EYE(dataidx).gaze.y;
    srate = EYE(dataidx).srate;
    datalabel = EYE(dataidx).datalabel;
    for aoiidx = 1:numel(EYE(dataidx).aoi)
        aoi = EYE(dataidx).aoi(aoiidx);
        isinaoi = x(aoi.absLatencies) > aoi.coords(1) &...
            x(aoi.absLatencies) < aoi.coords(1) + aoi.coords(3) &...
            y(aoi.absLatencies) > aoi.coords(2) &...
            y(aoi.absLatencies) < aoi.coords(2) + aoi.coords(4);
        for statidx = find(ismember(statOptions(1, :), stats))
            EYE(dataidx).aoi(aoiidx).stats = cat(2, EYE(dataidx).aoi(aoiidx).stats,...
                struct(...
                    'name', statOptions{statidx, 1},...
                    'stat', feval(statOptions{statidx, 2}, isinaoi, srate, datalabel)));
        end
    end
    EYE(dataidx).history = cat(1, EYE(dataidx).history, callstr);
end

end

function d = afd(isinaoi, srate, datalabel)

starts = isinaoi & [false diff(datalabel == 'f') == 1 false];
ends = isinaoi & [false diff(datalabel == 'f') == -1 false];
d = mean(find(starts) - find(ends)) * srate;

end