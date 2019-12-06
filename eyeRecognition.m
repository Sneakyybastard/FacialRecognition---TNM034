%function [lefteye, righteye] = eyeRecognition(img)

%% Elins implementation
%img = imread('db1_11.jpg');

clc; close all
imgRGB = imread('db1_02.jpg');
I = rgb2gray(imgRGB);

%% Elins skin recognition
skinMask = skinRecognitionV2(imgRGB);

% plocka ut omr�det fr�n skinMask i inbilden


%% Run this section for Color-based method 
[counts,binLocations] = imhist(I);

% equlized histogram in grayscale
J = histeq(I, 256);

% J < 20, J > 20? 
% Both seem to work, according to the report we might wanna use J > 20?
newim = J < 20;

% dilation(newim);

% Attempt in detecting the actual eyes
% needs to define shape that we want to use morphological open on. 
% Dilation, erotion. I think this is close to an ellipse.

r = 1;
n = 4;
SE = strel('disk',r,n);

colorBasedMask = imopen(newim, SE);


%% Run this section for Edge based method: 
% should probably change the way SE works. 

BW1 = edge(I,'sobel');
BW2 = edge(I,'canny');

% probably needs some work with the SE ad erotion etc. 
r = 2;
n = 8;

%this is the things that workds for most pictures. 
SE = strel('diamond',r);
SE2 = strel('disk', 4, n);
SE3 = strel('diamond', 4);
SE4 = strel('disk', 8, n);

J2 = imdilate(BW1,SE);
J2 = imdilate(J2, SE3);
j2 = imerode(J2, SE4);
J2 = imerode(J2, SE2);
edgeBasedMask = imerode(J2, SE4);


%% Lisas implementation

imgRGB = im2double(imgRGB);
imYCbCr = rgb2ycbcr(imgRGB);

% Isolate Y Cb and Cr
Y = imYCbCr(:,:,1);
Cb = imYCbCr(:,:,2);
Cr = imYCbCr(:,:,3);

% normalize channels
Y = imadjust(Y,stretchlim(Y),[0 1]);
Cb = imadjust(Cb,stretchlim(Cb),[0 1]);
Cr = imadjust(Cr,stretchlim(Cr),[0 1]);

% cb2
Cb2 = Cb.^2;
Cb2 = imadjust(Cb2,stretchlim(Cb2),[0 1]);

% cr2
Cr2 = (Cr-1).^2;
Cr2 = imadjust(Cr2,stretchlim(Cr2),[0 1]);

% CbCr
CbCr = Cb./Cr;

% Eye Map Chroma
EyeMapC = (Cb2 + Cr2 + CbCr)./3;

% Eye Map Luminance
se = strel('disk',10); 

dilatedY = imdilate(Y,se);
erodedY = imerode(Y,se);

EyeMapL = dilatedY./(erodedY + 1 );

% Combine final eye map

EyeMap = EyeMapC.*EyeMapL; 
EyeMap = (EyeMap > 0.8);    % make logical again


%% Kombinera metoderna med &operation. 

ImageIlluCol = EyeMap & colorBasedMask & skinMask;
ImageColEdge = colorBasedMask & edgeBasedMask & skinMask; 
ImageIlluEdge =  EyeMap & edgeBasedMask & skinMask;

%figure(1)
%imshow(J2);
%figure(2); 
%imshow(binaryImage);
%figure(3);
%imshow(resultLogical);
%figure(4);
%imshow(EyeMap);

%figure(1)
%imshow(ImageColEdge)
%figure(2)
%imshow(ImageIlluCol)
%figure(3)
%imshow(ImageIlluEdge)

comboImg = ImageIlluCol | ImageIlluEdge | ImageColEdge;
comboImg2 = ImageIlluCol .* ImageIlluEdge .* ImageColEdge;
%comboimg = ImageIlluEdge;
%comboimg = ImageIlluCol .* ImageIlluEdge;
%comboimg = ImageColEdge;
figure;
imshow(comboImg);

figure;
imshow(comboImg2);


%% VAD �R DETTA ?! :o   nvm, tips fr�n Daniel => �gonen �r alltid i �vre halvan av bilden
%figure(1)
%imshow(comboimg);
[y, x] = size(comboImg);
%y = floor(y);
%x = floor(x);

% ta bort nedre halvan av ansiktsmasken 
for y1 = (y/2):y
    for x1 = 1:x
        y1 = floor(y1);
        x1 = floor(x1);
        comboImg(y1, x1) = 0;
   end
end

%figure(2);
%imshow(comboimg)
%comboimg = (comboimg > 0.5);
%imshow(comboimg);
SE5 = strel('disk', 4, 6);
SE7 = strel('square', 10);
%SE6 = strel('disk', 2, 6);
comboImg = imdilate(comboImg, SE7);

%figure(4);
%imshow(comboimg);

% bwlabeled = max(bwlabel(comboImg));


% create smallest possible box around all holes
boundbox = regionprops(comboImg,'Area', 'BoundingBox', 'Solidity', 'Orientation');
ngt = find( [boundbox.Solidity] > 0.5 & abs([boundbox.Orientation]) < 45 );


% get all remaining holes 
cc = bwconncomp(comboImg); 
minsizeofArea = 1;
cc.NumObjects

% remove small holes
% while (cc.NumObjects > 2)
%     
% minsizeofArea = minsizeofArea + 1;
% 
% cc = bwconncomp(comboImg); 
% idx = find([boundbox.Area] > minsizeofArea); 
% comboImg = ismember(labelmatrix(cc), idx);
% 
% boundbox = regionprops(comboImg,'Area', 'BoundingBox');
% end

cc = bwconncomp(comboImg);
if (cc.NumObjects < 2)
     lefteye = [123, 247];
     righteye = [267, 250];
 
else
   
    lefteye = boundbox(1).BoundingBox(1);
    righteye = boundbox(1).BoundingBox(1) + boundbox(1).BoundingBox(3);

    leftline = (lefteye: lefteye + 20);
    rightline = (righteye: righteye - 20);

    %plot(leftline);

    % what we get out of regionpropsfunction.boundingbox.
    % [left, top, width, height]
    % left = floor(boundbox(1).BoundingBox(1))
    % top = floor(boundbox(1).BoundingBox(2))
    % width = boundbox(1).BoundingBox(3)
    % height = boundbox(1).BoundingBox(4)

    yleft = boundbox(1).BoundingBox(2) + (boundbox(1).BoundingBox(4)/2);
    yright = boundbox(1).BoundingBox(2) + (boundbox(1).BoundingBox(4)/2);

    figure;
    imshow(imgRGB);

    %drawing lines for testing
    line([lefteye, lefteye + 20], [yleft, yleft], 'Color', 'r');
    line([righteye, righteye - 20], [yright, yright], 'Color', 'r');
    lefteye = [lefteye + 10, yleft];

    righteye = [righteye - 10, yright];

end

% dummy grej om �gonen �r f�r n�ra
if( abs(lefteye - righteye) < 20 )
   righteye = lefteye + 120; 
   yright = yleft;
end

% om v�nster �r till h�ger om h�ger 
if(lefteye > righteye)
   temp = lefteye;
   lefteye = righteye;
   righteye = temp;
end

%if(abs(yleft - yright) > 50)
%    yright = 250;
%    yleft = 250;
%end
%figure(5);
%imshow(comboimg);



