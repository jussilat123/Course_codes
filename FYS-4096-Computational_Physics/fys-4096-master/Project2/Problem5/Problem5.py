"""
Simple Monte Carlo for Ising model

Related to course FYS-4096 Computational Physics

Project 2
Problem 5, 2D Ising model of a ferromagnet
Comparises two different models, first is simple Ising model and second method computes also next nearest neighbour

Author:
Tuomo Jussila
252980

"""

from numpy import *
from matplotlib.pyplot import *
from scipy.special import erf


# from random import *

class Walker:
    def __init__(self, *args, **kwargs):
        self.spin = kwargs['spin']  # spin of atom
        self.nearest_neighbors = kwargs['nn']  # contains spins of nearest neighbours
        self.nearest_nearest_neighbors = kwargs['nnn'] #contains spins of second nearest neighbours
        self.sys_dim = kwargs['dim']  # dimension of system
        self.coords = kwargs['coords']  # position of atom

    def w_copy(self):
        return Walker(spin=self.spin.copy(),
                      nn=self.nearest_neighbors.copy(),
                      nnn = self.nearest_nearest_neighbors.copy(),
                      dim=self.sys_dim,
                      coords=self.coords.copy())


def Energy(Walkers,option):
    E = 0.0
    J = 4.0  # given in units of k_B

    # computes energies of spins
    for walker in Walkers:
        E += site_Energy(Walkers, walker,option) / 2

    return E


def site_Energy(Walkers, Walker,option):
    E = 0.0
    J1 = 4.0  # given in units of k_B
    J2 = 1.0
    for k in range(len(Walker.nearest_neighbors)):
        j = Walker.nearest_neighbors[k]
        E += -J1 * Walker.spin * Walkers[j].spin

    #if option is b, second nearest neighbour is also computed
    if (option == 'b'):
        for k in range(len(Walker.nearest_nearest_neighbors)):
            j = Walker.nearest_nearest_neighbors[k]
            E += -J2 * Walker.spin * Walkers[j].spin

    return E


def ising(Nblocks, Niters, Walkers, beta,option):
    """
    computes Nearest neighbor spin model for ferromagnet using ising method

    :param Nblocks:
    :param Niters: iterations per blocks
    :param Walkers: includes information lattice
    :param beta: inverse temperature
    :return: upgraded Walkers, Energy, Energy**2, Acceptance ratio, magnetization, magnetization**2
    """
    M = len(Walkers)
    Eb = zeros((Nblocks,))
    Accept = zeros((Nblocks,))
    AccCount = zeros((Nblocks,))

    mag = zeros((Nblocks,))
    #mag2 = zeros((Nblocks,))
    #Eb2 = zeros((Nblocks,))

    obs_interval = 5
    for i in range(Nblocks):
        EbCount = 0
        for j in range(Niters):
            site = int(random.rand() * M)

            s_old = 1.0 * Walkers[site].spin

            E_old = site_Energy(Walkers, Walkers[site],option)

            # selection of new spin to variable s_new
            # choosing s_new randomly to up or down
            items = [-1, 1]
            direction = random.choice(items)
            s_new = s_old * direction

            Walkers[site].spin = 1.0 * s_new

            E_new = site_Energy(Walkers, Walkers[site],option)

            # Metropolis Monte Carlo
            q_s_sp = exp(-beta * (E_new - E_old))
            A_stosp = min(1.0, q_s_sp)
            if (A_stosp > random.rand()):
                Accept[i] += 1.0
            else:
                Walkers[site].spin = 1.0 * s_old
            AccCount[i] += 1

            if j % obs_interval == 0:
                E_tot = Energy(Walkers,option) / M  # energy per spin
                Eb[i] += E_tot
                EbCount += 1

                # spin and magne
                spins = []
                for walker in Walkers:
                    spins.append(walker.spin)

                mag[i] += sum(spins) /len(spins)

        Eb[i] /= EbCount
        mag[i] /= EbCount
        Accept[i] /= AccCount[i]

        print('Block {0}/{1}'.format(i + 1, Nblocks))
        print('    E   = {0:.5f}'.format(Eb[i]))
        print('    Acc = {0:.5f}'.format(Accept[i]))

    return Walkers, Eb, Accept, mag

