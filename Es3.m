clear
syms x1 x2 u
ueq=0;
x0=[3;5];

F=[3*(x1^2+x1)*x2;-4*x2+x1-x2*u+3*u];

%PUNTO 1
%calcolo punti equilibrio
xeq_s=solve(subs(F,u,ueq)==0);
%In questo caso ottengo 2 punti di equilibrio, lo vedo dalla dimensione 
%della soluzione
%Conversione da simbolico a numerico
xeq1=double([xeq_s.x1(1),xeq_s.x2(1)]);
xeq2=double([xeq_s.x1(2),xeq_s.x2(2)]);
%questi sono i valori dei punti di equilibrio
%xeq1= 0    0           
%xeq2= -1   -1/4

%calcolo lo jacobiano
J_s=jacobian(F,[x1,x2]);
J1=double(subs(J_s,[x1,x2,u],[xeq1,ueq]));
aval1=eig(J1); %indecidibilità per via dello 0, dalla simulazione vedo che xeq1 è stabile
%aval1= -4  0

J2=double(subs(J_s,[x1,x2,u],[xeq2,ueq]));
aval2=eig(J2); %autovalore positivo e negativo quindi si ha una sella
%aval2= -4  3/4
%Il punto di equilibrio è instabile.
%Il sistema non è raggiungibile.
%Il sistema è osservabile.

%PUNTO 2
% Calcolo del grado relativo del primo 
y1=5*x2;
%y non dipende da u, quindi il sistema non ha grado relativo 0
%linea gialla simulink
dy1=jacobian(y1,[x1,x2])*F;
%15*u + 5*x1 - 20*x2 - 5*u*x2
% dipende da u quindi ha grado relativo 1, non può essere il nostro ingresso
% linearizzante.

%Calcolo del grado relativo del secondo 
y2=2*x1;
%y non dipende da u, quindi il sistema non ha grado relativo 0
%linea blu simulink
dy2=jacobian(y2,[x1,x2])*F; %neanche lei dipende da u, ha grado relativo maggiore di 1
ddy2=jacobian(dy2,[x1,x2])*F;
%(6*x1^2 + 6*x1)*(3*u + x1 - 4*x2 - u*x2) + 2*x2^2*(6*x1 + 3)*(3*x1^2 + 3*x1)
% Dipende da u, quindi ha grado relativo 2
% Se r(grado rel.) = n (ordine sistema) so che la lin. I-O non causa
% generazione di parti non osservabili o non raggiungibili

% PUNTO 3
% Controllo linearizzante si ottiene imponendo l'uscita uguale all'ingresso
% trovo l'ingresso u che faccia diventare la y l'integrale doppio di v

g = 2*x1; %SERVE PER SIMULINK

syms v
u_lin=solve(ddy2==v,u);
%L'espressione di u_lin del controllo linearizzante: 
% ((6*x1^2 + 6*x1)*(x1 - 4*x2) - v + 2*x2^2*(6*x1 + 3)*(3*x1^2 + 3*x1))/((6*x1^2 + 6*x1)*(x2 - 3))

%PUNTO 4
% Equilibrio raggiunto dopo t=2secondi
% Scrivo il sistema visto dal controllore a seguito della linearizzazione
% che nello spazio degli stati è Y/V=1/s^2

A=[0 1;0 0];
B=[0;1];
C=[1 0];

% K lo calcolo con il comando place per posizionamento autovalori 
% Quanto vale a1? (che deve garantire tempo di raggiungimento della
% stabilità T=2sec) il che significa che la costante a tempo dominante sarà
% 2/5 e quindi il polo dominante a1 = -2,5
T=2;
td=T/5; % è sempre un quinto del tempo di regime
pd=-1/td; % polo dominante
a1=pd;
K=place(A,B,[a1,2*a1]);



% Devo determinare il diffeomorfismo che lega z e x -> z=T(x)
f=[3*(x1^2+x1)*x2;-4*x2+x1]; % La prendo da F togliendo tutto ciò che dipende da u
h=2*x1;
T=[h;jacobian(h,[x1,x2])*f];


% Punto B

%Linearizzo per trovare 
%Alin Blin Clin 

Alin=J1; % Jacobiana di F rispetto a [x1,x2], calcolata in xeq1
Blin=double(subs(jacobian(F,u),[x1,x2,u],[xeq1,ueq]));
Clin1=double(subs(jacobian(y1,[x1,x2]),[x1,x2,u],[xeq1,ueq]));
Clin2=double(subs(jacobian(y2,[x1,x2]),[x1,x2,u],[xeq1,ueq]));



%

Rr = rank(ctrb(Alin,Blin));

% il rango è 1, per cui non posso controllare il sistema con una retroazione dello stato
% non calcolo K

%Farò il simulink del sistema non controllato
