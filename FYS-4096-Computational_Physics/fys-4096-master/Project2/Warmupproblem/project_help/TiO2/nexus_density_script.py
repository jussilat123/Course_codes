#! /usr/bin/env python
from numpy import *
import os
from fileio import XsfFile

fname = 'TiO2_density.xsf'
       
s = XsfFile(fname)

density=s.data[3]['3d_pwscf']['datagrid_3d_unknown'].values.copy()

# modify density
#
#
#
#

# set density
s.data[3]['3d_pwscf']['datagrid_3d_unknown'].values = density

# export xsf file with different name
fname_out = 'out_density.xsf'
s.write(fname_out)
