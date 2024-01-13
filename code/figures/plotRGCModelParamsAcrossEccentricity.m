% scriptCreatePlots

% Housekeeping
clear
close all

% Load the RGC temporal model
rgcTemporalModel = fitRGCFResponse();

% Where to save figures
savePath = fullfile('~','Desktop','VSS 2023');

% Extract some info from the stored model structure
pRGC = rgcTemporalModel.p;
cfCone = rgcTemporalModel.cfCone;
coneDelay = rgcTemporalModel.coneDelay;
LMRatio = rgcTemporalModel.LMRatio;
pFitByEccen = rgcTemporalModel.pFitByEccen;
blockParamNames = rgcTemporalModel.meta.blockParamNames;
eccFields = rgcTemporalModel.meta.eccFields;
eccBins = rgcTemporalModel.meta.eccBins;
eccDegs = rgcTemporalModel.meta.eccDegs;
lbBlock = rgcTemporalModel.meta.lbBlock;
ubBlock = rgcTemporalModel.meta.ubBlock;

cellClasses = rgcTemporalModel.meta.cellClassIndices;

nEccBands = length(eccFields);
nBlockParams = size(pRGC,1);

% Plot the parameters vs. eccentricity and obtain params x eccentricity
% Loop across cells

for cc=1:3
    figure

    % Loop across the 7 params that vary with eccentricty
    for ii=1:nBlockParams-1

        % The values for this param across eccentricity
        y = squeeze(pRGC(ii,:,cc));

        % Plot these values and the fit
        subplot(4,2,ii)
        plot(eccDegs,y,'ok')
        hold on
        eccDegsFit = 0:90;
        plot(eccDegsFit,pFitByEccen{ii,cc}(eccDegsFit),'-r')
        title(blockParamNames{ii})
        xlabel('Eccentricity [deg]'); ylabel('param value')
        ylim([lbBlock(ii) ubBlock(ii)]);

    end
    sgtitle(cellClasses{cc})

    plotName = ['rgcModelParamsWithEccentricity_' cellClasses{cc} '.pdf' ];
    saveas(gcf,fullfile(savePath,plotName));

end

