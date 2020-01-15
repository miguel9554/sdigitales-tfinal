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

Ya funciona el escalado, hay discrepancias con lo generado por el script en < 4% de los casos, con una discrepancia unitaria en el último decimal