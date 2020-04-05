## Trabajo final de 86.41 Sistemas Digitales - FIUBA

Este trabajo consiste en rotar las coordenadas de un mundo y dibujarlas en pantalla mediante VGA.

Cada carpeta tiene dos directorios, implementation y test, con los archivos de implementación y los tests.
La excpeción es rotator, que implementa los test con un makefile, cada test se corre con make `tb_[name]`. Los demás tests están hechos con `VUnit`.

Para implementar el módulo principal, se necesita instanciar un DCM con la herramienta de síntesis.