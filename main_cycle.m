load A100.mat
load persons100.mat
targetSize_OneDimention = 128;
targetSize = [targetSize_OneDimention,targetSize_OneDimention];
fiches_numbers = [8,16,32,64,128,256,512,1024,2048];
%fiches_numbers = [32,128,256];
Histortoc=[];
HistorAccuracy=[];
HistorSize=[];
for k=fiches_numbers
    [Accuracy, rm, ttoc] = func_fitcecoc(k,targetSize, A, labels, persons);
    fileinfo = dir("model.mat");
    HistorAccuracy(end+1) = Accuracy;
    Histortoc(end+1) = ttoc;
    HistorSize(end+1) = fileinfo.bytes;
    fprintf('N_fiches %d,  Accuracy %.2f, time %.0f, size %d\n',k, Accuracy, ttoc, fileinfo.bytes);
end
save("dependence_from_hyperparameters_"+string(targetSize_OneDimention)+".mat","HistorSize", "Histortoc", "HistorAccuracy")