def problem5(grid_side,temperatures,option):
    """

    :param grid_side: size of lattice
    :param temperature_size: how many temperatures will be computed
    :param option: information if second nearest neighbour will be computed
    :return: Temperatures, Heat capacities, magnetizations, susceptibilites and energies
    """
    Tline = temperatures
    all_susceptibility = []
    all_magnetization = []
    all_heat_capacity = []
    all_energies = []
    all_energy_error = []
    all_magnetization_error = []

    for T in temperatures:
        Walkers = []

        dim = 2

        # initializing mapping matrix which is needed to find right atom of Walker array
        mapping = zeros((grid_side, grid_side), dtype=int)  # mapping
        inv_map = []  # inverse mapping
        ii = 0
        for i in range(grid_side):
            for j in range(grid_side):
                mapping[i, j] = ii
                inv_map.append([i, j])
                ii += 1

        # initalizing initial condition where all spins are up
        for i in range(grid_side):
            for j in range(grid_side):
                # nearest neighbour atoms
                j1 = mapping[i, (j - 1) % grid_side]
                j2 = mapping[i, (j + 1) % grid_side]
                i1 = mapping[(i - 1) % grid_side, j]
                i2 = mapping[(i + 1) % grid_side, j]

                # second nearest neighbour atoms
                jj1 = mapping[(i + 1) % grid_side, (j + 1) % grid_side]
                jj2 = mapping[(i + 1)% grid_side, (j - 1) % grid_side]
                ii1 = mapping[(i - 1) % grid_side, (j - 1)% grid_side]
                ii2 = mapping[(i - 1) % grid_side, (j + 1)% grid_side]


                # initializing atom where spin is up
                # Walker is not matrix, it is grid_side*grid_side long array
                Walkers.append(Walker(spin=0.5,
                                      nn=[j1, j2, i1, i2],  # positions of nearest neighbour atoms
                                      nnn=[jj1, jj2, ii1, ii2],  # positions of second nearest neighbour atoms
                                      dim=dim,
                                      coords=[i, j]))
        Nblocks = 200
        Niters = 1000
        eq = 20  # equilibration "time"
        beta = 1.0 / T # inverse temperature

        """
        Notice: Energy is measured in units of k_B, which is why
                beta = 1/T instead of 1/(k_B T)
        """
        #computes using ising model
        Walkers, Eb, Acc, mag = ising(Nblocks, Niters, Walkers, beta, option)

        Eb = Eb[eq:]
        mag = mag[eq:]
        susceptibility = var(mag)/T
        heat_capacity = var(Eb)/T/T

        all_heat_capacity.append(heat_capacity)
        all_susceptibility.append(susceptibility)
        all_magnetization.append(mean(mag))
        all_energies.append(mean(Eb))
        all_energy_error.append(std(Eb))
        all_magnetization_error.append(std(mag))


    return Tline,all_heat_capacity,all_magnetization,all_susceptibility,all_energies,all_energy_error,all_magnetization_error


# end problem3

def one_temperature(grid_side,temperature,option):

    all_susceptibility = []
    all_magnetization = []
    all_heat_capacity = []
    all_energies = []
    all_energy_error = []
    all_magnetization_error = []

    T = temperature

    Walkers = []
    dim = 2

    # initializing mapping matrix which is needed to find right atom of Walker array
    mapping = zeros((grid_side, grid_side), dtype=int)  # mapping
    inv_map = []  # inverse mapping
    ii = 0
    for i in range(grid_side):
        for j in range(grid_side):
            mapping[i, j] = ii
            inv_map.append([i, j])
            ii += 1

    # initalizing initial condition where all spins are up
    for i in range(grid_side):
        for j in range(grid_side):
            # nearest neighbour atoms
            j1 = mapping[i, (j - 1) % grid_side]
            j2 = mapping[i, (j + 1) % grid_side]
            i1 = mapping[(i - 1) % grid_side, j]
            i2 = mapping[(i + 1) % grid_side, j]

            # second nearest neighbour atoms
            jj1 = mapping[(i + 1) % grid_side, (j + 1) % grid_side]
            jj2 = mapping[(i + 1)% grid_side, (j - 1) % grid_side]
            ii1 = mapping[(i - 1) % grid_side, (j - 1)% grid_side]
            ii2 = mapping[(i - 1) % grid_side, (j + 1)% grid_side]

            # initializing atom where spin is up
            # Walker is not matrix, it is grid_side*grid_side long array
            Walkers.append(Walker(spin=0.5,
                                  nn=[j1, j2, i1, i2],  # positions of nearest neighbour atoms
                                  nnn=[jj1, jj2, ii1, ii2],  # positions of second nearest neighbour atoms
                                  dim=dim,
                                  coords=[i, j]))
    Nblocks = 200
    Niters = 1000
    eq = 20  # equilibration "time"
    beta = 1.0 / T  # inverse temperature

    """
    Notice: Energy is measured in units of k_B, which is why
            beta = 1/T instead of 1/(k_B T)
    """
    # computes using ising model
    Walkers, Eb, Acc, mag = ising(Nblocks, Niters, Walkers, beta, option)

    Eb = Eb[eq:]
    mag = mag[eq:]


    susceptibility = var(mag)/T
    heat_capacity = var(Eb)/T/T

    all_heat_capacity.append(heat_capacity)
    all_susceptibility.append(susceptibility)
    all_magnetization.append(mean(mag))
    all_energies.append(mean(Eb))
    all_energy_error.append(std(Eb))
    all_magnetization_error.append(std(mag))

    return all_heat_capacity,all_magnetization,all_susceptibility,all_energies,all_energy_error,all_magnetization_error
