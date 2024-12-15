clc;
clear;
targetSize=[8,8];
location = fullfile('lfw');
svd_cache = fullfile('cache','svd.mat');
% mkdir(fullfile('cache'));

disp('Creating image datastore...');
imds0 = imageDatastore(location,'IncludeSubfolders',true,'LabelSource','foldernames','ReadFcn', @(filename)imresize(im2gray(imread(filename)),targetSize));
% montage(preview(imds));
disp('Reading all images...');

k=8;                    % Number of features to consider
persons_amount = 30;    % Number of persons to consider

labels = imds0.Labels;                            % все метки из депозитория 13233
[counts, uniqueLabels] = histcounts(labels);     % Count the occurrences of each unique value in 'labels'
[~, sortedIndices] = sort(counts, 'descend');    % Sort the counts in descending order and get the indices
topLabels = uniqueLabels(sortedIndices(1:persons_amount));  % Select the 100 most frequent values
persons = categorical(topLabels);                % Create the new categorical array
save('persons_test'+ string(persons_amount), "persons");
[lia, locb] = ismember(imds0.Labels, persons);
imds = subset(imds0, lia);

% Check====================================================
if false
    element = categorical(cellstr('Angelina_Jolie'));      % Define the element of interest
    %load("A.mat")
    indices = find(labels == element);               % Find indices where 'labels' matches the given element
    correspondingElements = A(indices);              % Extract the corresponding elements from 'A'
% Play faces
    for j=1:length(correspondingElements)
        imshow(correspondingElements{j}),title(element,'Interpreter','none');
        colormap gray;
        drawnow;
        pause(1);
    end
end
A = readall(imds);
B = cat(3,A{:});
D = prod(targetSize);
B = reshape(B,D,[]);

disp('Normalizing data...');
B = single(B)./256;
[B,C,SD] = normalize(B);
disp('SVD')
if true
    tic;
    [U,S,V] = svd(B,'econ');
    toc;
end
% Discard unnecessary data
W = S * V';                             % Transform V to weights (ala PCA)
W = W(1:k,:);                           % Keep first K weights
U = U(:,1:k);                           % Keep K eigenfaces

% Find feature vectors of all images
X = W';
Y = categorical(imds.Labels, persons);

disp('Training Support Vector Machine...');
options = statset('UseParallel',true);
tic;
Mdl = fitcecoc(X, Y,'Verbose', 2,'Learners','svm',...
               'Options',options);
toc;
%CVMdl = crossval(Mdl);
%genError = kfoldLoss(CVMdl)

YPred = predict(Mdl, X);
Accuracy = numel(find(Y==YPred))/numel(Y)