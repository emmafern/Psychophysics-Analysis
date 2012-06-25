function [efit, info] = fitDataEmoAttPer_v3(emo4fit,info)

% put contrasts on log scale
emo4fit(:,1,:) = log(emo4fit(:,1,:)) + 10;
info.logcont = emo4fit(:,1,1)';

info.contrastsnum = round(str2num(char(info.contrasts))*100);

% separate conditions due to having different numbers of intensities
FV4fit = emo4fit(:,:,1);
FD4fit = emo4fit(:,:,2);
FI4fit = emo4fit(:,:,3);
NV4fit = emo4fit(:,:,4);
ND4fit = emo4fit(:,:,5);
NI4fit = emo4fit(:,:,6);

% replace zeros (contrasts not tested) with NaN
tmp = FV4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
FV4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.
tmp = FD4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
FD4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.
tmp = FI4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
FI4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.
tmp = NV4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
NV4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.
tmp = ND4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
ND4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.
tmp = NI4fit(:,3) == 0;  % find all the rows with a zero in the 3rd column
NI4fit(tmp,:) = []; %#ok<NASGU,FNDSB>  % delete those rows.

conds4fit = {'FV4fit','FD4fit','FI4fit','NV4fit','ND4fit','NI4fit'};
% use psignifit to fit the data to psychometric curves
for i = 1:length(conds4fit)
    a=figure(i);
    efit(i) = pfit(eval(conds4fit{i}),'plot without stats', 'shape', 'weibull', 'n_intervals', 2, 'cuts',.5, 'lambda_limits', [0 .08],'gamma_limits',[0 .08], 'verbose',0);
    xlim([5 11])
    ylim([0 1])
    ylabel('Proportion Correct','FontSize',15)
    xlabel('Contrast Levels (%)','FontSize',15)
    set(gca,'XTick',info.logcont')
    set(gca,'XTickLabel',info.contrastsnum)
    saveas(a,sprintf('%s_efit_%s',info.subID,info.emoconds{i}), 'png');
end
    
% Calculate Contrast Threshold
plevel = 0.75;

% Extract function parameters, slope, threshold, and goodness of fit
for i=1:size(efit,2)
    if strcmp(efit(i).shape,'Weibull')  % skip over missing conditions
        alpha = efit(i).params.est(1);
        beta = efit(i).params.est(2);
        gamma = efit(i).params.est(3);
        lambda = efit(i).params.est(4);
        params(i,:)=[alpha beta gamma lambda];
        threshold(i) = exp(getThresh(plevel,alpha,beta,gamma,lambda) - 10);
        slope(i) = efit(i).slopes.est(1);
        slopelims(i,:) = {efit(i).slopes.lims(1,1) efit(i).slopes.lims(4,1)};
        lambda2(i) = lambda;
        lambdalims(i,:) = {efit(i).params.lims(1,4) efit(i).params.lims(4,4)};
        gamma2(i) = gamma;
        gammalims(i,:) = {efit(i).params.lims(1,4) efit(i).params.lims(4,4)}; %#ok<NASGU>
        qualFit_D(i) = efit(i).stats.deviance.D; %#ok<NASGU,AGROW>
        qualFit_cpe(i) = efit(i).stats.deviance.cpe; %#ok<NASGU,AGROW>
    end
end

info.params = params;
info.threshold = threshold;
info.slope = slope;
info.slopelims = slopelims;
info.lambda = lambda2;
info.lambdalims = lambdalims;
info.gamma = gamma2;
info.qualFit_D = qualFit_D;
info.qualFit_cpe = qualFit_cpe;