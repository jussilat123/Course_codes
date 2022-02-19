#! /usr/bin/env python
from nexus import job

def general_configs(machine):
    if machine=='taito':
        jobs = get_taito_configs()
    else:
        print 'Using taito as defaul machine'
        jobs = get_taito_configs()
    return jobs

def get_taito_configs():
    # Are these correct modules for you, that is,
    # did you use these when you compiled the code
    scf_presub = '''
    module purge
    module load gcc
    module load openmpi
    module load openblas
    module load hdf5-serial
    '''

    qe='pw.x'

    # 4 processes
    scf  = job(cores=4,minutes=15,user_env=False,presub=scf_presub,app=qe)

    jobs = {'scf' : scf}

    return jobs
