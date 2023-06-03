PAV - P4: reconocimiento y verificación del locutor
===================================================

Obtenga su copia del repositorio de la práctica accediendo a [Práctica 4](https://github.com/albino-pav/P4)
y pulsando sobre el botón `Fork` situado en la esquina superior derecha. A continuación, siga las
instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para crear una rama con el apellido de
los integrantes del grupo de prácticas, dar de alta al resto de integrantes como colaboradores del proyecto
y crear la copias locales del repositorio.

También debe descomprimir, en el directorio `PAV/P4`, el fichero [db_8mu.tgz](https://atenea.upc.edu/mod/resource/view.php?id=3654387?forcedownload=1)
con la base de datos oral que se utilizará en la parte experimental de la práctica.

Como entrega deberá realizar un *pull request* con el contenido de su copia del repositorio. Recuerde
que los ficheros entregados deberán estar en condiciones de ser ejecutados con sólo ejecutar:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  make release
  run_spkid mfcc train test classerr verify verifyerr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recuerde que, además de los trabajos indicados en esta parte básica, también deberá realizar un proyecto
de ampliación, del cual deberá subir una memoria explicativa a Atenea y los ficheros correspondientes al
repositorio de la práctica.

A modo de memoria de la parte básica, complete, en este mismo documento y usando el formato *markdown*, los
ejercicios indicados.

## Ejercicios.

### SPTK, Sox y los scripts de extracción de características.

- Analice el script `wav2lp.sh` y explique la misión de los distintos comandos involucrados en el *pipeline*
  principal (`sox`, `$X2X`, `$FRAME`, `$WINDOW` y `$LPC`). Explique el significado de cada una de las 
  opciones empleadas y de sus valores.
  - `SOX`: Permite realizar la conversión de una señal de entrada sin cabecera a una del formato adecuado. Para la conversión se puede elegir cualquier formato de la señal de entrada y los bits utilizados entre otras cosas. Por ejemplo: sox, permite la conversión de una señal de entrada a reales en coma flotante de 32 bits con o sin cabecera.
  *faltan capturas 
  - `X2X`: Es el programa de SPTK que permite la conversión entre distintos formatos de datos, tal como se puede observar en la siguiente imagen, permite bastantes tipos de conversión, desde convertir a un formato de caracteres, hasta un unsigned long long de 8 bytes. En el caso de convertir a valores numéricos, hay que especificar hasta dónde se quiere que se redondean los valores de salida.  
  - `$FRAME`:  Divide la señal de entrada en tramas de “l” muestras con desplazamiento de ventana de periodo “p” muestras que se le indiquen y también puede elegir si el punto de comienzo es centrado o no. En nuestro caso tenemos: sptk frame -l 240 -p 80. En este caso le estamos pidiendo que nos divida la señal en tramas de 240 muestras, con un desplazamiento de 80 muestras.
  - `$WINDOW`: Multiplica cada trama por una ventana. Se puede elegir el número “l” de muestras por trama del fichero de entrada y “L” de muestras por trama del fichero de salida, el tipo de normalización (si no tiene normalización, si tiene normalización power o magnitude) y el tipo de ventana que se desea utilizar, pudiendo escoger entre 6 opciones distintas de ventana, siendo las 6 ventanas más utilizadas. 



- Explique el procedimiento seguido para obtener un fichero de formato *fmatrix* a partir de los ficheros de
  salida de SPTK (líneas 45 a 51 del script `wav2lp.sh`).
  * primero adjuntar foto de estas lineas

  - EXPLICACION:
    1. Utiliza el comando "sox" para convertir el archivo de audio WAV a una señal de tipo "signed int" de 16 bits, sin cabecera ni formato adicional.

    2. Utiliza el comando "X2X" para convertir los datos de formato "short" a formato "float".

    3. Aplica el comando "FRAME" para dividir la señal en tramas de 240 muestras, con un desplazamiento de ventana de 80 muestras.

    4. Utiliza el comando "WINDOW" para aplicar una ventana tipo Blackman a la señal, con una longitud de entrada y salida de 240 muestras.

    5. Utiliza el comando "LPC" para calcular los primeros coeficientes de predicción lineal (LPC) utilizando el método de Levison-Durbin. Se especifica el orden de predicción con el parámetro "-m" y se utiliza un tamaño de trama ("-l") de 240 muestras.

    6. La salida del proceso se redirige al archivo "$base.lp" utilizando la redirección ">".

    7. A continuación, se calcula el número de columnas y filas de la matriz resultante. Para esto, se suma uno al orden del predictor para obtener el número de columnas. El número de filas se calcula teniendo en cuenta la longitud de la señal, la longitud y desplazamiento de la ventana aplicada. Se utiliza el comando "sox" para convertir los datos de tipo float a formato ASCII y luego se utiliza el comando "wc -l" para contar el número de líneas y se resta 1.

    8. Finalmente, se tiene la matriz completa y se imprime en la salida.
  

  * ¿Por qué es más conveniente el formato *fmatrix* que el SPTK?
    OJO QUE FALTA ESTO 

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales de predicción lineal
  (LPCC) en su fichero <code>scripts/wav2lpcc.sh</code>:
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$LPC -l 240 -m $lpc_order > $base.lp || exit 1

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales en escala Mel (MFCC) en su
  fichero <code>scripts/wav2mfcc.sh</code>:
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$MFCC -l 240 -m $mfcc_order> $base.mfcc || exit 1

### Extracción de características.

- Inserte una imagen mostrando la dependencia entre los coeficientes 2 y 3 de las tres parametrizaciones
  para todas las señales de un locutor.
  
  ![image](https://github.com/constanzaelf/P4/assets/113508290/578a90e8-b99a-4bf9-9b5a-2de805e81546)

  ![image](https://github.com/constanzaelf/P4/assets/113508290/a64fd149-4178-4ecb-83fc-d73165419bd4)
  
  ![image](https://github.com/constanzaelf/P4/assets/113508290/912e4c53-3912-40fa-aaf4-79262fbcb327)


  
  + Indique **todas** las órdenes necesarias para obtener las gráficas a partir de las señales 
    parametrizadas.

    FEAT=lp run_spkid lp train
      fmatrix_show work/lp/BLOCK00/SES000/*.lp | egrep '^\[' | cut -f4,5 > lp_2_3.txt

    FEAT=lpcc run_spkid lpcc train
    fmatrix_show -H work/lpcc/BLOCK00/SES000/*.lpcc | egrep '^\[' | cut -f4,5 > lpcc_2_3.txt

    FEAT=lp run_spkid lp train
    fmatrix_show -H work/mfcc/BLOCK00/SES000/*.mfcc | egrep '^\[' | cut -f4,5 > mfcc_2_3.txt
    
  + ¿Cuál de ellas le parece que contiene más información?

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los parámetros 2 y 3 para un locutor, y rellene la tabla siguiente con los valores obtenidos.

  Comandos usados:
  1. pearson work/lp/BLOCK00/SES000/*.lp 
  2. pearson work/lpcc/BLOCK00/SES000/*.lpcc 
  3. pearson work/mfcc/BLOCK00/SES000/*.mfcc 



  |                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | &rho;<sub>x</sub>[2,3] |  -0.818326 | 0.181637 | -0.154598 |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.
  
  ![image](https://github.com/constanzaelf/P4/assets/113508290/f561b29d-d2cd-4a1a-a379-0b44a25751b3)



- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.
  
	![image](https://github.com/constanzaelf/P4/assets/113508290/f8b45afc-1337-465d-85c2-48890e05aed7)

	![image](https://github.com/constanzaelf/P4/assets/113508290/5f063898-1ab8-4dc4-9799-c3bce7d63c5b)
	
	![image](https://github.com/constanzaelf/P4/assets/113508290/62b3b9ff-a2d2-4b99-9357-ddadeef314f9)
	
	![image](https://github.com/constanzaelf/P4/assets/113508290/af9b9bda-290a-4a89-9fc7-9fe0788cb528)





  


### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.
  |                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | error rate             |11.08%|1.53% | 0.89%|

### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
  - LP:
  
  	![image](https://github.com/constanzaelf/P4/assets/113508290/c5fd9a74-1050-4477-a3f0-bc1492d7f7da)

  
  - LPCC:

	![image](https://github.com/constanzaelf/P4/assets/113508290/77e39cad-8c22-4d83-bd7f-34dd923dea78)


  - MFCC:
  	
	![image](https://github.com/constanzaelf/P4/assets/113508290/95ecabdd-c762-415a-8f68-da1d665951db)

 
### Test final

- Adjunte, en el repositorio de la práctica, los ficheros `class_test.log` y `verif_test.log` 
  correspondientes a la evaluación *ciega* final.

### Trabajo de ampliación.

- Recuerde enviar a Atenea un fichero en formato zip o tgz con la memoria (en formato PDF) con el trabajo 
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como 
  resultado del mismo.
