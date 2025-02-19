% read all images
images = cell(16,1);
for i = 1:16
    if i < 10 
        images{i} = imread(strcat('db1_0', int2str(i), '.jpg'));
    else
        images{i} = imread(strcat('db1_', int2str(i), '.jpg'));
    end
end

% color correct
for i = 1:16
    images{i} = referenceWhite(images{i});
end

finalMask = cell(16,1);
leftEye = cell(16,1);
rightEye = cell(16,1);

% skin & eye detection
figure
for i = 1:16
    [finalMask{i}, leftEye{i}, rightEye{i}] = eyerecog_Christian(images{i});
    subplot(4, 4, i);
    imshow(finalMask{i});
end

    
    
% rotate, scale & translate
% figure
% for i = 1:16
%     out = scaling(images{i}, leftEye{i}, rightEye{i});
%     subplot(4, 4, i);
%     imshow(out);
% end
