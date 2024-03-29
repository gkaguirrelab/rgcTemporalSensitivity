% Plot cell population density

% Place to save figures
savePath = '~/Desktop/VSS 2023/';

% Drasdo 2007 equation for the midget fraction as a function of
% eccentricity
midgetFraction = @(eccDeg) 0.8928*(1+eccDeg/41.03).^(-1);

% Bistratified RGCs as a function of eccentricity. Values taken from Figure
% 13B of:
%   Dacey DM. Morphology of a small-field bistratified ganglion cell type
%   in the macaque and human retina. Visual neuroscience. 1993
%   Nov;10(6):1081-98.
% Further, set the bistratified density to 0 below 0.5 degrees to model the
% tritanopic foveola.
%{
    daceyXmm = [1.0082    1.9945    2.9589    3.9671    4.9534    5.9616    6.9699    7.9123    8.9205    9.9507   10.9589   11.9671    12.9973   13.9616   14.9699];
    daceyY = 0.01 .* [1.3912    1.5573    2.0519    2.7377    3.2223    3.4308    3.5179    3.7927    4.1928    4.7528    5.3876    5.8085  5.8085    6.1072    6.7515];
    daceyXdeg = 0.1 + 3.4.*daceyXmm + 0.035.*daceyXmm.^2;
    pp = polyfit(daceyXdeg,daceyY,2)
    bistratifiedFraction = @(eccDeg) (eccDeg>0.5).*( pp(1).*eccDeg.^2+pp(2).*eccDeg+pp(3));
    figure
    semilogy(daceyXdeg,daceyY,'ok'); hold on
    semilogy(0:1:90,bistratifiedFraction(0:1:90),'-r')
%}
pp(1) = -0.000002818937309; pp(2) = 0.001127464065019; pp(3) = 0.009832178782458;
bistratifiedFraction = @(eccDeg) (eccDeg>0.5).*( pp(1).*eccDeg.^2+pp(2).*eccDeg+pp(3) );

cellClass = {'midget','parasol','bistratified'};
cellLine = {'-','--',':'};
x = logspace(log10(1),log10(90));

figHandle = figure('Renderer','painters');
figuresize(300,300,'pt');
tiledlayout(3,1,'TileSpacing','tight','Padding','tight')

nexttile
for cc = 1:3

    % At each eccentricity, what fraction of the total number of RGCs is of a
    % given cell class? The parasol denisty is what is left over after we
    % account for midget and bistratified classes.
    switch cellClass{cc}
        case 'midget'
            proportionFunc = @(ecc) midgetFraction(ecc);
        case 'parasol'
            proportionFunc = @(ecc) 1.0-midgetFraction(ecc)-bistratifiedFraction(ecc);
        case 'bistratified'
            proportionFunc = @(ecc) bistratifiedFraction(ecc);
    end

    plot(log10(x),proportionFunc(x),cellLine{cc},'Color','k','LineWidth',2);
    hold on
end

a=gca();
a.XTick = [];
ylabel('Proportion');
box off

nexttile
% Loop over the meridians and obtain the RGCf density functions
meridianAngles = [0 90 180 270];
for mm = 1:4
    totalRGCfDensity{mm} = watsonTotalRFDensityByEccenDegVisual(meridianAngles(mm));
end

% Obtain the mean, total ganglion receptive field density as a function of
% eccentricity
totalRGCfDensityAtEcc = @(eccDeg) mean(cellfun(@(x) x(eccDeg),totalRGCfDensity));

scalefunc = [];
for ii=1:length(x); scalefunc(ii) = totalRGCfDensityAtEcc(x(ii)); end

plot(log10(x),scalefunc,'-k','LineWidth',2)
hold on
a=gca();
a.XTick = [];
ylabel('RFs per deg^2');
box off

nexttile
plot(log10(x),(x/90),'-k','LineWidth',2)
a=gca();
a.XTick = log10([1,10,20,40,80]);
a.XTickLabels = {'1','10','20','40','80'};
xlabel('Eccentricity [deg]');
ylabel('annular area');
box off


plotNamesPDF = ['cellPopulationsIllo.pdf' ];
saveas(figHandle,fullfile(savePath,plotNamesPDF));

