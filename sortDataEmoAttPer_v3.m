function [dataEmo, emo4fit, info] = sortDataEmoAttPer_v3(data,info)

if ~isempty(info.fastRT) || ~isempty(info.timeouts)
    remove = [info.fastRT info.timeouts];
    data(remove) = [];  % get rid of fast response and timout trials
end

numTrials = size(data,2);  % recalculate how many trials

% now since some trials may have been taken out, relabel trial numbers.
for i = 1:numTrials
    data(i).trial = i; %#ok<AGROW>
end

fearValidInd=[];
fearDistrInd=[];
fearInvalInd=[];
neutValidInd=[];
neutDistrInd=[];
neutInvalInd=[];

% find indices for each of 6 conditions
for i = 1:numTrials
    switch data(i).cueEmo
        case 'Fear'
            if strcmp(data(i).validity,'Valid')
                fearValidInd = [fearValidInd i];
            elseif strcmp(data(i).validity,'Distr')
                fearDistrInd = [fearDistrInd i];
            elseif strcmp(data(i).validity,'Inval')
                fearInvalInd = [fearInvalInd i];
            end
        case 'Neut'
            if strcmp(data(i).validity,'Valid')
                neutValidInd = [neutValidInd i];
            elseif strcmp(data(i).validity,'Distr')
                neutDistrInd = [neutDistrInd i];
            elseif strcmp(data(i).validity,'Inval')
                neutInvalInd = [neutInvalInd i];
            end
    end
end

info.emoIND = {'fearValidInd','fearDistrInd','fearInvalnd','neutValidInd','neutDistrInd','neutInvalInd'};
info.emoconds = {'FV','FD','FI','NV','ND','NI'};
numEmoConds = length(info.emoconds);
numContrasts = length(info.contrasts);
    
% find indices for each contrast level within each condition
for i = 1:numContrasts
    contfields{1,i} = sprintf('c%d', i);
end

for i = 1:numEmoConds                                                                         %loop through 6 conditions
    for k = 1:numContrasts                                                              % loop through k contrast levels
        dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).contfieldsIND = [];            % instantiate empty index
    end
end

% create an index of all the trial numbers for each contrast within each
% condition

for k = 1:numContrasts
    for j = 1:length(fearValidInd)
        if strcmp(data(fearValidInd(j)).contrast,info.contrasts(k))
            dataEmo.FV.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.FV.(sprintf('%s',contfields{k})).contfieldsIND fearValidInd(j)];
        end
    end
    for m = 1:length(fearDistrInd)
        if strcmp(data(fearDistrInd(m)).contrast,info.contrasts(k))
            dataEmo.FD.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.FD.(sprintf('%s',contfields{k})).contfieldsIND fearDistrInd(m)];
        end
    end
    for n = 1:length(fearInvalInd)
        if strcmp(data(fearInvalInd(n)).contrast,info.contrasts(k))
            dataEmo.FI.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.FI.(sprintf('%s',contfields{k})).contfieldsIND fearInvalInd(n)];
        end
    end
    for p = 1:length(neutValidInd)
        if strcmp(data(neutValidInd(p)).contrast,info.contrasts(k))
            dataEmo.NV.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.NV.(sprintf('%s',contfields{k})).contfieldsIND neutValidInd(p)];
        end
    end
    for q = 1:length(neutDistrInd)
        if strcmp(data(neutDistrInd(q)).contrast,info.contrasts(k))
            dataEmo.ND.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.ND.(sprintf('%s',contfields{k})).contfieldsIND neutDistrInd(q)];
        end
    end
    for r = 1:length(neutInvalInd)
        if strcmp(data(neutInvalInd(r)).contrast,info.contrasts(k))
            dataEmo.NI.(sprintf('%s',contfields{k})).contfieldsIND = [dataEmo.NI.(sprintf('%s',contfields{k})).contfieldsIND neutInvalInd(r)];
        end
    end
end

correct = [data.correct];
% rt = [data.rt];

% incorrectInd = find(correct == 0);
% rt(incorrectInd) = NaN; %#ok<FNDSB>

% calculate number correct, total trials, mean RT, and standard error RT
% for each condition and contrast level
for i = 1:numEmoConds
    for k = 1:numContrasts
        dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).correct = ...
            sum(correct(dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).contfieldsIND));  % sum of correct trials
        dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).ntrials =  ...
            length(dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).contfieldsIND);  % # of trials in each cond
%         dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).mRT = ...
%             nanmean(rt(dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).contfieldsIND)); % mean RT
%         dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).seRT = ...
%             nanstd(rt(dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).contfieldsIND) / ...
%             sqrt(dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{k})).ntrials));  % RT SE
    end
end

% restructure the data into a format readable by psignifit
emo4fit = zeros(numContrasts,3,numEmoConds);

for i = 1:numContrasts
    contValue(i) = str2double(info.contrasts{i});
end

for i = 1:numEmoConds
    emo4fit(:,1,i) = contValue';
    for j = 1:numContrasts
        emo4fit(j,2,i) = dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{j})).correct;
        emo4fit(j,3,i) = dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{j})).ntrials;
    end
end

% % restucture RT data for ease in plotting
% for i = 1:numEmoConds
%     dataEmo.(sprintf('%s',info.emoconds{i})).mRTvec = [];
%     dataEmo.(sprintf('%s',info.emoconds{i})).seRTvec = [];
% end
% 
% for i = 1:numEmoConds
%     for j = 1:numContrasts
%         dataEmo.(sprintf('%s',info.emoconds{i})).mRTvec = ...
%             [dataEmo.(sprintf('%s',info.emoconds{i})).mRTvec dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{j})).mRT];
%         dataEmo.(sprintf('%s',info.emoconds{i})).seRTvec = ...
%             [dataEmo.(sprintf('%s',info.emoconds{i})).seRTvec dataEmo.(sprintf('%s',info.emoconds{i})).(sprintf('%s',contfields{j})).seRT];
%     end
% end