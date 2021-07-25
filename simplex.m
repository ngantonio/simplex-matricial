
% ############################ INTRODUCCIÓN ###############################

% SIMPLEX MATRICIAL - Fundamentos para la Optimización Computacional
% Gabriel Oliveira: 25.091.611
% Franco Gil: 26.879.366


clc;
printf("\n \n")
printf("\t ### MÉTODO SIMPLEX MATRICIAL ### \n\n");

printf("El siguiente programa calcula un problema de maximización \n");
printf("mediante el método simplex matricial en su forma básica. \n\n");
printf("Para que este programa arroje resultados logicos y correctos,\n");
printf("el problema de optimización a calcular debe reescribirse en\n");
printf("su forma matricial añadiendo las correspondientes variables de\n");
printf("holgura y exceso según corresponda para cada restricción dada,\n");
printf("incluyendolas en la función objetivo con valores iguales a 0.\n\n");
printf("Los datos para calcular dicho problema de optimización\n");
printf("deben ser leidos desde archivo ""simplex.in"" proporcionado\n");
printf("en este mismo directorio de la forma que sigue:\n\n");
printf("linea 1: DIMENSIÓN DE LA MATRIZ (MxN)\n");
printf("linea 2: VARIABLES DEL PROBLEMA\n");
printf("linea 3: COEFICIENTES DE LA FUNCIÓN OBJETIVO\n");
printf("lineas 4...N: MATRIZ DE COEFICIENTES DEL PROBLEMA\n\n");
printf("linea N+1: RESTRICCIONES DEL PROBLEMA\n");
printf("linea N+2: VARIABLES BASICAS INCIALES\n");


printf("Si el problema a calular en su forma estandar es: \n\n");
printf("MAX 1a + 1b\n");
printf("s.a: -4a +3b + c = 4\n");
printf("      1a + 1b + d = 5\n\n");

printf("El archivo de entrada debe contener los siguientes datos:\n\n");
printf("4 2\n");
printf("a b c d\n");
printf("1 1 0 0\n");
printf("-4 3 1 0\n");
printf("1 1 0 1\n");
printf("4 5\n");
printf("a c\n");

printf("\n");


printf("OBSERVACIONES:\n");
printf("\n");
printf("1- La dimensión de la matriz es dada por el numero de variables del\n");
printf("problema incluyendo las variables de holgura y exceso(M) Y el numero\n");
printf("de restricciones que tenga el problema(N)\n\n");
printf("2- Los numeros en el archivo de entrada deben de estar separados\n");
printf("entre si por un espacio en blanco\n\n");
printf("3- OCTAVE no permite la lectura de varios caracteres como uno solo,\n");
printf("por esta razón las variables del problema deben ser de un solo caracter\n");
printf("y no deben repetirse entre si, (x1,x2,h1,e2 no son permitidas..) \n");
printf("\n \n")

% ####################### LECTURA DE DATOS ###############################

printf("Lectura de datos del archivo ""simplex.in"": \n\n");

file = fopen('simplex.in', 'r');

% Lectura de filas y columnas
rows = fscanf(file,'%d',1);
cols = fscanf(file,'%d',1);
%rows
%cols

% Lectura de las variables del problema
vars=[];
i = 1;
vars = fscanf(file,'%s',rows);
printf("\nVariables asociadas al problema estandar:\n\n");
disp(vars);

% Lectura de la funcion objetivo

C = fscanf(file,'%f',rows);
C = C';
printf("\nFunción objetivo:\n\n");
C

% Lectura de la matriz

A = fscanf(file,'%f',[rows,cols]);
A = A';
printf("\nMatriz de coeficientes:\n\n");
A

% Lectura del vector b de restricciones
b = fscanf(file,'%d',cols);
b = b;
printf("\nVector de restricciones:\n\n");
b

% Lectura de las variables base
base_vars = fscanf(file,'%s');
printf("\nVariables basicas:\n");
base_vars

fclose(file);

% -------------------------------------------------------------------------------
% Ahora tengo el sistema de ecuaciones:

% a  b  c  d  e
% 3  2 -1  0  0 -> funcion objetivo
% 5  0 -1 -1  0 
% 1  1  3  0  1
 
% si me dicen que las basicas son a y e entonces la matriz B =

% 5  0 
% 1  1

%y el vector Cb =

% 3  0

%------------------------------------------------------------------------------

% Obteniendo los indices de las variables base en el arreglo de variables:

% necesito saber en que posiciones de su vector estan las variables basicas dadas 
% para construir la matriz B, la matriz B se construye a partir de las columnas 
% cuyos indices corresponden a los de las variables basicas
index_base_vars = [];
for i = 1:length(base_vars)
  [x,y] = find(vars == base_vars(i));
  index_base_vars(i) = y;
end


