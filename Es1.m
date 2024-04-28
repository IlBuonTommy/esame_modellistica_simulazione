% Modellizzare, studiare gli equilibri e simulare un sistema NONLINEARE di vostro interesse. Presentare durante
% l'esposizione variabili di stato, ingressi e uscite e principali caratteristiche ed eventuali criticita' della dinamica
% del sistema. La cartella modelli deterministici contiene degli esempi di modelli che potete utilizzare o da cui
% prendere esempio (ATTENZIONE: Questi articoli spesso contegono analisi piu' specifiche e complesse di quelle
% richieste: limitarsi a quanto richiesto dall’elaborato).

clear all;
close all;
clc

% Variabili di stato:
% x(t): popolazione di prede al tempo t
% y(t): popolazione di predatori al tempo t

% Ingressi:
% c: piccolo fattore di immigrazione positivo nella popolazione delle prede
% d: piccolo fattore di immigrazione positivo nella popolazione dei predatori

% Uscite:
% x(t): popolazione di prede al tempo t
% y(t): popolazione di predatori al tempo t

% Parametri:
% r: tasso di crescita della popolazione di prede
% a: tasso di mortalità delle prede per l'incontro con i predatori
% b: tasso di conversione delle prede in predatori
% m: tasso di mortalità dei predatori

r = 0.1; 
a = 0.1; 
b = 0.3; 
m = 0.2; 

c = 0.01;
d= 0.01;

val_iniziali=[5,5];

scelta = menu("Scegli che caso analizzare:", 'A: C=0 e D=0', 'B: C=c e D=0', 'C: C=0 e D=d', 'D: C=c/x e D=0', 'E: C=0 e D=d/y');

syms x y  % Definisco variabili di tipo simbolico

switch scelta

    case 1  %CASO A

        C = 0;
        D = 0;

        %  xeq1 =
        %  0     0
        %  xeq2 =
        %  0.6667    1.0000
        %
        %  aval1 =
        %  -0.2000
        %  0.1000
        %  Stabilità: Instabile a sella
        %
        %  aval2 =
        %  0.0000 + 0.1414i
        %  0.0000 - 0.1414i
        %  Stabilità: centro

        f1 = @(t, s) [r*s(1) - a*s(1)*s(2) + C; b*s(1)*s(2) - m*s(2) + D];

    case 2 %CASO B

        C = c;
        D = 0;

        %  xeq1 =
        %  -0.1000         0
        %  xeq2 =
        %  0.6667    1.1500

        %  aval1 =
        %  0.1000
        %  -0.2300
        %  Stabilità: Instabile a sella
        %
        %  aval2 =
        %  -0.0075 + 0.1515i
        %  -0.0075 - 0.1515i
        %  Due autovalori complessi con parte reale negativa (-0.0075)
        %  Stabilità: Stabile a spirale

        f1 = @(t, s) [r*s(1) - a*s(1)*s(2) + C; b*s(1)*s(2) - m*s(2) + D];

    case 3 %CASO C

        C = 0;
        D = d;

        %  xeq1 =
        %  0    0.0500
        %  xeq2 =
        %  0.6333    1.0000


        %  aval1 =
        %  -0.2000
        %  0.0950
        %  Stabilità: Instabile a sella
        %  aval2 =
        %  -0.0050 + 0.1377i
        %  -0.0050 - 0.1377i
        %  Due autovalori complessi con parte reale negativa (-0.0050)
        %  Stabilità: Stabile a spirale

        f1 = @(t, s) [r*s(1) - a*s(1)*s(2) + C; b*s(1)*s(2) - m*s(2) + D];

    case 4 %CASO D

        C = c/x;
        D = 0;

        %  xeq1 =
        %  0.6667    1.2250
        %  xeq2 =
        %  0.0000 - 0.3162i   0.0000 + 0.0000i

        %  aval1 =
        %  -0.0225 + 0.1549i
        %  -0.0225 - 0.1549i
        %  Due autovalori complessi con parte reale negativa (-0.0225)
        %  Stabilità: Stabile a spirale
        %  aval2 =
        %  0.2000 + 0.0000i
        %  -0.2000 - 0.0949i
        %  Stabilità: Instabile a sella

        f1 = @(t, s) [r*s(1) - a*s(1)*s(2) + c/s(1); b*s(1)*s(2) - m*s(2) + D];

    case 5 %CASO E

        C = 0;
        D = d/y;

        %  xeq1 =
        %  0.6333    1.0000
        %  xeq2 =
        %  0   -0.2236

        %  aval1 =
        %  -0.0100 + 0.1375i
        %  -0.0100 - 0.1375i
        %  Stabilità: Stabile a spirale
        %  aval2 =
        %  -0.4000
        %  0.1224
        %  Stabilità: Instabile a sella

        f1 = @(t, s) [r*s(1) - a*s(1)*s(2) + C; b*s(1)*s(2) - m*s(2) + d/s(2)];


end

f = [r*x - a*x*y + C; b*x*y - m*y + D];

% PUNTI DI EQUILIBRIO
% dx/dt=0 => f=0
xeq_s = solve(f==0);

xeq1_s = [xeq_s.x(1), xeq_s.y(1)];
xeq2_s = [xeq_s.x(2), xeq_s.y(2)];

xeq1 = double(xeq1_s)
xeq2 = double(xeq2_s)

% STABILITA' PUNTI DI EQUILIBRIO
% Per determinare la stabilità di un punto di equilibrio, calcoliamo gli
% autovalori della matrice jacobiana del sistema valutata nel punto di equilibrio.

% Devo calcolare la jacobiana di f nelle direzioni di x,y
A_s = jacobian(f,[x,y]); % [x,y] indica l'ordine (e quindi la colonna) delle derivate parziali
% Calcolo la matrice A nel pto di equilibrio 1
A1_s = subs(A_s,[x,y],xeq1);
A1 = double(A1_s); % A questo punto A1 è una matrice di numeri reali e a me servono i suoi autovalori
aval1 = eig(A1)
A2_s = subs(A_s,[x,y],xeq2);
A2 = double(A2_s); % A questo punto A2 è una matrice di numeri reali e a me servono i suoi autovalori
aval2 = eig(A2)

% Rappresentazione nello spazio delle fasi

tspan = [0 1000];
% Risolve il sistema
[t, s] = ode45(f1, tspan, val_iniziali);

% Plotto lo spazio della fase
figure(1); clf;
plot(s(:,1), s(:,2));
xlabel('Grandezza popolazione prede');
ylabel('Grandezza popolazione predatori');
title('Spazio della fase' );
grid on;
