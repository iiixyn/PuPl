
function EYE = pupl_reverttounprocessed(EYE)

fprintf('Reverting to unprocessed data...\n');
for dataidx = 1:numel(EYE)
    fprintf('\t%s...', EYE(dataidx).name);
    for field = {'gaze' 'diam'}
        EYE(dataidx).(field{:}) = getfromur(EYE(dataidx), field{:});
    end
    if isfield(EYE(dataidx).diam, 'both')
        EYE(dataidx).diam = rmfield(EYE(dataidx).diam, 'both');
    end
    fprintf('clearing processing history...');
    EYE(dataidx).history{end + 1} = getcallstr;
    fprintf('done\n');
end
fprintf('Done\n');

end