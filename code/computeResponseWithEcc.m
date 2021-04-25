function [] = computeResponseWithEcc(subjId, varargin)
% Calculate the L-M and L+M ellipse distance with eccentriciry and plots it
%
% Syntax:
%   [figHndl] = calcEllipseDistWithEcc(subjId, varargin)
%
% Description:
%    This function takes in a cell array of packets and returns one packet
%    with a the fields being a concatenation of all the input packets.
%
% Inputs:
%    subjId                     - String with subject ID
% Outputs:
%    figHndl                    - Figure Handle
%
% Optional key/value pairs:
%    saveFigs                   - Logical flag to save the figure

% MAB 03/10/20 Wrote it.
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjId',@ischar);
p.addParameter('LminMcontrast',0.08,@isnumeric)
p.addParameter('LplusMcontrast',0.48,@isnumeric)
p.addParameter('saveFigs',false,@islogical)
p.parse(subjId,varargin{:});

% load subject params
analysisParams = getSubjectParams(subjId);

% This is sent the getSubjectParams function
hemi  = analysisParams.hemisphere;

%% LOAD THE PARAMTER MAP
% Path the subject map data
dropBoxPath     = fullfile(getpref(analysisParams.projectName,'melaAnalysisPath'),analysisParams.projectName);
mapSavePath    = fullfile(dropBoxPath,'surfaceMaps',analysisParams.expSubjID,'V1');

% get the map names
% minorAxis
minorAxisMapName = fullfile(mapSavePath,['minorAxisMap_', analysisParams.sessionNickname '.dscalar.nii']);
% angle
angleMapName = fullfile(mapSavePath,['angleMap_', analysisParams.sessionNickname '.dscalar.nii']);
% amplitude
ampMapName = fullfile(mapSavePath,['nlAmpMap_', analysisParams.sessionNickname '.dscalar.nii']);
% semisaturation point
semiMapName = fullfile(mapSavePath,['nlSemiMap_', analysisParams.sessionNickname '.dscalar.nii']);
% exponent
expMapName = fullfile(mapSavePath,['nlExpMap_', analysisParams.sessionNickname '.dscalar.nii']);
% crfOffset
offMapName = fullfile(mapSavePath,['nlOffset_', analysisParams.sessionNickname '.dscalar.nii']);


% Load the paramter map
minorAxisVals = loadCIFTI(minorAxisMapName);
angleVals = loadCIFTI(angleMapName);
ampVals = loadCIFTI(ampMapName);
semisatVals = loadCIFTI(semiMapName);
expVals = loadCIFTI(expMapName);
offsetVals = loadCIFTI(offMapName);

%% LOAD THE RETINO MAPS
% Path the benson atlas maps

pathToBensonMasks = fullfile(getpref(analysisParams.projectName,'melaAnalysisPath'), 'mriTOMEAnalysis','flywheelOutput','benson');

if strcmp(hemi, 'lh')
    pathToLHLhEccFile = fullfile(pathToBensonMasks,'lh.benson14_eccen.dscalar.nii');
    eccMap = loadCIFTI(pathToLHLhEccFile);
    
elseif strcmp(hemi, 'rh')
    pathToRhEccFile = fullfile(pathToBensonMasks, 'rh.benson14_eccen.dscalar.nii');
    eccMap = loadCIFTI(pathToRhEccFile);
    
elseif strcmp(hemi, 'combined')
    % Load lh and rh maps
    pathToLHLhEccFile = fullfile(pathToBensonMasks,'lh.benson14_eccen.dscalar.nii');
    lhEccMap = loadCIFTI(pathToLHLhEccFile);
    pathToRhEccFile = fullfile(pathToBensonMasks,'rh.benson14_eccen.dscalar.nii');
    rhEccMap = loadCIFTI(pathToRhEccFile);
    
    % convert nan to 0 and combine maps
    lhEccMap(find(isnan(lhEccMap))) = 0;
    rhEccMap(find(isnan(rhEccMap))) = 0;
    eccMap = lhEccMap +rhEccMap;
else
    error('Map type not found');
end

%% LOAD THE MASK USED IN THE ANALYSIS
maskRoiPath  = fullfile(getpref(analysisParams.projectName,'melaAnalysisPath'),'LFContrastAnalysis','MNI_ROIs');
maskName     = ['V', num2str(analysisParams.areaNum), '_', analysisParams.hemisphere, '_ecc_', num2str(analysisParams.eccenRange(1)), '_to_', num2str(analysisParams.eccenRange(2)),'.dscalar.nii'];
maskFullFile = fullfile(maskRoiPath,maskName);
maskMatrix = loadCIFTI(maskFullFile);
voxelIndex = find(maskMatrix);

%% Get the L-M and L+M dist
lMinusMmap = zeros(91282,1);
lPlusMmap = zeros(91282,1);

defaultParamsInfo.noOffset = false;
qcmTcOBJ = tfeQCMDirection('verbosity','none','dimension',analysisParams.theDimension);

