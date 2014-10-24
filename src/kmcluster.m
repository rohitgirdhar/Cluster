function [C, A] = kmcluster(options)

imgsDir = options.dataset;
segImgsPath = options.segImgsDir;
imgsListFpath = options.imgsList;

%% Get imgs list
if isempty(imgsListFpath) || ~exist(imgsListFpath, 'file')
    frpaths = getImgFilesList(imgsDir);
else
    fid = fopen(imgsListFpath, 'r');
    frpaths = textscan(fid, '%s', 'Delimiter', '\n');
    frpaths = frpaths{:};
    fclose(fid);
end

all_features = [];
for i = 1 : numel(frpaths)
    [path, fname, ~] = fileparts(frpaths{i});
    features_dpath = fullfile(options.cacheDir, options.featureDir, path);
    load(fullfile(features_dpath, [fname, '.mat']), 'feature');
    all_features = [all_features; feature];
end
fprintf('Read all features (%d)\n', size(all_features, 1));

%[C, A] = vl_kmeans(all_features', options.K, 'Verbose', 'Algorithm', 'ANN');
[A, C] = kmeans(all_features, options.K);
system(['mkdir -p ' options.resultsDir]);
save(fullfile(options.resultsDir, ['kmeans_' ...
            options.clusterFeature '_' num2str(options.K) '.mat']), 'C', 'A');

fid = fopen(fullfile(options.resultsDir, ['kmeans_' ...
            options.clusterFeature '_' num2str(options.K) '.txt']), 'w');
for cls = unique(A(:))'
    selected = frpaths(A == cls);
    fprintf(fid, '%s\n', strjoin(selected', ' '));
end
fclose(fid);

