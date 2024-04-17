Modellistica e Simulazione (Data: 2023)![](Aspose.Words.0e4bfc82-9369-425f-806c-2e04430a5640.001.png)

Elaborato Modellistica e Simulazione

Docente: C. Carnevale

Istruzioni

- Consegnare script (con commenti) e schemi simulink.
- L’orale consiste in una presentazione dei risultati e delle scelte progettuali.
- NO livescript

1

- Elaborato Modellistica e Simulazione 2 Esercizio 1![](Aspose.Words.0e4bfc82-9369-425f-806c-2e04430a5640.002.png)

Modellizzare, studiare gli equilibri e simulare un sistema NONLINEARE di vostro interesse. Presentare durante l’esposizione variabili di stato, ingressi e uscite e principali caratteristiche ed eventuali criticità della dinamica del sistema. La cartella modelli deterministici contiene degli esempi di modelli che potete utilizzare o da cui prendere esempio (ATTENZIONE: Questi articoli spesso contegono analisi piu` specifiche e complesse di quelle richieste: limitarsi a quanto richiesto dall’elaborato).

Esercizio 2![](Aspose.Words.0e4bfc82-9369-425f-806c-2e04430a5640.003.png)

Selezionare una o piu` serie storiche (alcuni link nella cartella serie~~ storiche) e analizzare con le tecniche data- driven il problema selezionato (il modello deve avere almeno un input esogeno)

CONSEGNARE (nel caso NON si invii un file unico):

- NOME FILE: ES2~~ a
- TIPO FILE: .m
- CONTENUTO: script necessario alla risoluzione del problema. Riportare nei commenti il modello e la sua validazione.

- Elaborato Modellistica e Simulazione 3

Esercizio 3![](Aspose.Words.0e4bfc82-9369-425f-806c-2e04430a5640.004.png)

1) Scrivere uno script MATLAB che permetta di:
1. Calcolare e studiare la stabilit`a dei punti di equilibrio del sistema per u=0.
1. Valutare quale delle due uscite possa essere utilizzata per la linearizzazione I-O del sistema (supponendo in questo caso lo stato misurabile o stimabile).
1. Progettare il controllo linearizzante (se possibile) utilizzando l’uscita stabilita al punto (2).
1. Determinare un controllo in retroazione per la regolazione a 0 dello stato che permetta di avere dinamica definita dalla coppia di autovalori autovalori [a1;2\*a1], dove a1 deve permettere al sistema (considerando la linearizzazione ”perfetta”) di raggiungere l’equilibrio in un tempo T=2s.

CONSEGNARE:

- NOME FILE: ES3 a
- TIPO FILE: .m
- CONTENUTO: lo script MATLAB richiesto con i commenti necessari per giustificare le scelte (Utilizzare il simbolo % per inserire i commenti). Inserire come commento:.
- I valori dei punti di equilibrio, la loro classificazione (quando possibile), e le informazioni necessarie alla loro classificazione;
- l’espressione del controllo linearizzante;
- l’espressione della legge di controllo per il sistema linearizzato e il valore dei parametri calcolati.
2) Linearizzare il sistema attorno ad un suo punto di equilibrio stabile, calcolando le matrici del sistema lineare risultanti.

CONSEGNARE:

- NOME FILE: ES3 b
- TIPO FILE: .m
- CONTENUTO: lo script MATLAB richiesto con i commenti necessari per giustificare le scelte (Utilizzare il simbolo % per inserire i commenti). Inserire come commento:.
- I valori dei punti di equilibrio, la loro classificazione (quando possibile), e le informazioni necessarie alla loro classificazione;
- Il sistema linearizzato in forma simbolica (generale per i diversi punti di equilibrio) e in forma numerica nel punto di equilibrio selezionato.
3) Simulare il sistema controllato, a partire dalla condizione iniziale x0=[3;5], nei due casi.
