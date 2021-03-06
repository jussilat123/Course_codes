#! /usr/bin/env python
from numpy import *
import os
from nexus import settings,job,run_project,obj
from structure import read_structure
from nexus import generate_physical_system
from nexus import generate_pwscf
from machine_configs import get_taito_configs

settings(
    pseudo_dir    = './pseudopotentials',
    results       = '',
    status_only   = 0,
    generate_only = 1, 
    sleep         = 3,
    machine       = 'ws16', # is this correct for your environment
    )

jobs = get_taito_configs() # do you need to modify jobs in machine_configs.py

filename='TiO2_rutile_ICSD202240.xsf'
s = read_structure(filename)

prim = generate_physical_system(
    structure = s.copy(),
    net_spin  = 0,
    tiling    = (1,1,1),
    kgrid     = (1,1,1), # scf kgrid given separately below
    kshift    = (0,0,0),
    Ti        = 12,
    O         = 6,
)
scf_kgrid = (2,2,2)

shared_dft = obj(
    input_type  = 'generic',
    input_dft   = 'lda', # this is where the functional is given, e.g., lda or pbe
    lda_plus_u  = False,
    tot_magnetization  = 0,
    occupations = 'smearing',
    smearing    = 'fermi-dirac',
    max_seconds = 1800, # 30 minutes 
    verbosity   = 'high',
    restartable = True,
    electron_maxstep = 100,
    pseudos     = ['Ti.opt.upf','O.opt.upf'],
    nspin       = 2,
    ecutwfc     = 200,
    bandfac     = 1.3,         
    conv_thr    = 1e-6,    
    degauss     = 0.01,
    mixing_beta = 0.33,         
    kshift      = (0,0,0),
    nogamma     = True,
)
 
scf_path = 'dft/scf'
scf = generate_pwscf(
    path        = scf_path,
    identifier  = 'scf',
    calculation = 'scf',
    system      = prim,
    job         = jobs['scf'],
    wf_collect  = True,
    nosym       = False,
    kgrid       = scf_kgrid,
    **shared_dft
)
      
run_project(scf)
