import cocotb
import warnings

from cocotb.triggers import RisingEdge,FallingEdge,Timer

class _StreamInDrv:
    
    def __init__(self, data_sig, valid_sig, ready_sig) -> None:
        self.data_sig = data_sig
        self.valid_sig = valid_sig
        self.ready_sig = ready_sig
        self.data_size = len(data_sig)
    
    async def write(self, data) -> None:

        #if (self.valid_sig.value != 0):
        self.valid_sig.value = 0
        if (self.ready_sig.value == 0):
            await RisingEdge(self.ready_sig)

        #verifico el si el dato es mayor que el tamaño del vector (en bits)
        if (self.data_size < len(bin(data)[2:])):
            #si es asi, lo recorto con una operacion and
            #el (2**self.data_size - 1) me da un entero con tantos
            #bits en 1 como tamaño tenga el vector de entrada
            data = data & (2**self.data_size - 1)

        self.valid_sig.value = 1
        self.data_sig.value = data

        if (self.ready_sig.value == 1):
            await FallingEdge(self.ready_sig)
        
        self.valid_sig.value = 0
        self.data_sig.value = 0





class _StreamOutDrv:

    def __init__(self, data_sig, valid_sig, ready_sig) -> None:
        self.data_sig = data_sig
        self.valid_sig = valid_sig
        self.ready_sig = ready_sig
        self.data_size = len(data_sig)

    async def read(self, delay, units):
        if (self.ready_sig.value == 0):
            self.ready_sig.value = 1
        if (self.valid_sig.value == 0):
            await RisingEdge(self.valid_sig)
        retval = self.data_sig.value.integer
        self.ready_sig.value = 0
        await Timer (delay, units=units)
        self.ready_sig.value = 1
        return retval



        

class StreamDrv:

    def __init__(self, io_data_sig, io_valid_sig, io_ready_sig, input:bool) -> None:
        
        self.data_sig = io_data_sig
        self.valid_sig = io_valid_sig
        self.ready_sig = io_ready_sig
        
        if (input):
            self.drv_instance = _StreamInDrv(self.data_sig, self.valid_sig, self.ready_sig)
        else:
            self.drv_instance = _StreamOutDrv(self.data_sig, self.valid_sig, self.ready_sig)


    async def read(self, delay, units):
        if (type(self.drv_instance) == _StreamOutDrv):
            return await self.drv_instance.read(delay, units)
        else:
            warnings.warn("Warning! Calling read() on an Input Stream Driver!!")
    
    async def write(self, data) -> None:
        if (type(self.drv_instance) == _StreamInDrv):
            await self.drv_instance.write(data)
        else:
            warnings.warn("Warning! Calling write() on an Output Stream Driver!")
