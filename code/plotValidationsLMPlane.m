function [contrast, actualContrasts] = plotValidationsLMPlane(directedDirection,varargin)




p = inputParser;
p.addParameter('showVectors',true,@islogical);
p.addParameter('showPreCorrections',true,@islogical);
p.addParameter('showProjections',true,@islogical);
p.addParameter('showInfoInPlot',true,@islogical);
p.addParameter('infoDump',true,@islogical);
p.addParameter('saveLocation','~/Desktop/',@isstr);
p.parse(varargin{:});
options = p.Results;
saveLocation = options.saveLocation;

% clear screen
clc

% Loop over directions
for ii = 1:length(directedDirection)
    
    % Presize contrast measurement matrix
    actualContrasts  = zeros([size(directedDirection{ii}.describe.validation(1).contrastActual),length(directedDirection{ii}.describe.validation)]);
    
    % Get the desred contrast value for directrion
    desiredContrasts = directedDirection{ii}.describe.validation(1).contrastDesired;
    contrast{ii}.desired.pos2Deg_contrast_total = sqrt(desiredContrasts(1,1).^2 + desiredContrasts(2,1).^2);
    contrast{ii}.desired.neg2Deg_contrast_total = sqrt(desiredContrasts(1,2).^2 + desiredContrasts(2,2).^2);
    contrast{ii}.desired.pos15Deg_contrast_total = sqrt(desiredContrasts(4,1).^2 + desiredContrasts(5,1).^2);
    contrast{ii}.desired.neg15Deg_contrast_total = sqrt(desiredContrasts(4,2).^2 + desiredContrasts(5,2).^2);
    % get desired angle
    [anglesDesired_2Deg,quadrant_2deg] = getAnglesFromContrastMeasurements(directedDirection{ii}.describe.validation(1).contrastDesired(1:2,1:2));
    [anglesDesired_15Deg,quadrant_15deg]  = getAnglesFromContrastMeasurements(directedDirection{ii}.describe.validation(1).contrastDesired(4:5,1:2));
    
    % Get the validation measurements
    for jj = 1:length(directedDirection{ii}.describe.validation)
        actualContrasts(:,:,jj) = directedDirection{ii}.describe.validation(jj).contrastActual;
    end
    
    %% Calculate stuff
    % pre corrections contrast
    preCorrectionsContrast  = median(actualContrasts(:,:,1:5), 3);
    contrast{ii}.preCorrections.pos2Deg_contrast_total = sqrt(preCorrectionsContrast(1,1).^2 + preCorrectionsContrast(2,1).^2);
    contrast{ii}.preCorrections.neg2Deg_contrast_total = sqrt(preCorrectionsContrast(1,2).^2 + preCorrectionsContrast(2,2).^2);
    contrast{ii}.preCorrections.pos15Deg_contrast_total = sqrt(preCorrectionsContrast(4,1).^2 + preCorrectionsContrast(5,1).^2);
    contrast{ii}.preCorrections.neg15Deg_contrast_total = sqrt(preCorrectionsContrast(4,1).^2 + preCorrectionsContrast(5,1).^2);
    contrast{ii}.preCorrections.pos2Deg_deltaL  = abs(preCorrectionsContrast(1,1) - desiredContrasts(1,1));
    contrast{ii}.preCorrections.pos2Deg_deltaM  = abs(preCorrectionsContrast(2,1) - desiredContrasts(2,1));
    contrast{ii}.preCorrections.pos15Deg_deltaL = abs(preCorrectionsContrast(4,1) - desiredContrasts(4,1));
    contrast{ii}.preCorrections.pos15Deg_deltaM = abs(preCorrectionsContrast(5,1) - desiredContrasts(5,1));
    
    % post correction contrast
    postCorrectionsContrast = median(actualContrasts(:,:,6:10), 3);
    contrast{ii}.postCorrections.pos2Deg_contrast_total = sqrt(postCorrectionsContrast(1,1).^2 + postCorrectionsContrast(2,1).^2);
    contrast{ii}.postCorrections.pos15Deg_contrast_total = sqrt(postCorrectionsContrast(4,1).^2 + postCorrectionsContrast(5,1).^2);
    contrast{ii}.postCorrections.neg2Deg_contrast_total = sqrt(postCorrectionsContrast(1,2).^2 + postCorrectionsContrast(2,2).^2);
    contrast{ii}.postCorrections.neg15Deg_contrast_total = sqrt(postCorrectionsContrast(4,2).^2 + postCorrectionsContrast(5,2).^2);
    contrast{ii}.postCorrections.deg_2_deltaL  = abs(postCorrectionsContrast(1,1) - desiredContrasts(1,1));
    contrast{ii}.postCorrections.deg_2_deltaM  = abs(postCorrectionsContrast(2,1) - desiredContrasts(2,1));
    contrast{ii}.postCorrections.deg_15_deltaL = abs(postCorrectionsContrast(4,1) - desiredContrasts(4,1));
    contrast{ii}.postCorrections.deg_15_deltaM = abs(postCorrectionsContrast(5,1) - desiredContrasts(5,1));
    [anglesPostCor_2Deg] = getAnglesFromContrastMeasurements(postCorrectionsContrast(1:2,1:2));
    
    % Post experiment contrast
    postExperimentContrast  = median(actualContrasts(:,:,11:15),3);
    contrast{ii}.postExperiment.pos2Deg_contrast_total = sqrt(postExperimentContrast(1,1).^2 + postExperimentContrast(2,1).^2);
    contrast{ii}.postExperiment.pos15Deg_contrast_total = sqrt(postExperimentContrast(4,1).^2 + postExperimentContrast(5,1).^2);
    contrast{ii}.postExperiment.neg2Deg_contrast_total = sqrt(postExperimentContrast(1,2).^2 + postExperimentContrast(2,2).^2);
    contrast{ii}.postExperiment.neg15Deg_contrast_total = sqrt(postExperimentContrast(4,2).^2 + postExperimentContrast(5,2).^2);
    contrast{ii}.postExperiment.deg_2_deltaL  = abs(postExperimentContrast(1,1) - desiredContrasts(1,1));
    contrast{ii}.postExperiment.deg_2_deltaM  = abs(postExperimentContrast(2,1) - desiredContrasts(2,1));
    contrast{ii}.postExperiment.deg_15_deltaL = abs(postExperimentContrast(4,1) - desiredContrasts(4,1));
    contrast{ii}.postExperiment.deg_15_deltaM = abs(postExperimentContrast(5,1) - desiredContrasts(5,1));
    [anglesPostExp_2Deg] = getAnglesFromContrastMeasurements(postExperimentContrast(1:2,1:2));
    
    % Mean of the post corrections and the post experiment medians
    meanOfmedianExpContrast = mean(cat(3,postCorrectionsContrast,postExperimentContrast),3);
    contrast{ii}.meanOfmedianExpContrast.pos2Deg_contrast_total = sqrt(meanOfmedianExpContrast(1,1).^2 + meanOfmedianExpContrast(2,1).^2);
    contrast{ii}.meanOfmedianExpContrast.pos15Deg_contrast_total = sqrt(meanOfmedianExpContrast(4,1).^2 + meanOfmedianExpContrast(5,1).^2);
    contrast{ii}.meanOfmedianExpContrast.neg2Deg_contrast_total = sqrt(meanOfmedianExpContrast(1,2).^2 + meanOfmedianExpContrast(2,2).^2);
    contrast{ii}.meanOfmedianExpContrast.neg15Deg_contrast_total = sqrt(meanOfmedianExpContrast(4,2).^2 + meanOfmedianExpContrast(5,2).^2);
    contrast{ii}.meanOfmedianExpContrast.deg_2_deltaL  = abs(meanOfmedianExpContrast(1,1) - desiredContrasts(1,1));
    contrast{ii}.meanOfmedianExpContrast.deg_2_deltaM  = abs(meanOfmedianExpContrast(2,1) - desiredContrasts(2,1));
    contrast{ii}.meanOfmedianExpContrast.deg_15_deltaL = abs(meanOfmedianExpContrast(4,1) - desiredContrasts(4,1));
    contrast{ii}.meanOfmedianExpContrast.deg_15_deltaM = abs(meanOfmedianExpContrast(5,1) - desiredContrasts(5,1));
    [anglesMean_2Deg] = getAnglesFromContrastMeasurements(meanOfmedianExpContrast(1:2,1:2));
    
    %% Plot the validation information ------------------------------------
    figure;
    %suptitle(sprintf('Validation Plots for %.1f and %.1f',anglesDesired_2Deg(1), anglesDesired_2Deg(2)))
    
    %% Plots for central 2 deg --------------------------------------------
    subplot(1,2,1);hold on
    title('2 Degrees')
    axis square
    scaleVal = max(abs(actualContrasts(:)))+0.1*max(abs(actualContrasts(:)));
    plot(scaleVal.*[-1,1],[0,0],'k--')
    plot([0,0],scaleVal.*[1,-1],'k--')
    
    % If set to true, this will show the vector components as dashed lines
    if options.showProjections
        % Desired contrast
        plot([desiredContrasts(1,1),desiredContrasts(1,1)],[desiredContrasts(2,1),0],'k--')
        plot([desiredContrasts(1,1),0],[desiredContrasts(2,1),desiredContrasts(2,1)],'k--')
        plot([desiredContrasts(1,2),desiredContrasts(1,2)],[desiredContrasts(2,2),0],'k--')
        plot([desiredContrasts(1,2),0],[desiredContrasts(2,2),desiredContrasts(2,2)],'k--')
        % Post corrections
        plot([postCorrectionsContrast(1,1),postCorrectionsContrast(1,1)],[postCorrectionsContrast(2,1),0],'b--')
        plot([postCorrectionsContrast(1,1),0],[postCorrectionsContrast(2,1),postCorrectionsContrast(2,1)],'b--')
        plot([postCorrectionsContrast(1,2),postCorrectionsContrast(1,2)],[postCorrectionsContrast(2,2),0],'b--')
        plot([postCorrectionsContrast(1,2),0],[postCorrectionsContrast(2,2),postCorrectionsContrast(2,2)],'b--')
        % Post experiment
        plot([postExperimentContrast(1,1),postExperimentContrast(1,1)],[postExperimentContrast(2,1),0],'g--')
        plot([postExperimentContrast(1,1),0],[postExperimentContrast(2,1),postExperimentContrast(2,1)],'g--')
        plot([postExperimentContrast(1,2),postExperimentContrast(1,2)],[postExperimentContrast(2,2),0],'g--')
        plot([postExperimentContrast(1,2),0],[postExperimentContrast(2,2),postExperimentContrast(2,2)],'g--')
        % Mean of the medians
        plot([meanOfmedianExpContrast(1,1),meanOfmedianExpContrast(1,1)],[meanOfmedianExpContrast(2,1),0],'r--')
        plot([meanOfmedianExpContrast(1,1),0],[meanOfmedianExpContrast(2,1),meanOfmedianExpContrast(2,1)],'r--')
        plot([meanOfmedianExpContrast(1,2),meanOfmedianExpContrast(1,2)],[meanOfmedianExpContrast(2,2),0],'r--')
        plot([meanOfmedianExpContrast(1,2),0],[meanOfmedianExpContrast(2,2),meanOfmedianExpContrast(2,2)],'r--')
    end
    
    % If set to true this will show the vectors from the origin to points
    % of interest. the length of this vector is the contrast.
    if options.showVectors
        % Desired contrast
        plotv([desiredContrasts(1,1);desiredContrasts(2,1)],'k')
        plotv([desiredContrasts(1,2);desiredContrasts(2,2)],'k')
        % Post corrections
        plotv([postCorrectionsContrast(1,1);postCorrectionsContrast(2,1)],'b')
        plotv([postCorrectionsContrast(1,2);postCorrectionsContrast(2,2)],'b')
        % Post experiment
        plotv([postExperimentContrast(1,1);postExperimentContrast(2,1)],'g')
        plotv([postExperimentContrast(1,2);postExperimentContrast(2,2)],'g')
        % Mean of the medians
        plotv([meanOfmedianExpContrast(1,1);meanOfmedianExpContrast(2,1)],'r')
        plotv([meanOfmedianExpContrast(1,2);meanOfmedianExpContrast(2,2)],'r')
    end
    
    % Plot the desired contrast
    p1  = scatter(desiredContrasts(1,1),desiredContrasts(2,1),140,[0,0,0],'filled','^');
    scatter(desiredContrasts(1,2),desiredContrasts(2,2),140,[0,0,0],'filled','^')
    
    % Plot the post corrections median actual contrast
    p2 = scatter(postCorrectionsContrast(1,1),postCorrectionsContrast(2,1),140,[0,0,1],'filled','d');
    scatter(postCorrectionsContrast(1,2),postCorrectionsContrast(2,2),140,[0,0,1],'filled','d')
    
    % Plot each post corrections actual contrast
    scatter(actualContrasts(1,1,6:10),actualContrasts(2,1,6:10),40,[0.2,0.7,1.0],'filled')
    scatter(actualContrasts(1,2,6:10),actualContrasts(2,2,6:10),40,[0.2,0.7,1.0],'filled')
    
    % Plot the post experiment median actual contrast
    p3 = scatter(postExperimentContrast(1,1),postExperimentContrast(2,1),140,[0,1,0],'filled','d');
    scatter(postExperimentContrast(1,2),postExperimentContrast(2,2),140,[0,1,0],'filled','d')
    
    % Plot each post experiment actual contrast
    scatter(actualContrasts(1,1,11:15),actualContrasts(2,1,11:15),40,[0,0.26,.15],'filled')
    scatter(actualContrasts(1,2,11:15),actualContrasts(2,2,11:15),40,[0,0.26,.15],'filled')
    
    % Plot mean of the medians
    p4 = scatter(meanOfmedianExpContrast(1,1),meanOfmedianExpContrast(2,1),140,[1,0,0],'filled','d');
    scatter(meanOfmedianExpContrast(1,2),meanOfmedianExpContrast(2,2),140,[1,0,0],'filled','d')
    
    if options.showInfoInPlot
        % set coordinates for text to appear based on were data points are
        if quadrant_2deg(1) == 1 || 3
            xPos = scaleVal.*[-1.0];
            yPos = scaleVal.*[-1.25];
        elseif quadrant_2deg(1) == 2 || 4
            xPos = scaleVal.*[-1.0];
            yPos = scaleVal.*[-1.25];
        end
        % Create text to display
        textToShow = {sprintf('*Stimulus Angle*'), ...
                      sprintf('\tDesired Theta: pos %.2f, neg %.2f', anglesDesired_2Deg(1), anglesDesired_2Deg(2)),...
                      sprintf('\tpostCor Theta: pos %.2f, neg %.2f', anglesPostCor_2Deg(1), anglesPostCor_2Deg(2)),...
                      sprintf('\tpostExp Theta: pos %.2f, neg %.2f', anglesPostExp_2Deg(1), anglesPostExp_2Deg(2)),...
                      sprintf('\tmean Theta   : pos %.2f, neg %.2f', anglesMean_2Deg(1), anglesMean_2Deg(2))};
        % Show Text
        text(xPos,yPos,textToShow)
    end
    
    % Dump info to screen
    if options.infoDump
        
        fprintf('Stim %.0f Validations Info: \n',ii)
        
        % Angles info
        fprintf('*Stimulus Angle*\n')
        fprintf('\tDesired Theta: pos %.2f, neg %.2f\n', anglesDesired_2Deg(1), anglesDesired_2Deg(2))
        fprintf('\tpostCor Theta: pos %.2f, neg %.2f\n', anglesPostCor_2Deg(1), anglesPostCor_2Deg(2))
        fprintf('\tpostExp Theta: pos %.2f, neg %.2f\n', anglesPostExp_2Deg(1), anglesPostExp_2Deg(2))
        fprintf('\tmean Theta   : pos %.2f, neg %.2f\n', anglesMean_2Deg(1), anglesMean_2Deg(2))
        
        % Contrast info
        fprintf('*Stimulus Contrast*\n')
        fprintf('\tDesired = pos %.2f, neg %.2f\n',contrast{ii}.desired.pos2Deg_contrast_total,contrast{ii}.desired.neg2Deg_contrast_total)
        fprintf('\tpostCor = pos %.2f, neg %.2f\n',contrast{ii}.postCorrections.pos2Deg_contrast_total,contrast{ii}.postCorrections.neg2Deg_contrast_total)
        fprintf('\tpostExp = pos %.2f, neg %.2f\n',contrast{ii}.postExperiment.pos2Deg_contrast_total,contrast{ii}.postExperiment.neg2Deg_contrast_total)
        fprintf('\tmean    = pos %.2f, neg %.2f\n', contrast{ii}.meanOfmedianExpContrast.pos2Deg_contrast_total,contrast{ii}.meanOfmedianExpContrast.neg2Deg_contrast_total);
        
        % L Cone contrast
        
        % M Cone contrast
        
        % S Cone contrast
        
        fprintf('\n')
    end
    
    legend([p1, p2, p3, p4], {'Desired', 'Post Corrections', 'Post Experiemnt', 'Mean of Post Corr. and Post Exp.'})
    xlim(scaleVal.*[-1,1])
    ylim(scaleVal.*[-1,1])
    
    %% Plots for central 15 deg -------------------------------------------
    subplot(1,2,2);hold on
    title('15 Degrees')
    axis square
    plot(scaleVal.*[-1,1],[0,0],'k--')
    plot([0,0],scaleVal.*[1,-1],'k--')
    
    % If set to true, this will show the vector components as dashed lines
    if options.showProjections
        % Desired contrast
        plot([desiredContrasts(4,1),desiredContrasts(4,1)],[desiredContrasts(5,1),0],'k--')
        plot([desiredContrasts(4,1),0],[desiredContrasts(5,1),desiredContrasts(5,1)],'k--')
        plot([desiredContrasts(4,2),desiredContrasts(4,2)],[desiredContrasts(5,2),0],'k--')
        plot([desiredContrasts(4,2),0],[desiredContrasts(5,2),desiredContrasts(5,2)],'k--')
        % Post corrections
        plot([postCorrectionsContrast(4,1),postCorrectionsContrast(4,1)],[postCorrectionsContrast(5,1),0],'b--')
        plot([postCorrectionsContrast(4,1),0],[postCorrectionsContrast(5,1),postCorrectionsContrast(5,1)],'b--')
        plot([postCorrectionsContrast(4,2),postCorrectionsContrast(4,2)],[postCorrectionsContrast(5,2),0],'b--')
        plot([postCorrectionsContrast(4,2),0],[postCorrectionsContrast(5,2),postCorrectionsContrast(5,2)],'b--')
        % Post experiment
        plot([postExperimentContrast(4,1),postExperimentContrast(4,1)],[postExperimentContrast(5,1),0],'g--')
        plot([postExperimentContrast(4,1),0],[postExperimentContrast(5,1),postExperimentContrast(5,1)],'g--')
        plot([postExperimentContrast(4,2),postExperimentContrast(4,2)],[postExperimentContrast(5,2),0],'g--')
        plot([postExperimentContrast(4,2),0],[postExperimentContrast(5,2),postExperimentContrast(5,2)],'g--')
        % Mean of the medians
        plot([meanOfmedianExpContrast(4,1),meanOfmedianExpContrast(4,1)],[meanOfmedianExpContrast(5,1),0],'r--')
        plot([meanOfmedianExpContrast(4,1),0],[meanOfmedianExpContrast(5,1),meanOfmedianExpContrast(5,1)],'r--')
        plot([meanOfmedianExpContrast(4,2),meanOfmedianExpContrast(4,2)],[meanOfmedianExpContrast(5,2),0],'r--')
        plot([meanOfmedianExpContrast(4,2),0],[meanOfmedianExpContrast(5,2),meanOfmedianExpContrast(5,2)],'r--')
    end
    
    % If set to true this will show the vectors from the origin to points
    % of interest. the length of this vector is the contrast.
    if options.showVectors
        % Desired contrast
        plotv([desiredContrasts(4,1);desiredContrasts(5,1)],'k')
        plotv([desiredContrasts(4,2);desiredContrasts(5,2)],'k')
        % Post corrections
        plotv([postCorrectionsContrast(4,1);postCorrectionsContrast(5,1)],'b')
        plotv([postCorrectionsContrast(4,2);postCorrectionsContrast(5,2)],'b')
        % Post experiment
        plotv([postExperimentContrast(4,1);postExperimentContrast(5,1)],'g')
        plotv([postExperimentContrast(4,2);postExperimentContrast(5,2)],'g')
        % Mean of the medians
        plotv([meanOfmedianExpContrast(4,1);meanOfmedianExpContrast(5,1)],'r')
        plotv([meanOfmedianExpContrast(4,2);meanOfmedianExpContrast(5,2)],'r')
    end
    
    % Plot the desired contrast
    scatter(desiredContrasts(4,1),desiredContrasts(5,1),100,[0,0,0],'filled','^')
    scatter(desiredContrasts(4,2),desiredContrasts(5,2),100,[0,0,0],'filled','^')
    
    % Plot the post corrections median actual contrast
    scatter(postCorrectionsContrast(4,1),postCorrectionsContrast(5,1),100,[0,0,1],'filled','d')
    scatter(postCorrectionsContrast(4,2),postCorrectionsContrast(5,2),100,[0,0,1],'filled','d')
    
    % Plot each post corrections actual contrast
    scatter(actualContrasts(4,1,6:10),actualContrasts(5,1,6:10),40,[0.2,0.7,1.0],'filled')
    scatter(actualContrasts(4,2,6:10),actualContrasts(5,2,6:10),40,[0.2,0.7,1.0],'filled')
    
    % Plot the post experiment median actual contrast
    scatter(postExperimentContrast(4,1),postExperimentContrast(5,1),100,[0,1,0],'filled','d')
    scatter(postExperimentContrast(4,2),postExperimentContrast(5,2),100,[0,1,0],'filled','d')
    
    % Plot each post experiment actual contrast
    scatter(actualContrasts(4,1,11:15),actualContrasts(5,1,11:15),40,[0,0.26,.15],'filled')
    scatter(actualContrasts(4,2,11:15),actualContrasts(5,2,11:15),40,[0,0.26,.15],'filled')
    
    % Plot mean of the medians
    scatter(meanOfmedianExpContrast(4,1),meanOfmedianExpContrast(5,1),100,[1,0,0],'filled','d')
    scatter(meanOfmedianExpContrast(4,2),meanOfmedianExpContrast(5,2),100,[1,0,0],'filled','d')
    
    xlim(scaleVal.*[-1,1])
    ylim(scaleVal.*[-1,1])
    
    
    % save out plots 
    outFile = fullfile(saveLocation,['validationPlot_' num2str(ii) '.pdf']);

    saveas(gcf,outFile)
end
