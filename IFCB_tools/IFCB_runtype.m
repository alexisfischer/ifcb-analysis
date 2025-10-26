function [ runtype ] = IFCB_runtype( hdrname )
clear
hdrname='~/Documents/MATLAB/bloom-baby-bloom/IFCB-Data/D20220521T005008_IFCB150.hdr';

if ischar(hdrname), hdrname = cellstr(hdrname); end;
runtype = NaN(size(hdrname));
for count = 1:length(hdrname),
    hdr = IFCBxxx_readhdr(hdrname{count});
    if ~isempty(hdr),
        runtype = hdr.runtype;
    end;
end;

end


