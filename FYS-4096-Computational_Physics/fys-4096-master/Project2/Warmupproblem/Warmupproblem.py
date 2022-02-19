from numpy import *
from matplotlib.pyplot import *
import h5py
from mpl_toolkits.mplot3d import Axes3D
import Project2.Warmupproblem.spline_class as spl
import Project2.Warmupproblem.linear_interp as lnr

def read_hdf5_file(fname):
    f = h5py.File(fname,"r")
    x = array(f["x_grid"])
    y = array(f["y_grid"])
    data = array(f["data"])
    f.close()
    return x,y,data

def create_hdf5_file(fname,x):

    f = h5py.File(fname,"w")
    gset = f.create_dataset("1D_DATA",data=x,dtype='f')
    gset.attrs["info"] = '1D data'
    f.close()

def main():

    fname='warm_up_data.h5'
    x,y,data = read_hdf5_file(fname)
    X,Y = meshgrid(x,y)

    #original data as 3D
    fig = figure()
    ax = fig.add_subplot(223, projection='3d')
    ax.plot_wireframe(X,Y,data.transpose())
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('data')
    ax.set_title('Original data')

    #contourf
    ax1 = fig.add_subplot(221)
    ax1.contourf(X,Y,data.transpose())
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_title('Contourf of original data')

    #interpolating original data
    spl2d=spl.spline(x=x,y = y,f=data,dims=2)

    #interpolating the path
    intrp_x = linspace(-1.5,1.5,100)
    r = sqrt(2*(-1.5-intrp_x)**2)
    F = []
    for i in range(100):
        d = spl2d.eval2d(intrp_x[i],intrp_x[i])
        F.append(d[0][0])

    #plotting interpolated path
    ax2 = fig.add_subplot(222)
    ax2.plot(r,(array(F)))
    ax2.set_xlabel('r')
    ax2.set_ylabel('interpolated data')
    ax2.set_title('Interpolated data')

    tight_layout()

    #saving interpolated data
    create_hdf5_file('warm_up_interpolated.h5',F)
    show()

if __name__=="__main__":
    main()