# Documentación sobre prueba de hardware de core "i2c_master"

### Configuraciones de hardware

El core se probo utilizando una placa EDUCIAA-FPGA con una Lattice ICE40HX-4K y una placa NUCLEO-64 con un STM32F401RE.  

Se configuró un proyecto en el STM32CubeIDE:  

+ Clock CPU: 80MHz (para cumplir con multiplo de 10MHz requisito para i2c a 400kHz), entrada externa HSE  
+ AHB/APB: Divisores por defecto  
+ Perifericos:  
    + I2C_1: i2c estandar, 400kHz (fast), esclavo en pines PB8 (SCL) y PB9 (SDA), address 0x50, clock no stretch
    deshabilitado, modo de duty Tlow/Thigh = 2
    + NVIC:   
        + External interrupts  
            + PC13 (Blue button): Falling edge  
            + PC4 : Rising Edge (¿Al dope? no lo use)  
            + PA6 : Rising Edge  
        + I2C_1:  
            + Error interrupt  
            + Event interrupt  
    + GPIO:  
        + PA5, PA10: Output, no pullup / pulldown, High Speed  
        + PA7, PA8, PA9, PB4, PB5,PB6, PB10, PC7: Input, no pullup / pulldown  

La descripción de la configuración de las señales de la FPGA esta en el respectivo pinouts.pcf  

En sintesis, las señalizaciones son las siguientes:  
``` 
FPGA         STM32
        8
dout ---/--> din
dval ------> dval
strt <------ strt
sda  <-----> sda
scl  ------> scl
```

Tabla conexiones stm32:

| STM32  | Port/PIN |
|--------|----------|
| din[7] | PA7      |
| din[6] | PB6      |
| din[5] | PC7      |
| din[4] | PA9      |
| din[3] | PA8      |
| din[2] | PB10     |
| din[1] | PB4      |
| din[0] | PB5      |
| dval   | PA6      |
| strt   | PA10     |
| sda    | PB9      |
| scl    | PB8      |

---
### Descripcion de funcionamiento

El pushbutton se usa para iniciar la transferencia, se transmite por la UART2 que ya viene configurada al usar como placa de desarrollo la NUCLEO-64 checkpoints de transferencias y eventuales avisos de error.  

El I2C se trabaja por interrupciones. se adopta una mecanica tipo memoria EEPROM donde el i2c_master escribe un byte que representa la "posicion de memoria" a leer.  

En el stm32 se preprogramo una matriz de 256 filas con 256 elementos (256 x 256). El byte de address enviado por el i2c_master selecciona en realida una de las 256 tablas y se fija la recepcion del master en 256 bytes (antes de que mande un NAK).
Por cada byte recibido el STM32 lee el dato en la "interface paralela" fabricada con GPIO's que la FPGA coloca, una vez se señaliza la validez mediante **dval**. Se valida toda una trama entera, es decir, se envian 256 bytes, se guardan byte a byte a medida que el i2c_master los deja en el puerto de salida, y luego se verifican los 256 bytes antes de volver a iniciar la transferencia.  

Las transferencias se inician a partir de un pulso en la señal **strt**, enviados por el STM a la FPGA cuando terminó de validar la trama anterior. La primera debe iniciarse a mano mediante una presion del "blue button".  

Por el puerto serie se obtiene informacion tanto de checkpint (x traamas enviadas / x tramas recibidas sin errores) como de errores que ocurriesen durante la transferencia / validacion.  

El test se detiene automáticamente luego de 1e6 (un millon) de tramas, reportando cantidad de enviadas contra cantidad de recibidas correctamente.  

Se probaron las transferencias a 100kHz y a 400kHz, resubiendo el archivo a la FPGA y cambiando el valor del parametro **CLK_DIV**  


### Aclaraciones

Se utilizo **platformio** para poder correr, debuggear y subir el codigo a la placa NUCLEO-64. Se aprovecho la utilidad **stm32pio** para poder utilizar el configurador grafico STM32CubeMX, generar el codigo necesario y compatibilizarlo con el uso de **platformio**.  

Se utilizo el Makefile presente en la carpeta para poder sintetizar y subir en un solo paso la descripcion en verilog. El codigo esta basado en el de la Wiki de la EDUCIAA, con una pequeña modificacion para crear un directorio aparte.  

Fue necesario instalar un par de reglas udev para permitir al iceprog el acceso a la interface usb del FTDI para programar la FPGA asi como tambien para que Visual Studio Code pudiese acceder al STM32 sin necesidad de utilizar sudo o de andar cambiando los permisos en `/dev/bus/usb`.  


---
### Resultados

Se transmitieron correctamente mas de 1e6 tramas para 100kHz y 1e6 tramas para 400kHz, sin que se reportase ningun error por parte del periferico i2c.  

Imagenes probatorias:  

(100kHz)[./img/100k_screencap.png]
(400kHz)[./img/400k_screencap.png]

En ambas se puede ver en la parte de abajo el monitor serial conectado al puerto serie de la NUCLEO-64. Los valores impresos estan en hexadecimal debido a que se esperaba hacer funcionar el dispositivo hasta que se produjese un error, por lo que se habia calculado un runtime para mas de 1e6 tramas.  