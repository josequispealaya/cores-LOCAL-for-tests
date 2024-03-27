from cocotb.triggers import RisingEdge, Timer
from numpy.random import randint


class StreamDrv:
    """Axi-Stream interface driver
    
    This class will enable the data handshake between AXI Interfaces. Take into account that you will need to
    use a stream endpoint according to its direction.
    """

    def __init__(self, clk, io_data, io_valid, io_ready) -> None:
        """StreamDrv Constructor
    
        Parameters
        ----------
        clk : DUT signal
            DUT clock signal.
        io_data : DUT signal
            DUT signal that serves as data bus.
        io_valid : DUT signal
            DUT signal that is part of the AXI-STREAM protocol.
        io_ready : DUT signal
            DUT signal that is part of the AXI-STREAM protocol.
        """
        self.clk  = clk
        self.data = io_data
        self.valid = io_valid
        self.ready = io_ready
        self.data_size = len(io_data)

    async def read(self, count, max_delay = 0):
        """Reads the stream interface. 
        
        It will only drive the ready signal.This routine is equivalent to a "receive" function.

        Parameters
        ----------
        count  : int
            Amount of bytes to be read.
        max_delay : int, optional
            Maximmun delay between reads in ns. A uniform distribution between [0, max_delay] will be used to select each delay.

        Returns
        -------
        data : list
            List with the values that were received.

        Raises
        ------
        None
        """
        
        data = []
        for _ in range(count):
            # --- Random delay befor accepting ---
            await Timer (
                time = randint(0, max_delay) if max_delay!=0 else max_delay, 
                units='ns'
            )
            await RisingEdge(self.clk)
            # ------------------------------------


            while self.valid.value == 0:
                await RisingEdge(self.clk)

            # Accept data
            self.ready.value = 1
            data.append(self.data.value.integer)
            await RisingEdge(self.clk)
            self.ready.value = 0

        return data

    async def write(self, data, max_delay = 0) -> None:
        """Writes the stream interface. 
        It will drive both the data and valid signals. This routine is equivalent to a "send" function.
        
        Parameters
        ----------
        data  : list
            List with all data values to be written to the master.
        max_delay : int, optional
            Maximmun delay between writes in ns. A uniform distribution between [0, max_delay] will be used to select each delay.

        Returns
        -------
        None.

        Raises
        ------
        ValueError
            When there is a value inside the data list that cannot be represented with the data-bus width.
        """
        self.valid.value = 1
        for d in data:
            if (self.data_size < len(bin(d)[2:])): 
                raise ValueError('Error: data %d cannot be represented with %d bits.', d, self.data_size)
            
            self.data.value = d
            await RisingEdge(self.clk)
            while self.ready.value == 0:
                await RisingEdge(self.clk)

            # --- Random delay ---
            self.valid.value = 0
            self.data.value = 0
            await Timer (
                time = randint(0, max_delay) if max_delay!=0 else max_delay, 
                units='ns'
            )
            self.valid.value = 1
            # --------------------
        self.valid.value = 0