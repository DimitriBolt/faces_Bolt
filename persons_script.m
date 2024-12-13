clc;
clear;
targetSize=[128,128];
location = fullfile('lfw');
svd_cache = fullfile('cache','svd.mat');
% mkdir(fullfile('cache'));

disp('Creating image datastore...');
imds = imageDatastore(location,'IncludeSubfolders',true,'LabelSource','foldernames','ReadFcn', @(filename)imresize(im2gray(imread(filename)),targetSize));
% montage(preview(imds));
disp('Reading all images...');

labels = imds.Labels;                            % все метки из депозитория 13233
[counts, uniqueLabels] = histcounts(labels);     % Count the occurrences of each unique value in 'labels'
[~, sortedIndices] = sort(counts, 'descend');    % Sort the counts in descending order and get the indices
topLabels = uniqueLabels(sortedIndices(1:100));  % Select the 100 most frequent values
persons = categorical(topLabels);                % Create the new categorical array
save('persons100', "persons");

% Check====================================================
element = categorical(cellstr('Dick_Cheney'));      % Define the element of interest
load("A.mat")
indices = find(labels == element);               % Find indices where 'labels' matches the given element
correspondingElements = A(indices);              % Extract the corresponding elements from 'A'

% Play faces
    for j=1:length(correspondingElements)
        imshow(correspondingElements{j}),title(element,'Interpreter','none');
        colormap gray;
        drawnow;
        pause(1);
    end