import numpy as np
import matplotlib.pyplot as plt
import scipy.linalg as sl
import scipy.sparse as sp
import scipy.sparse.linalg as sla
from scipy.integrate import simps
from mpl_toolkits.mplot3d import Axes3D


def gaussian(x, x0=0, width=1, k=15):
    """

    :param x: variable
    :param x0: position of peak
    :param width: width of wave
    :param k: wavenumber
    :return: gaussian propagator for given parameters
    """
    return 1 / np.sqrt(width * np.sqrt(np.pi)) * np.exp(1j * k * x) * np.exp(-(x - x0) ** 2 / (2 * width ** 2))


# end gaussian

def test_probality(x, t=0, x0=0, width=1, k=15, h_hat=1, m=1):
    """
    Returns probality of propagating gaussian at given time

    :param x: variable
    :param t: propagated time
    :param x0: position of peak
    :param width: width of wave
    :param k: wavenumber
    :param h_hat: constant
    :param m: mass
    :return: probality of propagating gaussian
    """
    alfa = np.sqrt(width ** 2 + 1j * h_hat * t / m)
    P = width / (np.abs(alfa) ** 2) / np.sqrt(np.pi) * np.exp(
        -width ** 4 / (np.abs(alfa) ** 4) * (x - x0 - h_hat * k * t / m) ** 2 / (width ** 2))

    return P


# end test_probality

def diagonal_matrix():
    """
    This function calculates gaussian wave propagation
    with Crank-Nicolson method using 1D Schrödinger equation.
    Potential is zero.

    The calculated result will be compared to analytical result
    """

    # Initializing initial conditions
    delta_t = 0.0001
    grid = np.linspace(-5, 15, 1000)
    grid_size = grid.shape[0]
    dx = grid[1] - grid[0]
    dx2 = dx * dx

    # Hamiltonian with potential zero
    H0 = sp.diags(
        [
            -0.5 / dx2 * np.ones(grid_size - 1),
            1.0 / dx2 * np.ones(grid_size),
            -0.5 / dx2 * np.ones(grid_size - 1)
        ], [-1, 0, 1])

    # Identity matrix
    I = sp.diags(1 * np.ones(grid_size))

    # Creating matrixs for Crank-Nicolson equation
    HR = I - 1j * delta_t / 2 * H0
    HL = I + 1j * delta_t / 2 * H0
    HL_inv = sla.inv(HL)

    # Initializing gaussian wave at t=0 and x0 = 0
    phi = gaussian(grid, 0)

    # Time propagation
    M = HL_inv.dot(HR)
    for i in range(0, 1000):
        phi = M.dot(phi)

    # Plotting results
    plt.figure()
    plt.plot(grid, np.abs(phi) ** 2, label='Calculated probability')
    plt.plot(grid, test_probality(grid, 0.1), color='red', label='Analytical probability')
    plt.xlabel('x')
    plt.ylabel('|$\phi$(x,t)|²')
    plt.title('Gaussian at t = 0.1 s,k = 15')
    plt.legend(loc='upper right')
    plt.show()


# end diagonal matrix

def diagonal_matrix_with_pot(POT, pos):

    """
    This function calculates gaussian wave propagation
    with Crank-Nicolson method using 1D Schrödinger equation. The potential can be chosen and
    also its position in the grid.

    Results will be plotted in 3d figure where can be seen wave at different times

    :param POT: height of potential
    :param pos: position of potential wall
    """

    # Initializing initial values
    savePOT = POT #for figure
    delta_t = 0.0001
    grid = np.linspace(-5, 15, 1000)
    grid_size = grid.shape[0]
    dx = grid[1] - grid[0]
    dx2 = dx * dx

    # Hamiltonian without potential
    H0 = sp.diags(
        [
            -0.5 / dx2 * np.ones(grid_size - 1),
            1.0 / dx2 * np.ones(grid_size),
            -0.5 / dx2 * np.ones(grid_size - 1)
        ], [-1, 0, 1])

    # Creating potential matrix where is one potential peak at given position
    a = np.zeros(1000)
    a[pos] = POT
    POT = sp.diags(abs(a) * np.ones(grid_size))

    # Identity matrix
    I = sp.diags(1 * np.ones(grid_size))

    # Creating matrixs for Crank-Nicolson equation
    HR = I - 1j * delta_t / 2 * (H0 + POT)
    HL = I + 1j * delta_t / 2 * (H0 + POT)
    HL_inv = sla.inv(HL)

    # Creating gaussian wave at t = 0, x0 = 0, width = 1 and k = 25
    phi = gaussian(grid, 0, 1, 25)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    k = 0

    # Time propagation
    M = HL_inv.dot(HR)
    for i in range(0, 4000):
        phi = M.dot(phi)
        if (i % 400 == 0):
            # Saves some waves for plotting
            ax.bar(grid, np.abs(phi) ** 2, zs=4 * k, zdir='y', alpha=0.8)
            k += 1

    plt.xlabel('x')
    plt.ylabel('100*t')

    if (savePOT == 0):
        plt.title('Propagation,V = 0,k = 25')
    else:
        plt.title(r'Potential at $x = {}, V({}) = {},k = 25$'.format(pos/100,pos/100,savePOT))
    plt.show()


# end diagonal matrix


def main():
    diagonal_matrix()
    diagonal_matrix_with_pot(0, 500)
    diagonal_matrix_with_pot(10000, 500)
    diagonal_matrix_with_pot(100000, 500)


# end main

if __name__ == "__main__":
    main()
