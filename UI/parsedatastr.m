
function lim = parsedatastr(cmd, data)

%   Inputs
% str--something with %, m, sd

% Deal with percentiles
for x = {'%'}
    while true
        [s, e] = regexp(cmd, ['\d+(\.\d+)?' x{:}]);
        if isempty(s)
            break
        else
            cmd = [
                cmd(1:s(1)-1)...
                sprintf('%f', percentile(data, sscanf(cmd(s(1):e(1)), '%f')))...
                cmd(e(1)+1:end)
            ];
        end
    end
end

subs = {
    '\$'  @(x) x
    '`mn' @nanmean_bc
    '`md' @nanmedian_bc
    '`sd' @nanstd_bc
    '`var'  @nanvar_bc
    '`iq' @interquartilerange
    '`madv' @medianabsdev
};

for ii = 1:size(subs, 1)
    cmd = strsubconstval(cmd, subs{ii, 1}, all2str(subs{ii, 2}(data)));
end

try
    lim = eval(cmd);
catch
    lim = nan;
end

end