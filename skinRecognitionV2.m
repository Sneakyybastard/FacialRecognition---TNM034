
% https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=560536

function [outLogical] = skinRecognitionV2(inImg)
SE = strel('sphere', 3);
SE2_1 = strel('line', 300, 90);
SE2_2 = strel('line', 300, 0);

sizeImg = size(inImg);
maxSize = sizeImg(1)*sizeImg(2);
hsvImg = rgb2hsv(inImg);
ycbcrImg = rgb2ycbcr(inImg);

arrayImg = reshape(inImg, [],3);
arrayHsv = reshape(hsvImg, [],3);
arrayYcbcr = reshape(ycbcrImg, [],3);
arrayResult = zeros(3, maxSize);

hMin = 0; hMax = 50; sMin = 0.23; sMax = 0.68;
rMin = 95; gMin = 40; bMin = 20; % r > g & r > b & |r-g| > 15 
crMin = 135; cbMin = 85; yMin = 80;

for j = 1:3    
    if j == 2
        inImg = referenceWhite(inImg);
    elseif j == 3
        inImg = greyWorldAssumption(inImg);
    end
    if j > 1
        sizeImg = size(inImg);
        maxSize = sizeImg(1)*sizeImg(2);
        hsvImg = rgb2hsv(inImg);
        ycbcrImg = rgb2ycbcr(inImg);

        arrayImg = reshape(inImg, [],3);
        arrayHsv = reshape(hsvImg, [],3);
        arrayYcbcr = reshape(ycbcrImg, [],3);
    end
    for i = 1:maxSize
        r = arrayImg(i,1); g = arrayImg(i,2); b = arrayImg(i,3);
        h = arrayHsv(i,1); s = arrayHsv(i,2); 
        y = arrayYcbcr(i,1); cb = arrayYcbcr(i,2); cr = arrayYcbcr(i,3);
        crMax = (1.5862*cb)+20;
        crMin2 = (0.3448*cb)+76.2069;
        crMin3 = (-4.5652*cb)+234.5652;
        crMax2 = (-1.15*cb)+301.75;
        crMax3 = (-2.2875*cb)+432.85;

        test1 = (h > hMin && h < hMax && s > sMin && s < sMax &&...
                r > rMin && g > gMin && b > bMin && r > g && r > b && abs(r-g) > 15);
        if( test1)
            arrayResult(j,i) = 1;
        elseif( cr > crMin && cb > cbMin && y > yMin &&...
             cr < crMax && cr > crMin2 && cr > crMin3 && cr < crMax2 && cr < crMax3)

            arrayResult(j,i) = 1;
        else
            arrayResult(j,i) = 0;
        end

    end

end


sumResult = [sum(arrayResult(1,:), 'all'), sum(arrayResult(2,:), 'all'), sum(arrayResult(3,:), 'all')];

[tempMax, index] = max(sumResult);


% result1 = reshape(arrayResult(1,:), sizeImg(1), sizeImg(2));
% result2 = reshape(arrayResult(2,:), sizeImg(1), sizeImg(2));
% result3 = reshape(arrayResult(3,:), sizeImg(1), sizeImg(2));
% subplot(1,3,1);
% imshow(result1);
% subplot(1,3,2);
% imshow(result2);
% subplot(1,3,3);
% imshow(result3);

result = reshape(arrayResult(index,:), sizeImg(1), sizeImg(2));

result = imclose(result, SE2_1);
result = imclose(result, SE2_2);

outLogical = result;

end