#end one_temperature

def savedata(filename, data):
    savetxt(filename, data)
# end savetxt

def loaddata(filename):
    return loadtxt(filename)

def computedata_part1():
    """
    this compares two different neighbour methods for different temperatures. First method is simpliest, only nearest neighbours are computed.
    Second method, next nearest neighbours are also taken into computation
    a-case: only nearest neighbours
    b-case: also next nearest neighbours

    :return for both cases temperatures, heat_capacities,magnetizations,susceptibilities, energies, energy errors and magnetization errors
    """
    temperatures = linspace(0.5, 6, 20)

    #with nearest neighbour method
    Tline_a,all_heat_capacity_a,all_magnetization_a,all_susceptibility_a,all_energies_a,all_energies_error_a,all_magnetization_error_a = problem5(10,temperatures,'a')
    savedata('Tline_a',Tline_a)
    savedata('all_heat_capacity_a',all_heat_capacity_a)
    savedata('all_magnetization_a',all_magnetization_a)
    savedata('all_susceptibility_a',all_susceptibility_a)
    savedata('all_energies_a',all_energies_a)
    savedata('all_energies_error_a',all_energies_error_a)
    savedata('all_magnetization_error_a',all_magnetization_error_a)

    #with next nearest neighbour method
    Tline_b,all_heat_capacity_b,all_magnetization_b,all_susceptibility_b,all_energies_b, all_energies_error_b ,all_magnetization_error_b= problem5(10,temperatures,'b')
    savedata('Tline_b',Tline_b)
    savedata('all_heat_capacity_b',all_heat_capacity_b)
    savedata('all_magnetization_b',all_magnetization_b)
    savedata('all_susceptibility_b',all_susceptibility_b)
    savedata('all_energies_b',all_energies_b)
    savedata('all_energies_error_b',all_energies_error_b)
    savedata('all_magnetization_error_b',all_magnetization_error_b)
    return Tline_a,all_heat_capacity_a,all_magnetization_a,all_susceptibility_a,all_energies_a,all_energies_error_a,\
           all_magnetization_error_a,Tline_b,all_heat_capacity_b,all_magnetization_b,all_susceptibility_b,all_energies_b,\
           all_energies_error_b ,all_magnetization_error_b
#end computedata

def computedata_part2():
    #computes energies at different lattice sizes at same temperature
    #lattice-vector has computed lattice sizes as NxN

    temperature = 6
    lattices = [4,8,16,32,64]
    heat_capacity4,magnetization4,susceptibility4,energies4,energy_error4,magnetization_error4 = one_temperature(4,temperature,'b')
    print(energies4)
    savedata('energies4',energies4)
    savedata('energy_error4',energy_error4)

    heat_capacity8,magnetization8,susceptibility8,energies8,energy_error8,magnetization_error8 =one_temperature(8, temperature, 'b')
    print(energies8)
    savedata('energies8',energies8)
    savedata('energy_error8',energy_error8)

    heat_capacity16,magnetization16,susceptibility16,energies16,energy_error16,magnetization_error16 =one_temperature(16, temperature, 'b')
    savedata('energies16',energies16)
    savedata('energy_error16',energy_error16)

    heat_capacity32,magnetization32,susceptibility32,energies32,energy_error32,magnetization_error32 =one_temperature(32, temperature, 'b')
    savedata('energies32',energies32)
    savedata('energy_error32',energy_error32)

    heat_capacity64,magnetization64,susceptibility64,energies64,energy_error64,magnetization_error64 =one_temperature(64, temperature, 'b')
    savedata('energies64',energies64)
    savedata('energy_error64',energy_error64)

    latticeenergies = []
    latticeenergies.append(energies4)
    latticeenergies.append(energies8)
    latticeenergies.append(energies16)
    latticeenergies.append(energies32)
    latticeenergies.append(energies64)

    lattice_errors = []
    lattice_errors.append(energy_error4)
    lattice_errors.append(energy_error8)
    lattice_errors.append(energy_error16)
    lattice_errors.append(energy_error32)
    lattice_errors.append(energy_error64)

    savedata('lattices',lattices)
    savedata('latticeenergies',latticeenergies)
    savedata('lattice_errors',lattice_errors)

    return lattices,latticeenergies,lattice_errors

