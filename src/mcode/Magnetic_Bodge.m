%    Copyright 2020 Andrii Yanovets
%    This file is part of solensim.
%
%    solensim is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    solensim is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with solensim.  If not, see <https://www.gnu.org/licenses/>.


%% Magnetic Field Simulation %%
% Notes %
% ??? ????? ????? ???? ???????, ?? ? ???, ??? ? ?????? ????? ????????????
% ????? ????????? ??????, ????? ??? ?????? ??? ?????? ?? ??????? ? ????
% ????????????? ?????? ???? ? ? ?????? ????? >0. ???, ???? ???? ??? ???
% ????? ??? ????????, ???????? ??????? ??? ????? ??? ???????????? ???????
% F3 ? F3+C1*F4 (C1<<1) ?????. ? ???? ???? ????????? ?????? ?? ??????
% ??????. ?? ????????? ??? ??? ?????? ???????, ? ??? ??????????? ????. ???
% ? ?? ??????, ?? ??? ?????, ? ????????? ???????? ?????? ??????? (? ??????
% ?????????? ??????????? ?????) ? ????????? ????????????? ????. ? ?????
% ???? ?????? ???????, ????? ????????? ? ?????? ????? ?? ???, ???? ??? ??
% ????? ?? ????????? ??????, ??? ???????. ?? ??? ??????.
%% Initial parameters
% ????, ???? ??? ??? ????????
uo=4*pi*10^-7; % Diamagnetic vac const.H/mm
I=8; % Max current A
Bp=100; % mT
fmn=500; % min. focal length mm
leff= 50; % eff. length of B mm
% Magnet field %
tic
a=99.5*10^-3;
b=64*10^-3;
ri=30*10^-3;
Ne=1000;
rm=ri+a/2;
ce=sqrt(-(b^2-a^2)/12);
re=rm*(1+(a^2)/(24*rm^2));
em=9.1*10^-31;
eq=1.6*10^-19;
vc=3*10^8;
pz=sqrt(2*(3.5*10^6*eq)*em);
Bz = @(z,r,c, N) ((uo*N*I*((((r+i*c).^2)./(((z.^2)+(r+i*c).^2).^1.5))+(((r-i*c).^2)./(((z.^2)+(r-i*c).^2).^1.5)))/4));
Bz2= @(z,r,c, N) Bz(z,r,c,N).^2;
syms z
d1Bz=matlabFunction(diff(Bz, z));
d2Bz=matlabFunction(diff(d1Bz, z)); % ?? ?? ???? ??????, ?????????, ? ???????, ????? ???????, ??? ????? ?????? ??? ? ??? ?????? ???????????
Bz3= @(z,r,c, N) Bz(z,r,c, N).*d2Bz(z,r,c, N);
Bz4= @(z,r,c, N) Bz(z,r,c, N).^4;
F3= @(r,c, N) integral(@(z) Bz3(z,r,c, N), -inf, inf);
F4= @(r,c, N) integral(@(z) Bz4(z,r,c, N), -inf, inf);
F2= @(r,c, N) 2*integral(@(z) Bz2(z,r,c, N), 0, inf);
f= @(r,c, N) 1/(F2(r,c, N)*(eq/(2*pz))^2);
%% Optimization %%
% Under construction %
F3un= @(x) F3(x(1),x(2),x(3));
F4un= @(x) F4(x(1),x(2),x(3));
FS=@(r,c) F3(r,c,N)+0.01*F4(r,c,N);
FSun= @(x) FS(x(1),x(2),x(3));
fun = @(x) F3(x(1),x(2),x(3))+eq^2/(3*pz^2)*F4(x(1),x(2),x(3));
% Options %
options.MaxIterations = 10000;
options.ConstraintTolerance= 1e-200;
options.StepTolerance=1e-16;
options.FunctionTolerance=1e-20;
% End %
nonlcon = @dupazalupa;
x0 = [re ce Ne];
A = []; % No other constraints
b = [];
Aeq = [];
beq = [];
lb = [];
ub = [];
x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
fun1 = @(y) F3(y(1),y(2),y(3));
y = fmincon(fun1,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
%% Visualization %%
xsol = linspace(-0.45,0.45,1024);
xsol = xsol(:);
figure(1)
plot( xsol, Bz(xsol, x(1), x(2), x(3)));

xlabel('z (m)');
ylabel('B_z on axis (T)');
title('Calculated solenoid field at 8 A');
axis([-0.4 0.4 -0.2 0.4])
line([-0.06;0.06],[-0.06;-0.06]);
line([-0.12;0.12],[-0.08;-0.08]);
line([-0.15;-0.15;+0.15;+0.15;-0.15],[-0.055;-0.15;-0.15;-0.055;-0.055]);

% Kampus MVP %
% with beam pipe diameter 108 mm
% radius beam pipe = 108/2 mm = 54 mm
% coil can have min radius of 60 mm
% length of beam pipe = length of comp coil + 40 mm for vessel
% now with mu0 and ampereturns
Radius = 0.060; %0.060
Length = 0.120; % 0.090
Plus = Length./2 + xsol;
Minus = Length./2 - xsol;
Term1 = Plus./sqrt(Plus.^2 + Radius.^2);
Term2 = Minus./sqrt(Minus.^2 + Radius.^2);
LongCoil = Term1 + Term2;

mu0 = 4*pi.*10^(-7);
Current = 10;
NTurns = 5000;
NTurnsPerLength = NTurns./Length;
FieldCoil = 0.5.*mu0.*NTurnsPerLength.*Current.*LongCoil;


RadiusComp = 0.080; %0.100
% LengthComp = 0.240; %0.200
LengthComp = 0.240; %0.200
PlusComp = LengthComp./2 + xsol;
MinusComp = LengthComp./2 - xsol;
Term1Comp = PlusComp./sqrt(PlusComp.^2 + RadiusComp.^2);
Term2Comp = MinusComp./sqrt(MinusComp.^2 + RadiusComp.^2);
CompCoil = Term1Comp + Term2Comp;
% CompCoil = 0.24.*CompCoil./max(CompCoil);


% mu0 = 4*pi.*10^(-7);
CurrentComp = 10;
NTurnsComp = 0.200.*(LengthComp/Length).*NTurns;
NTurnsPerLengthComp = NTurnsComp./LengthComp;
FieldComp = 0.5.*mu0.*NTurnsPerLengthComp.*CurrentComp.*CompCoil;

NewCoil = FieldCoil-FieldComp;
% figure;
% subplot(2,1,1);
% plot(xsol,FieldCoil,xsol,FieldComp);
% subplot(2,1,2);
% plot(xsol,NewCoil);

figure(2);
plot(xsol,FieldCoil,xsol,FieldComp,xsol,NewCoil, xsol, Bz(xsol, x(1), x(2), x(3)));
legend('Main coil','|Compensation coil|','Solenoid field','Retreived field for 8 A');
xlabel('z (m)');
ylabel('B_z on axis (T)');
title('Solenoid field at 10 A');
axis([-0.4 0.4 -0.2 0.4])
line([-0.06;0.06],[-0.06;-0.06]);
line([-0.12;0.12],[-0.08;-0.08]);
line([-0.15;-0.15;+0.15;+0.15;-0.15],[-0.055;-0.15;-0.15;-0.055;-0.055]);
%% Double check of calculated features %%
syms z
HalbBreite=vpasolve(Bz(z,x(1), x(2), x(3))==0.5*Bz(0,x(1), x(2), x(3)),z)  % m
maxBz=Bz(0, x(1), x(2), x(3)) % T
F2=  @(x1,x2, x3) 2*integral(@(z) Bz2(z,x1,x2, x3), 0, inf);
f=   @(x1,x2, x3) 1/(F2(x1,x2, x3).*(eq/(2*pz))^2);
fokusf=f( x(1), x(2), x(3)) % m
syms z
HalbBreiteF3=vpasolve(Bz(z,y(1), y(2),y(3))==0.5*Bz(0,y(1), y(2),y(3)),z)  % m
maxBzF3=Bz(0, y(1), y(2),y(3)) % T
F2=  @(x1,x2, x3) 2*integral(@(z) Bz2(z,x1,x2, x3), 0, inf);
f=   @(x1,x2, x3) 1/(F2(x1,x2, x3).*(eq/(2*pz))^2);
fokusfF3=f( y(1), y(2),y(3)) % m
%% Iteration %%
% ? ??? ?????, ????? ????? ?????, ? ????? ????? ?? ????????
toc
%% Nonlinear costraints %%
function [c,ceq] = dupazalupa(x)
uo=4*pi*10^-7; % Diamagnetic vac const.H/mm
I=8; % Max current A
Bp=100; % mT
fmn=500; % min. focal length m
leff= 50; % eff. length of B m, ? ?????, ????? ?????? ???? ???????? ??? ? ?????? ?????, ????? ??? ??? ?????
a=99.5*10^-3;
b=64*10^-3;
ri=30*10^-3;
Ne=1000;
rm=ri+a/2;
ce=sqrt(-(b^2-a^2)/12);
re=rm*(1+(a^2)/(24*rm^2));
em=9.1*10^-31;
eq=1.6*10^-19;
pz=sqrt(2*(3.5*10^6*eq)*em); % ?????, ??? ? ???????? ?? ????, ??????????? ???????... ?? ?????? ?????, ??? ???? ??????
Bz = @(z,x1,x2,x3) ((uo.*x3.*I.*((((x1+i*x2).^2)./(((z.^2)+(x1+i*x2).^2).^1.5))+(((x1-i*x2).^2)./(((z.^2)+(x1-i*x2).^2).^1.5)))./4));
Bz2= @(z,x1,x2,x3) Bz(z,x1,x2,x3).^2; % ????? ??? ????? ????? ?????????? ??????????, ? ????? ???, ??????
F2=  @(x1,x2, x3) 2*integral(@(z) Bz2(z,x1,x2, x3), 0, inf);
f=   @(x1,x2, x3) 1/(F2(x1,x2, x3).*(eq/(2*pz))^2);
c(2) = -f(x(1),x(2), x(3))+0.5;
c(3) = -x(2)+0.001; % ? ???? ?!=? ?? ?? ???? ?????, ???? ???? ??? ?????? ????????? ?? ?i??i???, ??? ? ?????? ??????? ??? ?? ????i? ??????i ????? ????????? ?? ?????? ??????? ???????
c(4) = -x(1);
c(5) = f(x(1),x(2), x(3))-1;
c(6)= abs(-Bz(0.025,x(1),x(2), x(3))+0.5*Bz(0,x(1),x(2), x(3)))-0.01; % ???????
c(1) = -Bz(0,x(1),x(2), x(3))+0.11;
ceq=[];
end
