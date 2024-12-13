clc;
clear;

targetSize=[128,128];
location = fullfile('lfw');
svd_cache = fullfile('cache','svd.mat');
mkdir(fullfile('cache'));

disp('Creating image datastore...');
imds = imageDatastore(location,'IncludeSubfolders',true,'LabelSource','foldernames',...
                      'ReadFcn', @(filename)imresize(im2gray(imread(filename)),targetSize));
montage(preview(imds));
disp('Reading all images...');
A = readall(imds);

save('A', "A");