def loaddata_part1():
    #loads computed data for part1
    Tline_a = loaddata('Tline_a')
    all_heat_capacity_a = loaddata('all_heat_capacity_a')
    all_magnetization_a = loaddata('all_magnetization_a')
    all_susceptibility_a = loaddata('all_susceptibility_a')
    all_energies_a = loaddata('all_energies_a')
    all_energies_error_a = loaddata('all_energies_error_a')
    all_magnetization_error_a = loaddata('all_magnetization_error_a')
    Tline_b = loaddata('Tline_b')
    all_heat_capacity_b = loaddata('all_heat_capacity_b')
    all_magnetization_b = loaddata('all_magnetization_b')
    all_susceptibility_b = loaddata('all_susceptibility_b')
    all_energies_b = loaddata('all_energies_b')
    all_energies_error_b = loaddata('all_energies_error_b')
    all_magnetization_error_b = loaddata('all_magnetization_error_b')

    return Tline_a,all_heat_capacity_a,all_magnetization_a,all_susceptibility_a,all_energies_a,all_energies_error_a,\
           all_magnetization_error_a,Tline_b,all_heat_capacity_b,all_magnetization_b,all_susceptibility_b,all_energies_b, \
           all_energies_error_b ,all_magnetization_error_b
#end loaddata_part1

def loaddata_part2():
    #loads computed data of part2

    lattices = loaddata('lattices')
    latticeenergies = loaddata('latticeenergies')
    lattice_errors = loaddata('lattice_errors')

    return lattices,latticeenergies,lattice_errors
#end loaddata_part2

