# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 13:23:22 2019

@author: Ananda, Mikko, Tuomo and Tanveer
"""

import tensorflow as tf
import numpy as np
import os
import matplotlib.pyplot as plt
import cv2

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

def compile_model():
    
    base_model = tf.keras.applications.mobilenet.MobileNet(
            input_shape = (224,224,3),
            include_top = False)

    in_tensor = base_model.inputs[0] # Grab the input of base model
    out_tensor = base_model.outputs[0] # Grab the output of base model
    
    # Add an average pooling layer (averaging each of the 1024 channels):
    out_tensor = tf.keras.layers.GlobalAveragePooling2D()(out_tensor)
    
    # Define the full model by the endpoints.
    model = tf.keras.models.Model(inputs = [in_tensor],
                                  outputs = [out_tensor])
    
    # Compile the model for execution. Losses and optimizers
    # can be anything here, since we don’t train the model.
    model.compile(loss = "categorical_crossentropy", optimizer = 'sgd')
    
    print('Model done')
    
    return model
    
def load_images_to_model(model,class_names):
    # Find all image files in the data directory.
    
    X = [] # Feature vectors will go here.
    y = [] # Class ids will go here.
    
    for root, dirs, files in os.walk(r"C:\Opiskelu\SGN-41007_data\train\train"):
        for name in files:
            if name.endswith(".jpg"):
                
                # Load the image:
                img = plt.imread(root + os.sep + name)
                
                # Resize it to the net input size:
                img = cv2.resize(img, (224,224))
                
                # Convert the data to float, and remove mean:
                img = img.astype(np.float32)
                img -= 128
                
                # Push the data through the model:
                x = model.predict(img[np.newaxis, ...])[0]
                
                # And append the feature vector to our list.
                X.append(x)
                
                # Extract class name from the directory name:
                
                #label = name.split(os.sep)[-2]
                label = root.split(os.sep)[-1]
                print(class_names.index(label))
                y.append(class_names.index(label))
                
    # Cast the python lists to a numpy array.
    X = np.array(X)
    y = np.array(y)
    print('Images loaded')
    return X,y

def compute_features():
    class_names = sorted(os.listdir(r"C:\Opiskelu\SGN-41007_data\train\train"))
    
    model = compile_model()
    
    X,y = load_images_to_model(model,class_names)
    
    np.savetxt('Features',X)
    np.savetxt('Labels',y)
    return X,y
    
def load_features():
    
    X = np.loadtxt('Features')
    y = np.loadtxt('Labels')
    return X,y
    

def LDA(X,y):
    
    x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.20)
    clf = LinearDiscriminantAnalysis()
    clf.fit(x_train,y_train)
    y_prediction = clf.predict(x_test)
    print(accuracy_score(y_prediction,y_test))
    

def main():
    
    #X,y = compute_features()
    X,y = load_features()
    print(np.shape(X))
    print(np.shape(y))
    
    LDA(X,y)
    

    
    
if __name__== "__main__":
    main()