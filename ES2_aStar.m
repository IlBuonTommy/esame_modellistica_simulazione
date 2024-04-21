clear all
load("idrometrico_10_23_clean.mat");
load("precipitazioni_10_23.mat");
load("temperatura_10_23_clean.mat");
% Sui file contrassegnati con _clean sono state effettuate delle operazioni di clean degli outslier e di data smoothing
%https://www.arpalombardia.it/temi-ambientali/meteo-e-clima/form-richiesta-dati/

% Estrazione dei dati dalle tabelle
y = table2array(Altezza(:, 2)); % Estrazione dei dati dalla seconda colonna della tabella "Altezza"
u1 = table2array(Pioggia(:, 2)); % Estrazione dei dati dalla seconda colonna della tabella "Pioggia"
u2 = table2array(Temperatura(:, 2)); % Estrazione dei dati dalla seconda colonna della tabella "Temperatura"

% Validazione dati
% Trovo i valori non validi ovvero quelli con -999 e li sostituisco facendo
% un interpolazione lineare
y = interp999(y);
u1 = interp999(u1);
u2 = interp999(u2);

Ts = 1; % Sampling time 1h

dati = iddata(y, [u1, u2], Ts);

%l'estensione massima del bacino idrografico del lago d'iseo è di 50km,
%considerando una velocità media dell'acqua di 1m/s vuol dire che l'acqua
%percorre 80km al giorno
%https://www.researchgate.net/figure/Il-bacino-idrografi-co-del-fi-ume-Oglio-a-nord-del-lago-dIseo-provincia-di-Brescia-i_fig17_268349106

%  INPUT
%Indica gli indici massimi ai quali la ricerca del modello verrà fermata
ordine_max=10;
passo_previsione=24; %tra quante ore deve predire il modello
soglia_stop=0.11; %soglia di stop per l'euristica, MAE a cui si ferma la ricerca del modello

fineIdentificazione=78888; %valore del 1 gen 2019
dataset_identificazione=dati(1:fineIdentificazione);
dataset_validazione=dati((fineIdentificazione+1):end);

%richiama la funzione
[modello_migliore, best_orders] = aStar(dataset_identificazione, dataset_validazione, passo_previsione, ordine_max, soglia_stop);
%stampa l'ordine del miglior modello trovato
disp(best_orders);

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
title(['NMAE=',num2str(errMedioAssoNorm),'   NME=',num2str(errMedioNorm),'   Correlazione=',num2str(corr),'   MAE=',num2str(errMedioABS)])


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

