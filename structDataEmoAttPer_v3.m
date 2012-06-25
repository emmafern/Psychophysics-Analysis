function [data,info,anaEmo] = structDataEmoAttPer_v3(filenames,info,anaEmo)

datafields = {'block','trial','cueEmo','validity','targLoc','tilt','contrast','cueLoc','cueID','postCueLoc','buttonPress','correct','rt'};

numFields = length(datafields);

row = 1;
for i = 1:info.numFiles       % interate through each file
    
    if info.multFiles
        fid = fopen(filenames{i});
    else
        fid = fopen(char(filenames));    % if checking single file
    end

    while row
        tline = fgetl(fid);                % load first line of text file
        if tline == -1                     % if reached the end of the doc, return
            break
        elseif isempty(tline)              % if the line is empty
            continue                         % start at beginning of while loop
        elseif isempty(str2num(tline(1))) %#ok<ST2NM> % if 1st element not a number
            continue                         % skip to next line and load it
        end

        [T,R] = strtok(tline, ', ');       % take the first word, and the remainder
        data(row).block = str2num(T);  %#ok<ST2NM,AGROW> % enter block # into structure
        [T,R] = strtok(R, ', ');       %#ok<STTOK> % take the first word, and the remainder
        data(row).trial = str2num(T);   %#ok<ST2NM,AGROW> % enter trial # into structure
        
        for j = 3:numFields          % number of fields in data minus block and trial field
            [T,R] = strtok(R, ', ');          %#ok<STTOK>
            if strcmp(datafields(j), 'rt') || strcmp(datafields(j),'correct')
                data(row).(char(datafields(j))) = str2num(T); %#ok<ST2NM,AGROW>
            else
                data(row).(char(datafields(j))) = strtrim(T);  %#ok<AGROW> % fill in fields of data structure
            end
        end
        row = row + 1;
    end
end

for i = 1:size(data,2)
    data(i).trial = i; %#ok<AGROW>
end

tmp1 = {data.buttonPress}; %#ok<NASGU>
tmp2 = [data.rt];
tmp3 = {data.contrast};

info.timeouts = find(tmp2 == 999);  % note which trials have no response.
info.fastRT = find(tmp2 < 0.16);  % note which trials had a reaction time faster than 160ms (300ms from onset of target)
info.contrasts = unique(tmp3);