% Obteniendo las columnas de la matriz A correspondientes a cada indice de 
% las variables basicas para construir la matriz B con ellas, de la misma forma, 
% se construye el vector de coeficientes de las basicas Cb.

B = zeros([length(index_base_vars),cols]);
B = B';
Cb = [];
varb = [];
i = 1;
for index = index_base_vars
  % Matriz de las basicas: B se construye con las columnas basicas de A
  col = A(:,index);
  B(:,i) = col;
  % Vector de coeficientes de las basicas
  Cb(i) = C(index);
  varb(i) = vars(index);
  i++;
end
%printf("\nMatriz de restricciones basicas:\n");
%B
%printf("\nCoeficicentes de variables basicas:\n");
%Cb



% obteniendo el vector de indices de las variables no basicas
% este vector es un Xor entre el vector de variables del problema
% y el vector de variables basicas

%printf("\nVariables no basicas:\n\n");
nobase_vars = setxor(base_vars, vars); % se obtienen las variables no basicas
%nobase_vars

% se obtienen los indices de dichas variables en un vector
index_nobase = [];
for i = 1:length(nobase_vars)
  [x,y] = find(vars == nobase_vars(i));
  index_nobase(i) = y;
end

% Obteniendo las columnas de la matriz A correspondientes a cada indice de las variables
% no basicas y construyendo la matriz N con ellas, de la misma forma, se construye el vector 
% de coeficientes de las no basicas Cn.
% se pudiera hacer un Xor entre la matriz A y la matriz B

N = zeros([length(index_nobase),cols]);
N = N';
Cn = [];
i = 1;
for index = index_nobase
  % Matriz de las NO basicas:
  col = A(:,index);
  N(:,i) = col;
  % Vector de no basicas
  Cn(i) = C(index);
  i++;
end

%printf("\nMatriz de restricciones no basicas:\n");
%N
%printf("\nCoeficicentes de las variables no basicas:\n");
%Cn

%[m,n] = min([1,8,10,14])


% Preparandose para iterar
flag = true;
i = 0;
limite = false;

while flag
  aux = [];
  cociente = [];
  B_inv = inv(B);
  Xb = B_inv * b;

  if i == 0 && find(Xb < 0)
    printf("\n:::La base introducida es invalida:::\n");
    break;
  end

  coef_nobasicas = -Cb*(B_inv*N)+Cn; % renglon de las Z
  Z = (Cb*B_inv)*b;                  % valor de Z


  % Si hay almenos un valor positivo en el coeficiente de las no basicas, no es optimo
  if find(coef_nobasicas > 0)

    if i == 10000
      limite = true;
      break;
    end

    [max_,pos_max] = max(coef_nobasicas);
    lado_derecho = B_inv*-N;
    cociente = Xb/lado_derecho(:,pos_max);              % por cuestiones de octave esta division entre vectores genera una matriz
    [min_,pos_min] = min(cociente(:,length(cociente))); % asi que, se saca es el elemento minimo de la ultima columna
    
    %intercambio la matrices  
    aux = B(:,pos_min);           % almaceno la columna de B a intercambiar
    B(:,pos_min) = N(:,pos_max);  % en la columna de B copio la columna de N
    N(:,pos_max) = aux;

    % intercambio los vectores 
    aux = Cb(pos_min);
    Cb(pos_min) = Cn(pos_max);
    Cn(pos_max) = aux;

    % intercambio las variables
    aux = base_vars(pos_min);
    base_vars(pos_min) = nobase_vars(pos_max);
    nobase_vars(pos_max) = aux;

  else
    flag = false;
  end
  i++;
end

printf("\n\n__________________________________________________________________________\n");
printf("|::::::::::::::::::::::::FIN DE LAS ITERACIONES::::::::::::::::::::::::::|\n\n");

if limite
    printf("                    :::::  Observación  :::::                           \n\n");
    printf("|Se ha alcanzado el numero de iteraciones previstas para encontrar una   |\n");
    printf("|solución factible para este problema, por lo tanto se presume que la    |\n");
    printf("|función objetivo del problema es No acotada, debe de existir un ciclo   |\n");
    printf("|ente 2 o más valores de Z                                               |\n\n");
end

printf("|:::::::::::::::::::::::::::: RESUMEN :::::::::::::::::::::::::::::::::::|\n\n");

printf("| Cantidad de iteraciones: %d\n",i);
printf("| Variables que quedaron en la base: %s \n", base_vars);
printf("| Coeficientes de las variables que quedaron en la base:\n\n");
Cb
printf("| Variables no basicas: %s \n",nobase_vars);
printf("| Coeficientes de las variables no basicas:\n\n");
coef_nobasicas
printf("| Valor de Z alcanzado: %f \n",Z);
printf("|________________________________________________________________________|\n\n");


