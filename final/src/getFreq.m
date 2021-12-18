clear;
% clc;
image = imread('g_11_short/10.png');
% Show for debug
% imshow(image);

% image = imbilatfilt(image);

upper = 50;
lower = 10;
threshold = 9;

valid = (image > lower) & (image < upper);
valid = all(valid, 1);
% disp(nnz(valid));
image = image(:, valid);
% Show for debug
% imshow(image);

binary = zeros(size(image));
stride = 50;
tic
for i=1:stride:size(image, 2)
    
    next = i + stride;
    if next > size(image, 2)
        next = size(image, 2);
    end
    % Ostu's method
    level = graythresh(image(1:540, i:next));
    binary(1:540, i:next) = imbinarize(image(1:540, i:next),level);
    
    level = graythresh(image(541:1080, i:next));
    binary(541:1080, i:next) = imbinarize(image(541:1080, i:next),level);

    level = graythresh(image(1081:1620, i:next));
    binary(1081:1620, i:next) = imbinarize(image(1081:1620, i:next),level);
       
    level = graythresh(image(1621:2160, i:next));
    binary(1621:2160, i:next) = imbinarize(image(1621:2160, i:next),level);
end
toc
% Show for debug
% figure;
% imshow(binary);

%% Filter for debug
% binary = imbilatfilt(binary, 100);
se = strel('square',5);
binary = medfilt2(binary);
% binary = imdilate(binary, se);
% binary = imerode(binary, se);
% binary = modefilt(binary, [1, 2159]);
% Show for debug
% figure;
% imshow(binary);

binary = sum(int16(binary), 2);
light = binary >= (size(image, 2) * 0.4);
dark = binary < (size(image, 2) * 0.4);
binary(light) = 1;
binary(dark) = 0;
% binary = repmat(binary, 1, 4096);
% figure;
% imshow(binary);

stripes = diff([0 find(diff(binary))' numel(binary)]);
stripes = stripes(stripes >= 8 & stripes <= 97);
s = 0;
count = 0;
res = [];

for i=2:numel(stripes)
    if count == 0
        s = stripes(i);
        count = 1;
    elseif (abs(s/count - stripes(i)) > threshold) || ((s + stripes(i)) > 470)  || i == numel(stripes)
        if ( count >= 2 && s/count >= 9  && s/count <= 96)
            res = [res, s/count];
        end
        count = 0;
    else
        s = s + stripes(i);
        count = count + 1;
    end
end


gt = [93, 84, 75, 57, 39, 30, 21, 12, 66, 48];
gt_map = repmat(gt, [length(res), 1]);
[~, pred_indices] = min(abs(gt_map - res'), [], 2);
pred_indices = pred_indices( abs(gt(pred_indices) - res) < (threshold / 2));
% green = find(pred == 66, 1, 'first');
% red = find(pred == 48, 1, 'first');
green = find(pred_indices == 9);
red = find(pred_indices == 10);
start = 0;
signal = 0;   % 0 : error, 1: green singal, 2 : red signal

% Determine traffic light
if numel(green) >= 2
    [~, ind] = find(diff(green) == 3);
    if numel(ind) == 1
        signal = 1;
        start = green(ind);
    else
        singal = 0;
    end
elseif numel(red) >= 2
    [~, ind] = find(diff(red) == 3);
    if numel(ind) == 1
        signal = 2;
        start = red(ind);
    else
        singal = 0;
    end
elseif numel(green) == 1 && numel(red) == 1
    if (green < red) && (num(pred_indices) >= (green + 2))
        signal = 1;
        start = green;
    elseif (green > red) && (num(pred_indices) >= (red + 2))
        signal = 2;
        start = red;
    else
        singal = 0;
    end
elseif numel(green) == 1 && numel(pred_indices) >= (green + 2)
    signal = 1;
    start = green;
elseif numel(red) == 1 && numel(pred_indices) >= (red + 2)
    signal = 2;
    start = red;
elseif numel(green) == 1 && (green - 2) >= 1
    signal = 1;
    start = green - 3;
elseif numel(red) == 1 && (red - 2) >= 1
    signal = 2;
    start = red - 3;
else
    signal = 0;
end

if signal
    b1 = de2bi( pred_indices(start + 1) - 1, 3, 'left-msb');
    b2 = de2bi( pred_indices(start + 2) - 1, 3, 'left-msb');
    time = bi2de( [ b1 b2 ], 'left-msb');
end

signal
time

