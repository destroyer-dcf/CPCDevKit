10 MEMORY 23599
20 LOAD"8BP0.bin"
30 CALL &6B78
32 MODE 0
33 BORDER 0
34 INK 0,0: INK 1,24: INK 2,3
40 DEFINT A-Z : REM variables numericas enteras (mas rápidas)
50 |SETUPSP,31,9,17: REM asigna la imagen 16 al sprite 31
60 x=40:y=100: REM coordenadas donde queremos imprimir
70 |LOCATESP,31,y,x: REM coloca el sprite 31
80 |PRINTSP,31: REM imprime el sprite 31