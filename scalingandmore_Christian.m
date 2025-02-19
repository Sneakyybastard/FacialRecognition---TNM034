%% different images for testing
%im = imread('image_0009.jpg');
im = imread('db1_01.jpg');
%im = imread('db1_04.jpg');

%tnm034(im);
%figure
%imshow(im);
I = rgb2gray(im);
%figure
%imshow(I)

%% Denna section anv�nds inte just nu men vill inte ta bort det �n
S = sum(im,3);
[~,idx] = max(S(:));
[row,col] = ind2sub(size(S),idx); %Hitta ljusaste punkten


%imshow(img);
viscircles([col, row], 3, 'Color', 'b');

hsvImg = rgb2hsv(im);

%imshow(hsvImg);

thresholdLogical = hsvImg(:, :, 1) > 0 & hsvImg(:, :, 1) < 50 & hsvImg(:,:,2) > 0.23 & hsvImg(:,:,2) < 0.68;

resultHsvImg = thresholdLogical.*hsvImg(:,:,3);

resultLogical = resultHsvImg > 0.6;

%imshow(resultLogical);

skinImg = im.*uint8(resultLogical);

%imshow(skinImg);



%%

%f�r bounding box beh�ver vi ha skinrecognition som ger oss en region f�r
%skin. 
resultLogical = skinRecognition(im);
newimage = im .* uint8(resultLogical);

boundbox = regionprops(resultLogical,'Area', 'BoundingBox');
boundbox(1).BoundingBox(1)
%[left, top, width, height
left = floor(boundbox(1).BoundingBox(1))
top = floor(boundbox(1).BoundingBox(2))
width = boundbox(1).BoundingBox(3)
height = boundbox(1).BoundingBox(4)

%mybox = zeros(width, height);
%mybox(1) = left: left + width;
%testbox = [left: (left + width), 0:top];

scale = 1;
J = imresize(newimage,1);
%nothing working :///



% In order to see the box around the selected face, needs an addon 
%J = insertObjectAnnotation(J,'Rectangle',boundbox(1).BoundingBox,'testbox');

%testbox = imrezise(newimage, [testbox(1), testbox(2)]);
%figure;
%imshow(J);

%%
% cropping the image to the bounding box. 
rezisedimg = imcrop(J, boundbox(1).BoundingBox);
%rezisedimg = J(left: left + width, top: top + height);

%showing the cropped image
figure;
imshow(rezisedimg)

%% scaling
% Hur ska vi skala uniformt?
%scaledim = imresize(rezisedimg, [400, 300]);

% todo, fixa s� vi f�r fram �gon automatiskt. 

% f�rst roterar vi imagen, d�r vi f�tt fram right eye och left eye genom
% rotate(), detta beh�ver ske automatiskt genom eyerecog function. 
%rotate();
[righteye, lefteye] = eyeRecognition(im);

[eyeNew1, eyeNew2, rotatedImage] = rotateImage(im, righteye, lefteye);
figure
imshow(rotatedImage);

%% calls the function to scale image around the centerpoint between the
%%eyes. 
I = scaling(rotatedImage, eyeNew1, eyeNew2);
figure;
imshow(I);


%% test face for eyerecog with everything else.
im = imread('db1_15.jpg');
I = scaling(im);
figure;
imshow(I);





