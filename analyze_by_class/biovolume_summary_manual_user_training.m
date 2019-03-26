function [ ] = biovolume_summary_manual_user_training( manualpath, datapath, feapath_base, summary_dir)
%function [ ] = biovolume_summary_manual_user_training( manualpath, datapath, feapath_base, summary_dir)
%
% Heidi M. Sosik, Woods Hole Oceanographic Institution, September 2012 / August 2015
% modified by Alexis D. Fischer, UCSC, January 2019
% 
% manualpath = 'F:\IFCB104\manual\'; %USER manual file location
% datapath = 'F:\IFCB104\data\'; %USER where to access data (hdr files) (url for web services, full path for local)
% feapath_base = 'F:\IFCB104\features\XXXX\'; %USER
% summary_dir = 'C:\Users\kudelalab\Documents\GitHub\bloom-baby-bloom\SCW\Data\IFCB_summary\manual\'; %where summary file goes
micron_factor = 1/3.4; %USER PUT YOUR OWN microns per pixel conversion
filelist = dir([manualpath 'D*.mat']);

%calculate date
matdate = IFCB_file2date({filelist.name});

load([manualpath filelist(1).name]) %read first file to get classes
numclass = length(class2use_manual);
class2use_manual_first = class2use_manual;
classcount = NaN(length(filelist),numclass);  %initialize output
classbiovol = classcount;
ml_analyzed = NaN(length(filelist),1);

for filecount = 1:length(filelist),
    filename = filelist(filecount).name;
    disp(filename)
    hdrname = [datapath filesep filename(2:5) filesep filename(1:9) filesep regexprep(filename, 'mat', 'hdr')]; 
    ml_analyzed(filecount) = IFCB_volume_analyzed(hdrname);
     
    load([manualpath filename])
  %  yr = str2num(filename(7:10));
    clear targets
    feapath = regexprep(feapath_base, 'XXXX', filename(2:5));
    [~,file] = fileparts(filename);
    feastruct = importdata([feapath file '_fea_v2.csv'], ',');
    ind = strmatch('Biovolume', feastruct.colheaders);
    targets.Biovolume = feastruct.data(:,ind);
    ind = strmatch('roi_number', feastruct.colheaders);
    tind = feastruct.data(:,ind);   
    
    classlist = classlist(tind,:);
    if ~isequal(class2use_manual, class2use_manual_first)
        disp('class2use_manual does not match previous files!!!')
        %     keyboard
    end;
    temp = zeros(1,numclass); %init as zeros for case of subdivide checked but none found, classcount will only be zero if in class_cat, else NaN
    tempvol = temp;
    for classnum = 1:numclass,
        cind = find(classlist(:,2) == classnum | (isnan(classlist(:,2)) & classlist(:,3) == classnum));
        temp(classnum) = length(cind);
        tempvol(classnum) = nansum(targets.Biovolume(cind)*micron_factor.^3);
    end;
    
    classcount(filecount,:) = temp;
    classbiovol(filecount,:) = tempvol;  
    clear class2use_manual class2use_auto class2use_sub* classlist
end;

class2use = class2use_manual_first;

%datestr = date; datestr = regexprep(datestr,'-','');
notes = 'Biovolume in units of cubed micrometers';
save([summary_dir 'count_biovol_manual'], 'matdate', 'ml_analyzed', 'classcount', 'classbiovol', 'filelist', 'class2use', 'notes')

disp('Summary biovolume file stored here:')
disp([summary_dir 'count_biovol_manual'])


