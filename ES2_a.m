clear all
load("idrometrico_10_23_clean.mat");
load("precipitazioni_10_23.mat");
load("temperatura_10_23_clean.mat");
%https://www.arpalombardia.it/temi-ambientali/meteo-e-clima/form-richiesta-dati/

y = table2array(Altezza(:, 2));
u1 = table2array(Pioggia(:, 2));
u2 = table2array(Temperatura(:, 2));

% Validazione dati
% Trovo i valori non validi ovvero quelli con -999 e li sostituisco facendo
% un interpolazione lineare
y = interp999(y);
u1 = interp999(u1);
u2 = interp999(u2);

Ts = 1; % Sampling time

dati = iddata(y, [u1, u2], Ts);

%l'estensione massima del bacino idrografico del lago d'iseo è di 50km,
%considerando una velocità media dell'acqua di 1m/s vuol dire che l'acqua
%percorre 80km al giorno
%https://www.researchgate.net/figure/Il-bacino-idrografi-co-del-fi-ume-Oglio-a-nord-del-lago-dIseo-provincia-di-Brescia-i_fig17_268349106
na_max=9;
na_min=9;
n_precipitazioni_max=45;
n_precipitazioni_min=45;
n_temperatura_max=3;
n_temperatura_min=3;
nk=0;
passo_previsione=24; %tra quante ore deve predire il modello

fineIdentificazione=78888; %valore del 1 gen 2019
dataset_identificazione=dati(1:fineIdentificazione);
dataset_validazione=dati((fineIdentificazione+1):end);
cont=0;
for iar=na_min:na_max
    for iex1=n_precipitazioni_min:n_precipitazioni_max   
        for iex2=n_temperatura_min:n_temperatura_max
            na=iar;%ordine parte autoregressiva, quante istanze di y 
            nb=[iex1,iex2];%ordine parte esogena, quante istanze di u ho
            nk=[0 0];%ritardo della parte esogena, ritardo tra la prima istanza di u e l'uscita
            
            cont=cont+1;
            percentuale_avanzamento=round(cont/((na_max-na_min+1)*(n_precipitazioni_max-n_precipitazioni_min+1)*(1+n_temperatura_max-n_temperatura_min))*10^4)/10^2;
            fprintf("Avanzamento: %.2f%%\n",percentuale_avanzamento);
            
            %non avendo necessita di avere un ingresso perchè vogliamo solo la
            %previsione possiamo avere anche un autoregressivo puro. SENZA INPUT

            orders=[na,nb,nk];
            modello=arx(dataset_identificazione,orders);

            %salviamo i modelli
            lista_modelli{cont}=modello;
            struttura(cont,:)=orders;

         
            %USO l'indice MAE sulla validazione perchè non mi interessa il rapporto complessità prestazioni
            %d=na+nb; %numero dei parametri del modello, attenzione nb se è un vettore va sommato con tutti i suoi elementi
            %Se non si usa l'FPE si usa il dataset di validazione
            dati_out_id=predict(modello,dataset_validazione,passo_previsione);
            e(cont)=mean(abs(dati_out_id.y-dataset_validazione.y));
            e_matrice(iar, iex1,iex2)=e(cont);
        end
    end
end

[min_e,indice_min_e]=min(e); %resituisce il valore minimo e il suo indice
modello_migliore=lista_modelli{indice_min_e};
%ordini migliori con fronte di previsione di 10h   2    30    1 con un MAE
%di 0.04144
% 4    60     1 MAE 0.03138
% 9    97     1 MAE 0.012921
% 9    95     3 MAE=0.10157  sulle 24h
%stampo ordini
%f min con    metodo ottimizzazione
struttura(indice_min_e,:)

ypredict=predict(modello_migliore,dataset_validazione,passo_previsione); %calcola i dati di output del modello in previsione
%per portarlo in forma vettoriale 
ypred_v=ypredict.y;
y_v=dataset_validazione.y;
periodoValidazione=table2array(Altezza((fineIdentificazione+1):end, 1));

figure(1); clf
lin=linspace(1,length(y_v),length(y_v))';
plot(lin,y_v,'LineWidth',2,'DisplayName','Livello reale')
legend('-dynamiclegend','Location', 'best')
hold on
plot(lin,ypred_v,'LineWidth',1,'DisplayName','Previsione')
grid on
xlabel(sprintf('Numero di ore dal %s al %s', periodoValidazione(1), periodoValidazione(end)));
title(['Analisi nel tempo del modello migliore con passo previsionale di ' num2str(passo_previsione) ' ore'])
ylabel('Livello idrometrico del lago d''Iseo in cm')

%calcolo dell'errore (residui)
%la sua media è l'errore medio
err=ypred_v-y_v; %non si fa abs per vedere se il modello sovrastima o sottostima NME
errMedio=mean(err); %ME
errMedioABS=mean(abs(err)); %MAE
errMedioNorm=errMedio/mean(y_v);   %NME
errMedioAssoNorm=errMedioABS/mean(y_v);   %NMAE
%calcolo della correlazione per vedere se spostando la predizione si
%raggiungono risultati migliori. Le due correlazioni miste sono quelle di
%nostro interesse, quindi prendo solo uno dei due elementi sull'anti diagonale
corr=corrcoef(ypred_v,y_v);
corr=corr(2,1);

figure(2); clf
plot(lin,err,'LineWidth',2,'DisplayName','Errori')
legend('-dynamiclegend','Location', 'best')
grid on
xlabel('Ore')
ylabel('Errori in cm')
title(['NMAE=',num2str(errMedioAssoNorm),'   NME=',num2str(errMedioNorm),'   Correlazione=',num2str(corr),'   MAE=',num2str(min_e)])

%uso dell-euristica tipo a star per il caloclo della matrice, in modo da
%arrivare velocemente al risultato voluto.


function dati_interp = interp999(dati)
    % Trova gli indici dei valori non mancanti
    indici_non_mancanti = find(dati ~= -999);

    % Interpola i valori mancanti
    dati_interp = dati;
    indici_mancanti = find(dati == -999);
    for i = 1:length(indici_mancanti)
        indice_mancante = indici_mancanti(i);
        dati_interp(indice_mancante) = interp1(indici_non_mancanti, dati(indici_non_mancanti), indice_mancante, 'linear');
    end
end