def main():
    #if you have computed data, comment computedata calls and uncomment loaddata function calls

    Tline_a,all_heat_capacity_a,all_magnetization_a,all_susceptibility_a,all_energies_a,all_energies_error_a,\
    all_magnetization_error_a,Tline_b,all_heat_capacity_b,all_magnetization_b,all_susceptibility_b,all_energies_b, \
    all_energies_error_b ,all_magnetization_error_b = computedata_part1()

    #Tline_a,all_heat_capacity_a,all_magnetization_a,all_susceptibility_a,all_energies_a,all_energies_error_a,\
    #all_magnetization_error_a,Tline_b,all_heat_capacity_b,all_magnetization_b,all_susceptibility_b,all_energies_b, \
    #all_energies_error_b ,all_magnetization_error_b = loaddata_part1()

    lattices,latticeenergies,lattice_errors = computedata_part2()
    #lattices,latticeenergies,lattice_errors = loaddata_part2()

    #plotting
    fig1: matplotlib.figure.Figure = figure()
    ax1_1 = fig1.add_subplot(223)
    ax1_1.plot(Tline_a, all_heat_capacity_a,label = 'only nearest neighbour')
    ax1_1.plot(Tline_b, all_heat_capacity_b,label = 'also next nearest neighbour')
    ax1_1.set_title('Heat Capacity')
    ax1_1.set_xlabel('Temperature (T)')
    ax1_1.set_ylabel('C_v')
    ax1_1.legend(loc = 0,fontsize = 8)


    ax1_2 = fig1.add_subplot(224)
    ax1_2.plot(Tline_a, all_susceptibility_a,label = 'only nearest neighbour')
    ax1_2.plot(Tline_b, all_susceptibility_b,label = 'also next nearest neighbour')
    ax1_2.set_xlabel('Temperature (T)')
    ax1_2.set_ylabel('Susceptibility')
    ax1_2.set_title('Susceptibility')
    ax1_2.legend(loc=0,fontsize = 8)

    ax1_3 = fig1.add_subplot(222)
    ax1_3.plot(Tline_a, all_magnetization_a,'b',label = 'only nearest neighbour')
    ax1_3.plot(Tline_a, add(all_magnetization_a,all_magnetization_error_a),'c',label = 'only nearest neighbour error')
    ax1_3.plot(Tline_a, add(all_magnetization_a,negative(all_magnetization_error_a)),'c')

    ax1_3.plot(Tline_b, all_magnetization_b,'r',label = 'also next nearest neighbour')
    ax1_3.plot(Tline_b, add(all_magnetization_b,all_magnetization_error_b),'g',label = 'next nearest error')
    ax1_3.plot(Tline_b, add(all_magnetization_b,negative(all_magnetization_error_b)),'g')
    ax1_3.set_title('Magnetization')
    ax1_3.set_xlabel('Temperature (T)')
    ax1_3.set_ylabel('Magnetization (M)')
    ax1_3.legend(loc=0,fontsize = 8)


    ax1_4 = fig1.add_subplot(221)
    ax1_4.plot(Tline_a, all_energies_a,'b',label = 'only nearest neighbour')
    ax1_4.plot(Tline_a, add(all_energies_a,all_energies_error_a),'c',label = 'only nearest neighbour error')
    ax1_4.plot(Tline_a, add(all_energies_a,negative(all_energies_error_a)),'c')

    ax1_4.plot(Tline_b, all_energies_b,'r',label = 'also next nearest neighbour')
    ax1_4.plot(Tline_b, add(all_energies_b,all_energies_error_b),'g',label = 'next nearest error')
    ax1_4.plot(Tline_b, add(all_energies_b,negative(all_energies_error_b)),'g')
    ax1_4.set_xlabel('Temperature (T)')
    ax1_4.set_ylabel('Energy')
    ax1_4.set_title('Energy')
    ax1_4.legend(loc=0,fontsize = 8)
    tight_layout()

    #plotting without error bars
    fig2: matplotlib.figure.Figure = figure()
    ax1_1 = fig2.add_subplot(223)
    ax1_1.plot(Tline_a, all_heat_capacity_a,label = 'only nearest neighbour')
    ax1_1.plot(Tline_b, all_heat_capacity_b,label = 'also next nearest neighbour')
    ax1_1.set_title('Heat Capacity')
    ax1_1.set_xlabel('Temperature (T)')
    ax1_1.set_ylabel('C_v')
    ax1_1.legend(loc = 0,fontsize = 8)


    ax1_2 = fig2.add_subplot(224)
    ax1_2.plot(Tline_a, all_susceptibility_a,label = 'only nearest neighbour')
    ax1_2.plot(Tline_b, all_susceptibility_b,label = 'also next nearest neighbour')
    ax1_2.set_xlabel('Temperature (T)')
    ax1_2.set_ylabel('Susceptibility')
    ax1_2.set_title('Susceptibility')
    ax1_2.legend(loc=0,fontsize = 8)

    ax1_3 = fig2.add_subplot(222)
    ax1_3.plot(Tline_a, all_magnetization_a,'b',label = 'only nearest neighbour')

    ax1_3.plot(Tline_b, all_magnetization_b,'r',label = 'also next nearest neighbour')
    ax1_3.set_title('Magnetization')
    ax1_3.set_xlabel('Temperature (T)')
    ax1_3.set_ylabel('Magnetization (M)')
    ax1_3.legend(loc=0,fontsize = 8)


    ax1_4 = fig2.add_subplot(221)
    ax1_4.plot(Tline_a, all_energies_a,'b',label = 'only nearest neighbour')

    ax1_4.plot(Tline_b, all_energies_b,'r',label = 'also next nearest neighbour')
    ax1_4.set_xlabel('Temperature (T)')
    ax1_4.set_ylabel('Energy')
    ax1_4.set_title('Energy')
    ax1_4.legend(loc=0,fontsize = 8)
    tight_layout()

    #plotting lattice size comparison
    figure()
    plot(lattices,latticeenergies,label = 'Energy')
    plot(lattices,add(latticeenergies,lattice_errors),'c',label = 'error')
    plot(lattices,add(latticeenergies,negative(lattice_errors)),'c')
    xlabel('Grid_side')
    ylabel('Energy')
    title('Energies at different lattice sizes(at 6 K)')
    legend(loc = 0)


    show()

if __name__ == "__main__":
    main()
