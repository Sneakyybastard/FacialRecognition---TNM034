close all
clc

in = imread('db1_04.jpg');
out = referenceWhite(in);
%%
figure,imshow(in)
title('Original')

% determine if correction is needed
Ravg = sum( sum(in(:,:,1)))/numel(in(:,:,1) ); 
Gavg = sum( sum(in(:,:,2)))/numel(in(:,:,2) ); 
Bavg = sum( sum(in(:,:,3))/numel(in(:,:,3) ) ); 
corrVal = max(max(Ravg, Gavg), Bavg)/min(min(Ravg, Gavg), Bavg);
if abs( corrVal ) > 1.3
    grey = greyWorldAssumption(in);
    fprintf('Correction with Grey World Assumption is performed! \n')
else
    fprintf('No correction is needed! \n')
end

% white = referenceWhite(in);
% figure, imhist(in)
% figure, imhist(white)
% figure, imhist(grey)
% whiteGrey = greyWorldAssumption(white);
% title('White-balanced + Grey World Assumption')
% greyWhite = referenceWhite(grey);
% title('Grey World Assumption + White-balanced')

