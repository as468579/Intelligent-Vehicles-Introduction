
root = "C:\Users\USER\Desktop\img\";
folder = strcat(root, date);

% Create folder if not exists
if ~exist(folder, 'dir')
   mkdir(folder)
end

camera = videoinput('pointgrey', 1, 'F7_Mono8_4096x2160_Mode0');
% camera = videoinput('pointgrey', 1,  'F7_BayerRG16_4096x2160_Mode0');
% camera = videoinput('pointgrey', 1,  'F7_Mono8_4000x3000_Mode10');
% Camera Configuration
set(camera, 'TriggerRepeat', Inf);
set(camera, 'FramesPerTrigger', 1);
camera.FrameGrabInterval=1;
config = getselectedsource(camera);
set(config, 'FrameRate', 11);
set(config, 'Exposure', 2.4);
set(config, 'Shutter', 0.025);

resolution = camera.VideoResolution;
numOfBands = camera.NumberOfBands;

% Create figure
% figure('Name', 'Preview window of  camera');
% Create UI Control Button
% ButtonHandler = uicontrol('Style', 'PushButton', ...
%                                                    'String', 'Stop Record', ...
%                                                    'Callback', 'delete(gcf)');

% img = image( zeros(resolution(2), resolution(1), numOfBands) );
% 
% preview(camera, img);
% img_list = [];
% count = 11 * 60;
% while count
%     imageData = getsnapshot(camera);
%     img_list = [img_list, imageData];
%     if ~ishandle(ButtonHandler)
%         closepreview(camera);
%         delete(camera);
%         disp('Record stopped by user');
%         break;
%     end
%     pause(0.01);
% end

num_images = 11;
frames = zeros(resolution(2), resolution(1), num_images) ;
list = [];
start(camera);
for i=1:num_images
    list = [list getdata(camera, 1)];
end

for i=1:num_images
    image = list(:, (i-1)*resolution(1)+1:i*resolution(1));
    imwrite(image, strcat(num2str(i-1), '.png'));
end
delete(camera);
