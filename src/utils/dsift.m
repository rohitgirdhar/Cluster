function feature = dsift(I)
% conver to lab
origSize = size(I);
I = padarray(I, [2 2], 'pre');
I = padarray(I, [1 1], 'post');
Ilab = rgb2lab(I);

% smooth image
binSize = 8 ;
magnif = 3 ;
Is1 = vl_imsmooth(single(Ilab(:,:,1)), sqrt((binSize/magnif)^2 - .25)) ;
Is2 = vl_imsmooth(single(Ilab(:,:,2)), sqrt((binSize/magnif)^2 - .25)) ;
Is3 = vl_imsmooth(single(Ilab(:,:,3)), sqrt((binSize/magnif)^2 - .25)) ;

% extract sift on each channel
[~, d1] = vl_dsift(single(Is1),'size',1,'fast');
[~, d2] = vl_dsift(single(Is2),'size',1,'fast');
[~, d3] = vl_dsift(single(Is3),'size',1,'fast');
d = [d1;d2;d3];

feature = reshape(d', origSize(1), origSize(2), []);
%feature = permute(feature, [2 1 3]); % multidimensional transpose

