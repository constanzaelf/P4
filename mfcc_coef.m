% Nombre del archivo de texto
nombre_archivo = 'lpcc_2_3.txt';

% Leer el archivo de texto
datos = dlmread(nombre_archivo);

% Obtener las columnas de datos
columna_x = datos(:, 1);
columna_y = datos(:, 2);

% Graficar los puntos
figure;
plot(columna_x, columna_y, 'o');
xlabel('coeficiente 2');
ylabel('coeficiente 3');
title('Gráfico LPCC');

% Opcional: Agregar una cuadrícula al gráfico
grid on;
