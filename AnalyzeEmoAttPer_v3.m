%% Read in text files from EmoAttPer 2010 psychophysics experiment
% create a data structure recording all details of each trial in one mat file
% organize data averaging over target location
% October 2010, Emma Ferneyhough

function [info] = AnalyzeEmoAttPer_v3()

%% Choose text files
info.multFiles = input('Analyzing multiple (1) or single (0) text file ? ');
if info.multFiles
    [filenames, pathname] = uigetfile('*.txt', 'Pick text files', 'MultiSelect', 'on'); %#ok<NASGU>
    info.numFiles = length(filenames); %#ok<NASGU>
else
    [filenames, pathname] =uigetfile('*.txt', 'Pick text file', 'MultiSelect','off');
    info.numFiles = 1; %#ok<NASGU>
end
if isequal(filenames,0) || isequal(pathname,0)
    disp('User pressed cancel')
end

addpath(pathname)
cd(pathname)

% anaEmo = input('Enter 1 to analyze emotion, and 2 to collapse over emotion (e.g.,''1''): ');
% anaBlock = input('Enter 1 to analyze by block, and 2 to collapse over blocks (e.g., "1"): ');
% pool = input('Enter 1 for single subject, 2 for average over subjects: ');

anaEmo = 1;
anaBlock = 2;
pool = 1;

if pool == 1
    info.subID = char(filenames);
    info.subID = info.subID(1,1:8);
else
    info.subID = 'AVG';
end

%% --------------Put Data in Structure---------------%
[data, info, anaEmo] = structDataEmoAttPer_v3(filenames, info, anaEmo);
save(sprintf('%s_structData',info.subID), 'data','info','filenames','anaBlock','anaEmo','pool');

%% ----------Organize Data by Type of Analysis--------%
%------and---Fit the Data using Psignifit------------%

[dataEmo, emo4fit, info] = sortDataEmoAttPer_v3(data, info);
save(sprintf('%s_emoData',info.subID), 'data','info','dataEmo','emo4fit');
[efit, info] = fitDataEmoAttPer_v3(emo4fit,info);
save(sprintf('%s_emoFit',info.subID), 'data','info','dataEmo','emo4fit','efit');

info.qualFit_D' %#ok<NOPRT,NOPTS>
info.qualFit_cpe' %#ok<NOPRT,NOPTS>
info.threshold' %#ok<NOPRT,NOPTS>
info.slope' %#ok<NOPRT,NOPTS>
info.lambda' %#ok<NOPRT,NOPTS>
info.gamma' %#ok<NOPRT,NOPTS>