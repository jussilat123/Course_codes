import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import simps
from mpl_toolkits.mplot3d import Axes3D

def main():
    #lattice vectors
    a1 = np.array([1.1,0])
    a2 = np.array([1/2,1])

    N = 100

    #creating meshgrid for alfas
    alfa1,alfa2 = np.meshgrid(np.linspace(0,1,N),np.linspace(0,1,N))

    #calculating real space points for alfas
    X = alfa1*a1[0] + alfa2*a2[0]
    Y = alfa1*a1[1] + alfa2*a2[1]
    #calculating function value for X,Y s
    Z = (X+Y)*np.exp(-1/2*np.sqrt(X**2+Y**2))

    #asked integral result
    print('Integral is: ',simps(simps(Z,X),Y[:,0]))

    #plotting
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.plot_wireframe(X,Y,Z)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('F(x,y)')
    plt.plot(X,Y,color = 'black')
    plt.title('Function F')

    plt.figure()
    plt.contourf(X,Y,Z)
    plt.xlabel('x')
    plt.ylabel('y')
    plt.title('Contourf')

    plt.show()






#end main

if __name__ == "__main__":
    main()
