from pynq import DefaultIP

class cmac(DefaultIP):
    """
    This class wrapps the common function of the CMAC IP
    """

    bindto = [
        "nus.edu.sg:RTLKernel:cmac_au50_0:1.0", 
        "nus.edu.sg:RTLKernel:cmac_au200_0:1.0",
        "nus.edu.sg:RTLKernel:cmac_au200_1:1.0",
        "nus.edu.sg:RTLKernel:cmac_au250_0:1.0",
        "nus.edu.sg:RTLKernel:cmac_au250_1:1.0",
        "nus.edu.sg:RTLKernel:cmac_au280_0:1.0",
        "nus.edu.sg:RTLKernel:cmac_au280_1:1.0"
    ]

    def __init__(self, description):
        super().__init__(description=description)
        self._fullpath = description['fullpath']
        self.start = self.start_sw = self.start_none = \
            self.start_ert = self.call

    def _setup_packet_prototype(self):
        pass
    
    def call(self, *args, **kwargs):
        raise RuntimeError("{} is a free running kernel and cannot be " 
            "starter or called".format(self._fullpath))

    def linkStatus(self):
        link = True
        txrx_ena = self.getTxRxConf()
        link &= txrx_ena['tx_ena'] & txrx_ena['rx_ena']
        rx_stat = self.getRxStat()
        link &= rx_stat['status'] & rx_stat['aligned']
        return link

    def setReset(self):
        regval = int(self.register_map.reset_reg)
        regval |= 1 << 30   # usr_rx_reset
        regval |= 1 << 31   # usr_tx_reset
        self.register_map.reset_reg = regval
    
    def clearReset(self):
        regval = int(self.register_map.reset_reg)
        regval &= ((1<<32)-1) ^ (1 << 30)   # usr_rx_reset
        regval &= ((1<<32)-1) ^ (1 << 31)   # usr_tx_reset
        self.register_map.reset_reg = regval

    def getTxRxConf(self):
        regval_tx = int(self.register_map.conf_tx)
        regval_rx = int(self.register_map.conf_rx)
        conf = {}
        conf['tx_ena'] = bool(regval_tx & (1 << 0))
        conf['rx_ena'] = bool(regval_rx & (1 << 0))
        return conf
    
    def enableTxRx(self):
        regval_tx = int(self.register_map.conf_tx)
        regval_rx = int(self.register_map.conf_rx)
        regval_tx |= 1 << 0 # ctl_tx_enable
        regval_rx |= 1 << 0 # ctl_rx_enable
        self.register_map.conf_tx = regval_tx
        self.register_map.conf_rx = regval_rx
    
    def disableTxRx(self):
        regval_tx = int(self.register_map.conf_tx)
        regval_rx = int(self.register_map.conf_rx)
        regval_tx &= ((1<<32)-1) ^ (1 << 0) # ctl_tx_enable
        regval_rx &= ((1<<32)-1) ^ (1 << 0) # ctl_rx_enable
        self.register_map.conf_tx = regval_tx
        self.register_map.conf_rx = regval_rx
    
    def getTxStat(self):
        regval = int(self.register_map.stat_tx_status)
        return {"tx_local_fault" : bool(regval & (1 << 0))} # LH
    
    def getRxStat(self):
        regval = int(self.register_map.stat_rx_status)
        regval_l = int(self.register_map.stat_rx_lane_sync)
        regval_le = int(self.register_map.stat_rx_lane_sync_err)
        rxstats = {}
        rxstats['status'] = bool(regval & (1 << 0))     # LL
        rxstats['aligned'] = bool(regval & (1 << 1))    # LL
        rxstats['misaligned'] = bool(regval & (1 << 2)) # LH
        rxstats['align_err'] = bool(regval & (1 << 3))  # LH
        rxstats['lane_sync'] = regval_l & ((1 << 20) - 1)       # LL
        rxstats['lane_sync_err'] = regval_le & ((1 << 20) - 1)  # LH
        return rxstats

