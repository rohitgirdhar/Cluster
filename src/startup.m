run('~/software/vlfeat/toolbox/vl_setup.m');
addpath(genpath('.'));

options.datasetID = 'fullbody';
options.dataset = '~/projects/003_SelfieSeg/datasets/selfies_fullbody/fullbody/gym';
options.imgsList = '~/projects/003_SelfieSeg/datasets/selfies_fullbody/ImgsList.txt';
options.cacheDir = fullfile('../CacheR', options.datasetID);
options.resultsDir = fullfile('../ResultsR', options.datasetID);
options.segImgsDir = '~/projects/003_SelfieSeg/subdiscover/ResultsR/fullbody/gym_1';
options.clusterFeature = 'color-hist'; % could be 'dsift', 'color-hist'
options.featureDir = '/features'; % directory in cache to store the feature reps
options.segExt = '.png'; % extensions of segmentation files
