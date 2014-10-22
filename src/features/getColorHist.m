function colhist = getColorHist(I, varargin)
% GETCOLORHIST computes the color histogram of image I.
% optional arguments:
%   'segMap' : give a binary (segmentation) image, and will consider only the 
%   white (1s) part for computing the feature

p = inputParser;
addOptional(p, 'segMap', ones(size(I, 1), size(I, 2)));
parse(p, varargin{:});

segMap = p.Results.segMap;
if size(I, 1) ~= size(segMap, 1) || size(I, 2) ~= size(segMap, 2)
    fprintf('Sizes dont match!\n');
end

I_re = reshape(I, size(I, 1) * size(I, 2), [], 1);
segMap_re = reshape(p.Results.segMap, size(I, 1) * size(I, 2), []);
I_re_sel = I_re(segMap_re == 1, :);
colhist = reshape(histc(I_re_sel, 1 : 256), 1, []);

% if size less than 768 - eg grayscale images, simply repeat the hist
if size(colhist, 2) == 256
    colhist = repmat(colhist, 1, 3);
end

% L2 normalize
colhist = colhist ./ norm(colhist);

