function model = computeVocab(imgsDir, params, varargin)
% Read all images recursively in imgsDir and learn a vocabulary by AKM
% Optional param
% 'imgsListFpath', 'path/to/file.txt' :- File contains a newline separated
% list of image paths (relative to imgsDir) of the image files to 
% build index upon. Typically used to set the train set.
% 'avgSiftsPerImg', <count> :- (default: 1000). Used to pre-allocate the
% storage array. Give an upper bound estimate. But take care that num_imgs
% * avg_sift memory will be allocated.. so it may crash if the machine 
% can't handle it.
% params.numWords = size of voacbulary to learn
% params.maxImgsForVocab = max number of images to use for computing it

p = inputParser;
addOptional(p, 'imgsListFpath', 0); % dir with all the images
addOptional(p, 'segImgsPath', 0); % directory with segmentation images
addOptional(p, 'alpha', 10000); % number of descriptors to sample from each image
parse(p, varargin{:});

%% Get imgs list
if p.Results.imgsListFpath == 0
    frpaths = getImgFilesList(imgsDir);
else
    fid = fopen(p.Results.imgsListFpath, 'r');
    frpaths = textscan(fid, '%s', 'Delimiter', '\n');
    frpaths = frpaths{:};
    fclose(fid);
end
fullpaths = cellfun(@(x) fullfile(imgsDir, x), frpaths, 'UniformOutput', false);
if p.Results.segImgsPath ~= 0
    segDir = p.Results.segImgsPath;
    fprintf('Will use segment information from %s\n', segDir);
    fprintf('Takes the black region features only\n');
end

if ~isfield(params, 'maxImgsForVocab')
    params.maxImgsForVocab = 10000;
end
if numel(fullpaths) > params.maxImgsForVocab
    fprintf('Too many images (%d), randomly sampling %d of those\n', ...
            numel(fullpaths), params.maxImgsForVocab);
    sample = randsample(numel(fullpaths), params.maxImgsForVocab);
    fullpaths = fullpaths(sample);
    frpaths = frpaths(sample);
end

all_features = [];
fprintf('Reading images..\n');
for i = 1 : numel(fullpaths)
    % best to read one by one, in case of large number of images
    try
        I = imread(fullpaths{i});
    catch
        fprintf(2, 'Unable to read %s\n', fullpaths{i});
        continue;
    end
    if size(I, 3) ~= 3
        continue;
    end
    feature = dsift(I);
    feature_reshaped = reshape(feature, size(feature, 1) * size(feature, 2), ...
            [], 1);
    if p.Results.segImgsPath ~= 0
        try
            segImg = imread(fullfile(segDir, strrep(frpaths{i}, '.jpg', '.png')));
            if ~islogical(segImg)
                segImg = logical(segImg);
            end
            % since I count the background (black) features
            segImg = ~segImg;
            segImg = reshape(segImg, size(segImg, 1) * size(segImg, 2), 1);
            feature_reshaped = feature_reshaped(segImg, :);
        catch
        end
    end
    feature_reshaped = feature_reshaped(randperm(size(feature_reshaped, 1), ...
                min(p.Results.alpha, size(feature_reshaped, 1))), :);
    all_features = [all_features; feature_reshaped];
    fprintf('Read %d features from %s\n', size(feature_reshaped, 1), frpaths{i});
end

fprintf('Found %d descriptors. Clustering now...\n', size(all_features, 1));

%% K Means cluster the SIFTs, and create a model
model.vocabSize = params.numWords;
model.vocab = vl_kmeans(double(descs), ...
                        min(size(descs, 2), params.numWords), 'verbose', ...
                        'algorithm', 'ANN');
model.kdtree = vl_kdtreebuild(model.vocab);
save('model.mat', 'model');

