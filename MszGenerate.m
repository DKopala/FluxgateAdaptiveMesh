% The MIT License (MIT)
%
% Copyright (c) 2023 Dominika Kopala
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%
%
% DESCRIPTION:
% Script generating .msz file connected with the paper:
% D. Kopala, R. Szewczyk, A. Ostaszewska-Lizewska
% "Improved accuracy of FEM fluxgate models based on
% adaptive meshing"

% =============== INITIALIZATION ===============
clear all
close all
clc
warning('off')            % use if you want to turn warnings off

% =============== PARAMETERS ===============
% - PHYSICAL -
mi0 = 4.*pi.*1e-7;        % Magnetic constant
mi = 7e3.*mi0;            % Relative magnetic permeability

ro = 1e-7;                % Resitivity (Ohm*m)
R = 2e-3;                 % Radius of the cores (m)
I = 1;                    % Total driving current in the wire (A)

% - EDDY CURRENTS DISTRIBUTION -
r = 0:0.01.*R:R;          % Distance from the core's axis (m)
f = 200;                  % Driving current frequency (Hz)

J = [];                   % Eddy current amplitude (MA/m^2)

% - MODELLING PARAMETERS -
b = 3;                    % Number of division points
n_lay = 3;                % Number of layers in each section

% - FLUXGATE SENSOR PARAMETERS -
n_core = 2;               % Number of cores

% Axis line parameters
z1 = [-30,-30];           % Z coordinate - beginning of the core (mm)
z2 = [30,30];             % Z coordinate - end of the core (mm)

% XY parameters of cores' cross-section
x0 = [-4,4];              % X coordinates (mm)
y0 = [0,0];               % Y coordinates (mm)

% - CALCULATED PARAMETERS -
w=2.*pi.*f;               % Angular frequency
k=sqrt(-1.*w.*mi.*i./ro); % k parameter from equation (2)

% - Calculation of eddy currents amplitude from equation (1) -
for n1=1:numel(r)         % for each radius
  J = [J abs(k.*I./(2.*pi.*R).*J0(k.*r(n1))./J1(k.*R))];
end

% === PLOT EDDY CURRENTS AMPLITUDE ===
figure(1)
plot(r.*1e3,J./1e6,'linewidth',3);
set(gca,'fontsize',24);
xlabel('{\it distance from core axis r (mm)}');
ylabel('{\it eddy current density i (MA/m^2)}');
grid;

hold on;

% === CALCULATE DIVISION POINTS ===
rb=0;                     % Division points values on X axis (r axis)(m)
Jb=min(J);                % Y value for division points: J(rb)

for n1=1:b                % for each section

  x=interp1(J,r,max(J).*n1./b);
  % interpolate J function to get J values for division points
  if ~isnan(x)
    rb=[rb x];            % add new division point to the tab
    Jb=[Jb interp1(r,J,rb(end))]; % put J(rb) in Jb tab
  end

end

% === PLOT DIVISION POINTS ===
% - DRAW DIVISION POINTS -
plot(rb.*1e3,Jb./1e6,'or','linewidth',2);

% -DRAW STRAIGHT LINE ACROSS DIVISION POINTS -
for n1=1:numel(rb)
  plot([rb(n1).*1e3,rb(n1).*1e3],[0, J(end)./1e6],'-r','linewidth',1);
end

hold off

% - WARNING MESSAGE IN CASE TOO LESS DIVISION POINTS EXIST -
if numel(rb)==2
  fprintf('\n Too less division points to divide into sections! \n\n');
  return
end

% ============ MESH PARAMETERS GENERATION ============
% - INITIALIZATION OF CIRCLE AND MESH PARAMETERS -
% Temporary parameters
x = 0;
y = 0;
r = 0;
n = 0;                        % Numer of points in one circle
maxh = 0;

% Parameters for whole mesh
x_tab = [];
y_tab = [];
n_tab = [];                   % Number of points in total
maxh_tab = [];

dist_lay = 0;                 % Distance between specific sections
n_circ = b+(n_lay-1).*(b-1);  % Number of circles in one core

% - CALCULATION OF CIRCLE AND MESH PARAMETERS -
for i = 1:n_core              % for each core
  for j = 1:n_circ            % for each circle

    % If is_division = 0, we are in division point
    % If not, we are in layer point
    is_division = mod(j-1,n_lay);
    % Number of current division n1
    n1 = floor((j-1)./n_lay)+2;

    % Calculate distance between sections
    dist_lay = rb(n1)-rb(n1-1);
    if(n1 == 2) % If it's the first division point
      dist_lay = rb(n1+1)-rb(n1); % Substract 2nd from 1st
    end

    % Set maxh value for a specific circle
    maxh = dist_lay./n_lay.*1e3;
    % Set radius value for a specific circle
    if(is_division == 0)  % We are in division point
      r = rb(n1).*1e3;
    else                  % We are in layer point
      % Number of current layer n2
      n2 = is_division;
      r = (rb(n1)+n2./n_lay.*dist_lay).*1e3;
    end

    % Set XY coordinates for circles, calculate number of points
    [x,y,n] = MakeCircle(x0(i),y0(i),r,maxh);

    % Append data
    x_tab = [x_tab x];
    y_tab = [y_tab y];
    n_tab = [n_tab n];
    maxh_tab = [maxh_tab maxh];
  end
end

% - PLOT MESH REFINMENT POINTS IN CORES' CROSS-SECTIONS -
figure(2)
plot (x_tab,y_tab,'ob')

% ========= GENERATE MSZ MESH FILE =========
% - FILE INITIALIZATION -
file_name = 'refinement';                   % select name for your file
file_full_name = strcat(file_name,'.msz');
mesh_file = fopen(file_full_name,'w');        % open new file

% - WRITE FILE HEADER -
% number of points - no points are generated
fprintf(mesh_file,"0\n");
% number of lines
n_total = sum(n_tab);
fprintf(mesh_file,"%d\n",n_total);

% Number identifying mesh size
j = 0;
% lines for dense mesh
for i = 1:n_total
  j += 1;
  if j>n_circ
    j = 1;
  endif
  % each line definition
  fprintf(mesh_file,"%4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.4f\n",...
  x_tab(i),y_tab(i),z1(1),x_tab(i),y_tab(i),z2(1),maxh_tab(j));
end

fclose(mesh_file);                          % close and save file
% ======================== THE END OF SCRIPT ========================
