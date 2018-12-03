function errorSurf = getPFEerrorsurface(EYE)

%   Inputs
% EYE--single struct, not array
%   Outputs
% errSurf--struct with fields:
%   surface--numerical matrix
%   x--gaze x values
%   y--gaze y values

f = figure(...
    'ToolBar', 'none',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'Name', 'Pupil foreshortening error surface',...
    'Units', 'normalized',...
    'Position', [0.2 0.2 0.7 0.7]);

% Plot
axes(f,...
    'Tag', 'errorSurface',...
    'Units', 'normalized',...
    'Position', [0.36 0.11 0.58 0.78])
% Params
controlPanel = uipanel(f,...
    'Tag', 'controlPanel',...
    'Units', 'normalized',...
    'Position', [0.01 0.01 0.28 0.98]);
% Trim proportion
uicontrol(controlPanel,...
    'Style', 'text',...
    'String', 'Trim what proportion of highest & lowest x and y gaze values?',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.91 0.98 0.08])
uicontrol(controlPanel,...
    'Tag', 'trimPpn',...
    'Style', 'edit',...
    'String', '0.0',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.81 0.98 0.08])
% Manual range
uicontrol(controlPanel,...
    'Style', 'text',...
    'String', 'Or input gaze range (low x, high x, low y, high y) (overwrites the above)',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.71 0.98 0.08])
uicontrol(controlPanel,...
    'Tag', 'inputRange',...
    'Style', 'edit',...
    'String', '',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.61 0.98 0.08])
% Grid n
uicontrol(controlPanel,...
    'Style', 'text',...
    'String', 'Divide the gaze field into an n-by-n grid where n equals:',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.51 0.98 0.08])
uicontrol(controlPanel,...
    'Tag', 'gridN',...
    'Style', 'edit',...
    'String', '32',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.41 0.98 0.08])
% Boxcar param
uicontrol(controlPanel,...
    'Style', 'text',...
    'String', 'Boxcar square side length (in units of grid points):',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.31 0.98 0.08])
uicontrol(controlPanel,...
    'Tag', 'boxcar',...
    'Style', 'edit',...
    'String', '0.5',...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.21 0.98 0.08])
uicontrol(controlPanel,...
    'Style', 'pushbutton',...
    'String', 'Plot error surface',...
    'Callback', @(h,e)plotErrorSurf(EYE, f, 'error'),...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.51 0.11 0.48 0.08])
uicontrol(controlPanel,...
    'Style', 'pushbutton',...
    'String', 'Plot density',...
    'Callback', @(h,e)plotErrorSurf(EYE, f, 'density'),...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.11 0.48 0.08])
uicontrol(controlPanel,...
    'Style', 'pushbutton',...
    'String', 'Done',...
    'Callback', @(h,e)uiresume(f),...
    'FontSize', 10,...
    'Units', 'normalized',...
    'Position', [0.01 0.01 0.98 0.08])

plotErrorSurf(EYE, f, 'error');

uiwait(f);
if isvalid(f)
    errorSurf = f.UserData.errorSurf;
    close(f);
else
    errorSurf = [];
end
    
end

function plotErrorSurf(EYE, varargin)

fprintf('Plotting...')

f = varargin{1};

gridN = str2num(get(getcomponentbytag(f, 'controlPanel', 'gridN'), 'String'));
trimPpn = str2num(get(getcomponentbytag(f, 'controlPanel', 'trimPpn'), 'String'));
inputRange = str2num(get(getcomponentbytag(f, 'controlPanel', 'inputRange'), 'String'));
boxcar = str2num(get(getcomponentbytag(f, 'controlPanel', 'boxcar'), 'String'));

if isempty(inputRange)
    sorteds = structfun(@(v) sort(v(~isnan(v))), EYE.gaze, 'un', 0);
    ranges = structfun(@(v)...
                linspace(v(max(round(trimPpn*numel(v)), 1)),...
                         v(min(round((1 - trimPpn)*numel(v)), numel(v))),...
                         gridN),...
        sorteds, 'un', 0);
else
    ranges = struct(...
        'x', linspace(inputRange(1), inputRange(2), gridN),...
        'y', linspace(inputRange(3), inputRange(4), gridN));
end
widths = structfun(@(x) (x(2) - x(1))*boxcar, ranges, 'un', 0);
[averages, densities] = deal(nan(gridN));
if isfield(EYE.data, 'both')
    dataVector = EYE.data.both;
else
    dataVector = mean([EYE.data.left; EYE.data.right], 'omitnan');
end
dataVector = pi*(dataVector/2).^2;
fprintf('%0.2f', 0);
for xi = 1:numel(ranges.x)
    fprintf('\b\b\b\b%0.2f', xi/numel(ranges.x));
    for yi = 1:numel(ranges.y)
        currIdx = abs(EYE.gaze.x - ranges.x(xi)) <= widths.x...
            & abs(EYE.gaze.y - ranges.y(yi)) <= widths.y...
            & ~EYE.isBlink;
        densities(yi, xi) = numel(~isnan(dataVector(currIdx)));
        averages(yi, xi) = mean(dataVector(currIdx), 'omitnan');
    end
end

f.UserData.errorSurf = struct(...
    'surface', averages,...
    'x', ranges.x,...
    'y', ranges.y);

axes(getcomponentbytag(f, 'errorSurface'));
if any(strcmpi(varargin, 'density'))
    title('Measured dilation by gaze coordinates')
    image(ranges.x, ranges.y, flipud(densities),...
        'CDataMapping', 'scaled');
    cbarLabel = 'N. data points';
elseif any(strcmpi(varargin, 'error'))
    title('Measured dilation by gaze coordinates')
    set(image(ranges.x, ranges.y, flipud(averages),...
        'CDataMapping', 'scaled'),...
        'AlphaData', flipud(~isnan(averages)));
    cbarLabel = 'Average measured pupil area';
end
set(gca,'YDir','normal')
xlabel('Gaze x');
ylabel('Gaze y');
c = colorbar;
c.Label.String = cbarLabel;

fprintf('\b\b\b\bdone\n')

end