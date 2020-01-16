## Trabajo final de 86.41 Sistemas Digitales - FIUBA

Para correr cada testbench, `make [tb_name]`. Previamente tiene que generarse el archivo `.dat` corriendo el script que se encuentra en `utils/stimulus_generation/[tb_name].py`. Pueden generarse todos los archivos `.dat` de una pasada ejecutando `utils/generate_stimulus`

### Estado actual

- Los componentes del cordic funcionan individualmente de la manera esperada
- El testbench del cordic se encuentra
	- coords de 10 bits, testbench con 12 bits, OK
	- coords de 20 bits, testbench con 22 bits, OK
	- coords de 30 bits, testbench con 32 bits, OK
	- Con coords de 31 bits, ya tenemos bound check failures

Hay que hacer andar el escalado con coords < 31 bits, después ver cómo hacemos para trabajar con coords de más de 31 bits (el problema parece ser leerlas del archivo, la limitación esta en el límite del tipo `integer`, no en el funcionamiento del módulo)

### Update 15/01:

~Ya funciona el escalado, hay discrepancias con lo generado por el script en < 4% de los casos, con una discrepancia unitaria en el último decimal.~

Solucionado el problema (al menos pasa 10k de casos con cero error). El problema está en encontrar cual es el valor exacto de factor de escala que usa el algoritmo. Es decir, que valor toma 

`to_signed(integer(CORDIC_SCALE_FACTOR*real(2**(COORDS_WIDTH-1))), COORDS_WIDTH)`

Ahora está harcodeado para 30 bits, queda encontrar una expresión generica en función de `CORDIC_SCALE_FACTOR` y `COORDS_WIDTH`.

#### Solución

Aparentemente, hay que imitar esto

- Computar `CORDIC_SCALE_FACTOR*real(2**(COORDS_WIDTH-1))`
	- En python, lo hacemos como `PURE_CORDIC_SCALE_FACTOR*2**(WIDTH+1)`. Lo más probable es que tengan el mismo valor en ambos lenguajes
- Pasar a entero, `integer()`
	- En python, lo hacemos con `int(round())`. Aparentemente, el redondeo de python con `round` es igual al de vhdl. Si en algún momento falla, el problema puede estar en la diferencia de redondeo
- En vhdl, este valor entero se convierte a un `signed` de `COORDS_WIDTH` bits. Esta conversión no tiene ningún tipo de error. Con suficientes bits, los enteros son 1 a 1
	- En python, para obtener el factor de escala con el redondeo, multiplicar el entero anterior por `2**-(WIDTH+1)`. Esto debería dar lo mismo que multiplicar el `signed` por `2**-(WIDTH+1)` (shiftear para que quede como un decimal) y convertir el numero binario fraccionario resultante a decimal. Si falla la multiplicación, probar con esto

En resúmen, suponiendo que

- la multiplicación por `2**(COORDS...` da lo mismo en python y vhdl
- python y vhdl redondean igual
- `COORDS_WIDTH = WIDTH + 2` (el testbench en vhdl usa coordenadas 2 bits mas anchas que las que genera el script en python)

el factor de escala para usar en python es

```python
ROUNDED_CORDIC_SCALE_FACTOR = int(PURE_CORDIC_SCALE_FACTOR*2**(WIDTH+1))*2**-(WIDTH+1)
```

## Update 2 15/01

Los scripts de python ya generan la misma salida que el módulo cordic, solucionado (aparentemente) el tema de redondeo, como se explica arriba. Se probó con 10k de casos para 10, 20 y 30 bits y cero errores.