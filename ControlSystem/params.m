
%% Параметры робота 
%m1 = 4.5;               % масса первого звена  
%m2 = 4.5;               % масса второго звена 
%L1 = 0.5;               % длина первого звена 
%L2 = 0.5;               % длина второго звена
mw = 0.85;              % масса колеса
L = 0.33;               % расстояние до центра масс робота от оси колёс
R = 0.12;                % радиус колеса
Jw = 0.5*mw*R^2;           % момент инерции вколеса
%Mr = m1 + m2;           % масса робота
Mr = 8.5;
g = 9.81;               % ускорение свободного падения
Rp = 0.299;             % сопротивление якоря двигателя
Km = 30.2e-3;           % коэффициент моментов
kw = 1/(317*pi/30);     % коэффициент скоростей
i = 9;                % передаточное отношение
eta = 0.8;              % КПД привода колеса
%Jq = 1/12*m2*(L2^2+0.05^2)+m2*(L2/2)^2+m2*(L1)^2;
%Jp_ = 1/12*m1*(L1^2+0.05^2)+m1*(L1/2)^2;
%J_sum = Jq + Jp_;       % момент инерции тела робота относительно оси колёс
J_sum = 0.2;
%ml = 0;                 % максимальная масса груза 
%Jl = ml*(0.2^2+0.3^2)/12 + ml*(2*L)^2;   % максимальный момент инерции груза относительно оси колёс
%% Элементы матриц E, F, G, H
z1 = (2*Jw+2*mw*R^2+Mr*R^2)/R;
z2 = -Mr*R;
z3 = (2*i^2*eta*Km*kw/Rp)/R;
z4 = Mr*L;
z5 = -(Mr*L^2 + J_sum)/(L);
z6 = -z3;
z7 = Mr*g;
k = 2*i*eta*Km/Rp;

%% Матрицы E, F, G, H
E = [z1 z2; z4 z5];
F = [z3 0; z6 0];
G = [0 0; 0 z7];
H = [k; -k];

%% Построение матриц системы A, B, C, D
A1 = zeros(2);
A2 = diag([1 1]);
A3 = -inv(E)*G;
A4 = -inv(E)*F;

B1 = [0; 0];
B2 = inv(E)*H;

K = [1 1 1 1];

A = [A1 A2; A3 A4]
B = [B1; B2]
C = diag([1 1 1 1])
D = [0; 0; 0; 0]

%% Управляемость и наблюдаемость
P = [B A*B A^2*B A^3*B]
Q = [C; C*A; C*A^2; C*A^3]

if rank(P) == 4
    fprintf('Система управляема!\n');
else
    fprintf('Система не управляема!\n');
end

if rank(Q) == 4
    fprintf('Система наблюдаема!\n');
else
    fprintf('Система не наблюдаема!\n');
end

%% Характеристическое уравнение 
lm = sym('lm');
Dl(lm) = det(A-lm*eye(4));
solve(Dl == 0)

%% Синтез
Q = diag([1 1 1 1]);
R = 0.1;
s = ss(A, B, C, D);
[K, S, e] = lqr(s, Q, R)

%% Коэффициенты для нелинейной системы
eps = -1/(L);
a1 = -z2/z1;
a2 = z2*eps/z1;
a3 = z3/z1;
a4 = k/z1;
b1 = -z4/z5;
b2 = z7/(eps*z5);
b3 = z6/z5;
b4 = -k/z5;