%check
lPlusMstim  = [cosd(45),sind(45),p.Results.LplusMcontrast]';
lMinusMstim = [cosd(315),sind(315),p.Results.LminMcontrast]';
testStim.values = [lPlusMstim,lMinusMstim];
testStim.timebase = [1,2];
kernel = []; 

for ii = 1:length(voxelIndex)
    qcmParams.Qvec        = [minorAxisVals(voxelIndex(ii)), angleVals(voxelIndex(ii))];
    qcmParams.crfAmp      = ampVals(voxelIndex(ii));
    qcmParams.crfSemi     = semisatVals(voxelIndex(ii));
    qcmParams.crfExponent = expVals(voxelIndex(ii));
    qcmParams.crfOffset   = offsetVals(voxelIndex(ii));
    qcmParams.expFalloff  =  0.3000; % unused
    
    theModelPred = qcmTcOBJ.computeResponse(qcmParams,testStim,kernel);
    
    LplusMresponse(ii)  = theModelPred.values(1);
    LminusMresponse(ii) = theModelPred.values(2);
    
end

%% APPLY THE MASK and remove nans
eccSatterPoints    = eccMap(voxelIndex);

%% PLOT IT
figHndl = figure;
hold on;
% Set the figure's size in inches
figureSizeInches = [12 8];
figHndl.Units = 'inches';

markerSize = 9;
markerAreaPtsSquared = markerSize^2;
lPlusM_color = [107, 107, 107]./255;
lMinusM_color= [156, 28, 19]./255;

lPlusM_lm = fitlm(eccSatterPoints,LplusMresponse,'RobustOpts','on');
regLinelPlusMParams = lPlusM_lm.Coefficients.Variables;
regLinelPlusM = @(x) regLinelPlusMParams(2,1).*x + regLinelPlusMParams(1,1);

lMinusM_lm = fitlm(eccSatterPoints,LminusMresponse,'RobustOpts','on');
regLinelMinusMParams = lMinusM_lm.Coefficients.Variables;
regLinelMinusM = @(x) regLinelMinusMParams(2,1).*x + regLinelMinusMParams(1,1);

scatter(eccSatterPoints,LminusMresponse, markerAreaPtsSquared, 'o', ...
    'LineWidth', 1.0, 'MarkerFaceColor',lMinusM_color, 'MarkerEdgeColor',lMinusM_color*.8);

scatter(eccSatterPoints,LplusMresponse, markerAreaPtsSquared, 'o', ...
    'LineWidth', 1.0, 'MarkerFaceColor',lPlusM_color, 'MarkerEdgeColor',lPlusM_color*.8);


xPts = [min(eccSatterPoints), max(eccSatterPoints)];

yPtslPlusM = regLinelPlusM(xPts);
p1 = line(xPts,yPtslPlusM,'Color',lPlusM_color*1.4,'LineWidth',3);

yPtslMinusM = regLinelMinusM(xPts);
p2 = line(xPts,yPtslMinusM,'Color',lMinusM_color*1.25,'LineWidth',3);

% add text
modelTxtTheta = sprintf('L+M slope = %s offset = %s',...
    num2str(regLinelPlusMParams(2,1),3), num2str(regLinelPlusMParams(1,1),3));
theTextHandle = text(gca, 1,4.6 , modelTxtTheta, 'Interpreter', 'latex');
set(theTextHandle,'FontSize', 13, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);

modelTxtTheta = sprintf('L-M slope = %s offset = %s',...
    num2str(regLinelMinusMParams(2,1),3), num2str(regLinelMinusMParams(1,1),3));
theTextHandle = text(gca, 1,4.2 , modelTxtTheta, 'Interpreter', 'latex');
set(theTextHandle,'FontSize', 13, 'Color', [0.3 0.3 0.3], 'BackgroundColor', [1 1 1]);
xlabel('Eccentricity (Degrees)');

yString = 'Response';
ylim([-.5 5]);
legend([p1 p2],{'L+M','L-M'});
ylabel(yString);

title('Threshold By Eccentricity');

set(gca, ...
    'XColor', [0.2 0.2 0.2], ...
    'YColor', [0.2 0.2 0.2], ...
    'FontName', 'Helvetica', ...
    'FontSize', 14, ...
    'FontWeight', 'normal', ...
    'TickLength',[0.01 0.01], ...
    'TickDir', 'out', ...
    'LineWidth', 0.7, ...
    'Box', 'off');

if p.Results.saveFigs
    set(figHndl, 'Renderer', 'Painters');
    set(figHndl, 'PaperSize',figureSizeInches);
    set(figHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
    % Full file name
    figName =  fullfile(getpref(analysisParams.projectName,'figureSavePath'),analysisParams.expSubjID, ...
        [analysisParams.expSubjID,'_scatterEllipseRespEcc_' analysisParams.sessionNickname '_hcp.pdf']);
    % Save it
    print(figHndl, figName, '-dpdf', '-r300');
end
end
