#########################################################################
#    Copyright 2020 Anton Douginets
#    This file is part of solensim.
#
#    solensim is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    solensim is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with solensim.  If not, see <https://www.gnu.org/licenses/>.
#########################################################################

import solensim.backend.core as core
import solensim.backend.optim as optim
import solensim.backend.track as track
from solensim.units import *

import time
import pandas as pd
import numpy as np

def test_load_mcode_plugin():
    import plugins.mcode.wrapper as mwrapper
    o = mwrapper.OWrapper()
    return o

def load_ini():
    wip()

class TrackHandle(track.TrackModule):
    """
    Interlayer to tracking functionality
    """
    def __init__(self, astra):
        track.TrackModule.__init__(self, astra)
        self.linked_core = None

    # Result storage:
        self.results = pd.DataFrame()  # run info container???
        self.data = {}
        self._run_ticker = 0

    # Interaction with core:
    def bind_to_core(self, core):
        self._linked_core = core
        if core != None:
            core.register_track_module(self)
    def get_link_to_bound_core(self):
        return self._linked_core
    linked_core = property(get_link_to_bound_core, bind_to_core)

    # Logging:
    def msg(self, msg):
        dt = pd.Timestamp.fromtimestamp(time.time())
        if self.verbose:  print("%s : %s"%(dt.time(), msg))

    def use_field(self, z, Bz):
        self.msg("Updating currently used field.")
        self.astra.write_field(z, Bz)

    def get_field(self):
        self.msg("Loaded field from solenoid.dat")
        z, Bz = self.astra.read_field()
        return z, Bz

class CoreHandle(core.Core):
    """
    Pre-optim core interlayer
    """
    def __init__(self):
        core.Core.__init__(self)
        self.track = None

    def register_track_module(self, track_module):
        self.track = track_module

    # Logging:
    def msg(self, msg):
        dt = pd.Timestamp.fromtimestamp(time.time())
        if self.verbose:  print("%s : %s"%(dt.time(), msg))
