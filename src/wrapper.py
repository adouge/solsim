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

import backend.backend as backend
import numpy as np

def stop(Wrapper):
    """
    Stop the engine, delete handle
    """
    Wrapper.exit()
    del(Wrapper)

class PWrapper(backend.Core):
    """
    User-facing methods of the python backend
    """
    def __init__(self):
        backend.Core.__init__(self)
        self.results = []

    def exit(self):
        pass  # let the wrapper's close() handle it

### result storage
    def append_result(self):
        result = {
        "g" : self.g,
        "s" : self.s,
        "t_g" : self.target_g,
        "t_s" : self.target_s,
        "t_B" : self.target_Bpeak,
        "t_l" : self.target_l,
        "t_f" : self.target_f,
        "t_margin" : self.margin,
        "gopt": self.g_opt,
        "sopt": self.s_opt
        }
        self.results.append(result)

### main routine interlayer
    def run_ctr(self, maxiter=100, ptol=9, gtol=9, verbose=2,penalty=0):
        constraints = self.define_ctr_constraints()
        out = self.ctr_minimize(constraints,
            max_iter=maxiter,
            ptol=ptol, gtol=gtol,
            penalty=penalty,
            verbose=verbose)
        self.s_opt = out.x[0]
        self.g_opt = out.x[1:]
        self.last_message = out.message
        self.last_out = out