function [best_model, best_orders] = aStar(dataset_identificazione, dataset_validazione, passo_previsione, ordine_max, soglia_stop)
    % Inizializza la matrice con i nodi visitati se hanno un valore diverso da -1
    matriceVisitati = 100000 * ones(ordine_max, ordine_max, ordine_max); %salvo il MAE di ogni modello visitato e lo uso come euristica
    matriceVisitatiDiretti = -1 * ones(ordine_max, ordine_max, ordine_max);
    matriceVisitatiModelli = cell(ordine_max, ordine_max, ordine_max); %salvo i modelli che ho visitato
    %Dichiaro il nodo iniziale
    cordNodoIniziale=[1,1,1];
    % Inizializza il miglior modello e gli ordini come vuoti
    best_model = [];
    best_orders = [];
    erroriL=[];
    best_error = inf;
    % Finché la lista aperta non è vuota
    while any(matriceVisitati(:) == 100000)
        % Calcola l'euristica e i modelli dei valori vicini
        [matriceVisitati, matriceVisitatiModelli] = generateChildren(cordNodoIniziale, dataset_identificazione, dataset_validazione, passo_previsione, ordine_max, matriceVisitati, matriceVisitatiModelli);
        %sposto il nodo corrente su quello con l'euristica minore controllando che non sia lo stesso nodo che ho visitato prima
        [best_error, indice_relativo] = min(matriceVisitati(:));
        [x, y, z] = ind2sub(size(matriceVisitati), indice_relativo);
        best_orders = [x, y, z];

        % Aggiungi il valore best_error all'array degli errori
        erroriL = [erroriL, best_error];
        % Crea un array con il numero di cicli eseguiti
        cicli = 1:length(erroriL);
        % Grafico degli errori in funzione dei cicli
        figure(3); clf
        plot(cicli, erroriL, 'LineWidth', 2);
        grid on;
        xlabel('Nodi visitati');
        xticks(floor(min(cicli)):1:ceil(max(cicli)));
        ylabel('MAE più basso trovato');
        numElements = numel(matriceVisitati(matriceVisitati < 10000));
        totNumElements = numel(matriceVisitati);
        title(['Sono stati calcolati ',num2str(numElements),' modelli su ',num2str(totNumElements)]);

        matriceVisitatiDiretti(cordNodoIniziale(1),cordNodoIniziale(2),cordNodoIniziale(3)) = 1;
        if(best_error < soglia_stop)
            best_model = matriceVisitatiModelli{best_orders(1), best_orders(2), best_orders(3)};
            return;
        end

        % Crea una copia di matriceVisitati per manipolare
        matriceTemp = matriceVisitati;
        while true
            % Trova il valore minimo e il suo indice lineare
            [tempC, indice_lineare] = min(matriceTemp(:));
            % Converti l'indice lineare in indici di matrice
            [x, y, z] = ind2sub(size(matriceTemp), indice_lineare);
            % Controlla se il corrispondente valore in matriceVisitatiDiretti è 1
            if matriceVisitatiDiretti(x, y, z) ~= 1
                % Se non è 1, esci dal ciclo
                break;
            else
                % Se è 1, imposta questo valore a Inf in matriceTemp e continua il ciclo
                matriceTemp(x, y, z) = Inf;
            end
        end
        cordNodoIniziale = [x, y, z];
    end
    best_model = matriceVisitatiModelli{best_orders(1), best_orders(2), best_orders(3)};
    fprintf("\nNessun nodo trovato con valore euristico (MAE) inferiore a %f\n",soglia_stop);
end

function [matriceVisitati, matriceVisitatiModelli] = generateChildren(cordNodoIniziale, dataset_identificazione, dataset_validazione, passo_previsione, ordine_max, matriceVisitati, matriceVisitatiModelli)
    % Visita tutti i vicini di un nodo nelle tre dimensioni
    for i = -1:1
        for j = -1:1
            for k = -1:1
                if cordNodoIniziale(1) + i > 0 && cordNodoIniziale(1) + i <= ordine_max && cordNodoIniziale(2) + j > 0 && cordNodoIniziale(2) + j <= ordine_max && cordNodoIniziale(3) + k > 0 && cordNodoIniziale(3) + k <= ordine_max
                    childCordinate = [cordNodoIniziale(1) + i, cordNodoIniziale(2) + j, cordNodoIniziale(3) + k];
                    if(matriceVisitati(childCordinate(1),childCordinate(2),childCordinate(3)) > 10000)
                        na=childCordinate(1);%ordine parte autoregressiva, quante istanze di y 
                        nb=[childCordinate(2),childCordinate(3)];%ordine parte esogena, quante istanze di u ho
                        nk=[0 0];%ritardo della parte esogena, ritardo tra la prima istanza di u e l'uscita
                        orders=[na,nb,nk];
                        matriceVisitatiModelli{childCordinate(1), childCordinate(2), childCordinate(3)} = arx(dataset_identificazione, orders);
                        dati_out_id = predict(matriceVisitatiModelli{childCordinate(1), childCordinate(2), childCordinate(3)}, dataset_validazione, passo_previsione);
                        matriceVisitati(childCordinate(1), childCordinate(2), childCordinate(3)) = mean(abs(dati_out_id.y - dataset_validazione.y));
                    end
                end
            end
        end
    end
end