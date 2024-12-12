
[un_ibl,ia,ic] = unique(ibl);
icn = accumarray(ic, 1);
icn(:,2)=iblu;
icnsort = sortrows(icn,1,'descend');
listpersons = icnsort(1:100,2);
person = ibl(listpersons);
persons = cellstr(person);
personsold = {'Angelina_Jolie', 'Eduardo_Duhalde', 'Amelie_Mauresmo'};
[~, ~, indices] = unique(persons);