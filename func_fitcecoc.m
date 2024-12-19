function [Accuracy, rm, ttoc] = func_fitcecoc(k, targetSize, A, labels, persons)
    clc;
    %clearvars -except A persons labels;
    %targetSize = [128,128];
    %k=64;                                   % Number of features to consider
    % location = fullfile('lfw');
    
    % disp('Creating image datastore...');
    % imds0 = imageDatastore(location,'IncludeSubfolders',true,'LabelSource','foldernames','ReadFcn', @(filename)imresize(im2gray(imread(filename)),targetSize));
    % disp('Creating subset of several persons...');
    % persons = {'Angelina_Jolie', 'Eduardo_Duhalde', 'Amelie_Mauresmo'}
    % load('persons100.mat')
    % [lia, locb] = ismember(imds0.Labels, persons);
    % imds = subset(imds0, lia);
    
    % t=tiledlayout('flow');
    % nexttile(t);
    % montage(imds);
    
    % disp('Reading all images');
    % A = readall(imds);
    % labels = imds.Labels;
    % save ("A100.mat","A", "labels")
    % load("A100.mat")
    
    B = cat(3,A{:});
    D = prod(targetSize);
    B = reshape(B,D,[]);
    
    % disp('Normalizing data...');
    B = single(B)./256;
   
    [B,C,SD] = normalize(B);
    % tic;
    [U,S,V] = svd(B,'econ');
    % toc;
    % Get an montage of eigenfaces
    % Eigenfaces = arrayfun(@(j)reshape((U(:,j)-min(U(:,j)))./(max(U(:,j))-min(U(:,j))),targetSize), 1:size(U,2),'uni',false);
    
    % nexttile(t);
    % montage(Eigenfaces(1:16));
    % title('Top 16 Eigenfaces');
    % colormap(gray);
    
    % NOTE: Rows of V are observations, columns are features.
    % Observations need to be in rows.
    k = min(size(V,2),k);
    
    % Discard unnecessary data
    W = S * V';                             % Transform V to weights (ala PCA)
    W = W(1:k,:);                           % Keep first K weights
    % NOTE: We will never again need singular values S
    %S = diag(S);
    %S = S(1:k);
    U = U(:,1:k);                           % Keep K eigenfaces
    
    % Find feature vectors of all images
    X = W';
    Y = categorical(labels, persons);
    
    % Create colormap
    cm=[1,0,0;
        0,0,1,
        0,1,0];
    % Assign colors to target values
    c=cm(1+mod(uint8(Y),size(cm,1)),:);
    
    % disp('Training Support Vector Machine...');
    options = statset('UseParallel',true);
    tic;
    
    % You may try this, to get a more optimized model
    % 'OptimizeHyperparameters','all',...
    
    % Mdl = fitcecoc(X, Y,'Verbose', 2,'Learners','svm',...
    %                'Options',options);
    Mdl = fitcecoc(X, Y,'Verbose', 0,'Learners','svm', 'Options',options);
    ttoc = toc;
    
    % Generate a plot in feature space using top two features
    % nexttile(t);
    % scatter3(X(:,1),X(:,2),X(:,3),50,c);
    % title('A top 3-predictor plot');
    % xlabel('x1');
    % ylabel('x2');
    % zlabel('x3');
    
    % nexttile(t);
    % scatter3(X(:,4),X(:,5),X(:,6),50,c);
    % title('A next 3-predictor plot');
    % xlabel('x4');
    % ylabel('x5');
    % zlabel('x6');
    
    %[YPred,Score] = predict(Mdl,X);
    [YPred,Score,Cost] = resubPredict(Mdl);
    
    % ROC = receiver operating characteristic
    % See https://en.wikipedia.org/wiki/Receiver_operating_characteristic
    % disp('Plotting ROC metrics...');
    rm = rocmetrics(labels, Score, persons);
    % nexttile(t);
    % plot(rm);
    
    % disp('Plotting confusion matrix...')
    % nexttile(t);
    % confusionchart(Y, YPred);
    % title(['Number of features: ' ,num2str(k)]);
    
    % Save the model and persons that the model recognizes.
    % NOTE: An important part of the submission.
    save('model','Mdl','persons','U', 'targetSize');
    YPred = predict(Mdl, X);
    Accuracy = numel(find(Y==YPred))/numel(Y);
end