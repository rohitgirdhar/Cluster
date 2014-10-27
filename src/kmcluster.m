function [C, A] = kmcluster(options)

imgsDir = options.dataset;
imgsListFpath = '';
if isfield(options, 'imgsList')
    imgsListFpath = options.imgsList;
end

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
    if strcmp(options.featureExt, '.mat')
        load(fullfile(features_dpath, [fname, '.mat']), 'feature');
    elseif strcmp(options.featureExt, '.txt')
        feature = readTxt(fullfile(features_dpath, [fname, '.txt']));
    end
    all_features = [all_features; feature];
end
fprintf('Read all features (%d)\n', size(all_features, 1));


system(['mkdir -p ' options.resultsDir]);
kmeans_cache_file = fullfile(options.resultsDir, ['kmeans_' ...
            options.clusterFeature '_' num2str(options.K) '.mat']);
if ~exist(kmeans_cache_file, 'file')
%    [C, A] = vl_kmeans(all_features', options.K, 'Verbose', 'Algorithm', 'ANN');
    [A, C, ~, D] = kmeans(all_features, options.K);
    save(kmeans_cache_file, 'C', 'A', 'D');
else 
    load(kmeans_cache_file, 'C', 'A', 'D');
end
D = cat(1, D, inf(size(A, 1) - size(D, 1), options.K));

fid = fopen(fullfile(options.resultsDir, ['kmeans_' ...
            options.clusterFeature '_' num2str(options.K) '.txt']), 'w');
for cls = 1 : options.K
    mask = A == cls;
    selected = [];
    if ~all(mask == 0) % if at least one element got assigned this label
        selected = frpaths(mask);
        cls
        selected_D = D(mask, cls);
        [~, order] = sort(selected_D);
        selected = selected(order);
    end
    fprintf(fid, '%s\n', strjoin(selected', ' '));
end
fclose(fid);

function feature = readTxt(fpath)
fid = fopen(fpath);
feature = textscan(fid, '%f\n');
fclose(fid);
feature = feature{1};
feature = feature(:)';

