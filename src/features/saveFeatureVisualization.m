function saveFeatureVisualization(I, feature, featVis, out_fpath, options)

if strcmp(options.clusterFeature, 'color-hist')
    figure('Visible', 'off');
    plot(feature);
    [~, ~, ext] = fileparts(out_fpath);
    saveas(gcf, out_fpath, ext(2 : end));
    close all;
elseif strcmp(options.clusterFeature, 'dsift')
    figure('Visible', 'off');
    imagesc(featVis);
    [~, ~, ext] = fileparts(out_fpath);
    saveas(gcf, out_fpath, ext(2 : end))
    close all;
else
    fprintf('Feature visulization for %s not implemented yet\n', ...
            options.clusterFeature);
end

