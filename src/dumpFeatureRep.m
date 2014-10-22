function feature = dumpFeatureRep(options)
% DUMPFEATUREREP reads all images in the directory, clips using the segmentation
% images and dumps the feature representation in cache

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

fullpaths = cellfun(@(x) fullfile(imgsDir, x), frpaths, 'UniformOutput', false);
if ~isempty(segImgsPath) && exist(segImgsPath, 'dir')
    segDir = segImgsPath;
    fprintf('Will use segment information from %s\n', segDir);
    fprintf('Takes the black region features only\n');
end

all_features = [];
for i = 1 : numel(fullpaths)
    try
        I = imread(fullpaths{i});
    catch
        fprintf(2, 'Unable to read %s\n', fullpaths{i});
        continue;
    end
    
    [path, fname, ~] = fileparts(frpaths{i});

    try
        segMap = imread(fullfile(segDir, path, [fname, options.segExt]));
        feature = computeFeatureRep(I, options, 'segMap', segMap);
    catch
        feature = computeFeatureRep(I, options);
    end

    features_dpath = fullfile(options.cacheDir, options.featureDir, ...
            path);
    system(['mkdir -p ' features_dpath]);
    save(fullfile(features_dpath, [fname, '.mat']), 'feature');
end


