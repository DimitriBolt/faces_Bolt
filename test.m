clc
ibl = imds0.Labels; %все метки из депозитория 13233
%iblu = unique(ibl);
[un_ibl,ia,ic] = unique(ibl); % уникальные метки, уникальный номер уникальной метки, 
icn = accumarray(ic, 1);%количество уникальных значений каждой метки (под номерами)
icn(:,2)=un_ibl;%добавил номера, чтобы их искать в ibl
icnsort = sortrows(icn,1,'descend');%сортировка по убыванию по первому столбцу
listpersons = icnsort(1:100,2);%выбрали первые 100
person = ibl(listpersons);%вставили имена
persons = cellstr(person)';%изменили формат
personsold = {'Angelina_Jolie', 'Eduardo_Duhalde', 'Amelie_Mauresmo'};%старый список
[~, ~, indices] = unique(persons);
nomer_peron=100
disp(persons(nomer_peron))
disp(icnsort(nomer_peron))
[tlia, tlocb] = ismember(imds0.Labels, persons(nomer_peron));
AA = readall(imds0);
BB = cat(3,AA{:});
imshow(BB(:,:,nomer_peron))
drawnow;
