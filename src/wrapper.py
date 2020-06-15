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

# Wrapper code segment

import oct2py
import os
import matlab.engine
import pycode.backend

def workdir():
    work_dir = os.path.dirname(os.path.realpath(__file__))
    return work_dir

class OWrapper(oct2py.Oct2Py):
    """
    wrapper class for Oct2Py
    Octave instances start with mcode in PATH
    """
    work_dir = workdir()
    mcode_path = work_dir  + "/mcode"
    def __init__(self):
        oct2py.Oct2Py.__init__(self)
        self.addpath(self.mcode_path)

    def restart(self):
        oct2py.Oct2Py.restart(self)
        self.addpath(self.mcode_path)

def mWrapper():
    """
    Returns a MATLAB engine instance, with mcode in PATH
    """
    engine = matlab.engine.start_matlab()
    work_dir = workdir()
    mcode_path = work_dir  + "/mcode"
    engine.addpath(mcode_path)
    return engine

def stop(Wrapper):
    """
    Stop the engine, delete handle
    """
    Wrapper.exit()
    del(Wrapper)

class PWrapper(pycode.backend.Core):
    def __init__(self):
        pycode.backend.Core.__init__(self)
        self.result = "None"
        self.p = {
            "g":"Not set",
            "gp": "Not set",
            "s":"Not set",
            "E":"Not set",
            "R":"Not set"
        }

    def set(self, key, value):
        self.p[key] = value

    def set_geomp(self):
        self.p["gp"] = parse_geometry(self.p["g"])

    def set_all(self, g, s, E, R):
        self.p = {
            "g": g,
            "gp": "Not set",
            "s": s,
            "E": E,
            "R": R
        }
        self.set_geomp()

    def settings(self):
        for key in self.p.keys():
            print(key,":",self.p[key])

    def exit(self):
        pass  # let the wrapper's del(self) handle it

    def show(self):
        (B0, l, f, cs) = self.result
        print("Peak axial field:", B0*1000, "mT")
        print("Effective field length:", l*1000,"mm")
        print("Focal distance for given E:", f*100,"cm")
        print("Spherical aberration for given E:", cs)
