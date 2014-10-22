function saveFeatureVisualization(I, feature, out_fpath, options)

if strcmp(options.clusterFeature, 'color-hist')
    figure('Visible', 'off');
    plot(feature);
    [~, ~, ext] = fileparts(out_fpath);
    saveas(gcf, out_fpath, ext(2 : end));
    close all;
else
    fprintf('Feature visulization for %s not implemented yet\n', ...
            options.clusterFeature);
end

