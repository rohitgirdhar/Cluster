function [feature, vis] = computeFeatureRep(I, options, varargin)
% I a mxnx3 image
% segMap a mxn binary segmentaion map

p = inputParser;
addOptional(p, 'segMap', ones(size(I, 1), size(I, 2)));
parse(p, varargin{:});

segMap = p.Results.segMap;
if ~islogical(segMap)
    segMap = logical(segMap);
end

feature = [];
if strcmp(options.clusterFeature, 'color-hist')
    feature = getColorHist(I, 'segMap', segMap);
    vis = [];
elseif strcmp(options.clusterFeature, 'dsift')
    [feature, vis] = getDSIFTHist(I, options, 'segMap', segMap);
else
    fprintf(2, 'Not implemented yet!\n');
end

