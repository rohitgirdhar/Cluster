function [hist, vis] = getDSIFTHist(I, options, varargin)
% consider only 1s part from segMap to compute the histogram
p = inputParser;
addOptional(p, 'segMap', ones(size(I, 1), size(I, 2)));
parse(p, varargin{:});

% dsift function can't handle grayscale images, convert to rgb if required
if size(I, 3) == 1
    I = cat(3, I, I, I);
end

load(fullfile(options.cacheDir, ['vocab_model_', ...
            num2str(options.dsiftVocabK), '.mat']), 'model');

dsift_img = dsift(I);
dsift_rowed = reshape(dsift_img, size(I, 1) * size(I, 2), [], 1);
seg_rowed = reshape(p.Results.segMap, [], 1);
tic;
vis = uint32(vl_kdtreequery(model.kdtree, model.vocab, ...
            double(dsift_rowed(seg_rowed, :)')));
vis_final = zeros(size(I, 1) * size(I, 2), 1);
vis_final(find(seg_rowed), :) = vis;
vis = reshape(vis_final, size(I, 1), size(I, 2));
hist = histc(vis(:), 1 : options.dsiftVocabK);
hist = reshape(hist, 1, []);
hist = hist ./ norm(hist, 1);
fprintf('Time to compute visual rep %f\n', toc);

