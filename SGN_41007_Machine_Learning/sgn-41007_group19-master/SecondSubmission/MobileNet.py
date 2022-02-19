# -*- coding: utf-8 -*-
"""
Created on Sat Nov 30 17:08:35 2019

@author: Tuomo
"""
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Flatten
from tensorflow.keras.layers import Conv2D, MaxPooling2D
from tensorflow.keras import backend as K
from tensorflow.keras.layers import Flatten

import numpy as np
import cv2
import h5py
import os

def train(model):
    
    #modify only these
    batch_size = 32
    nb_epochs = 5
    train_data_dir = r"C:\Opiskelu\SGN-41007_data\train\train"
    
    train_datagen = ImageDataGenerator(rescale=1./255,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    validation_split=0.2) # set validation split

    train_generator = train_datagen.flow_from_directory(
    train_data_dir,
    target_size=(128, 128),
    batch_size=batch_size,
    #class_mode='binary',
    subset='training') # set as training data

    validation_generator = train_datagen.flow_from_directory(
    train_data_dir, # same directory as training data
    target_size=(128, 128),
    batch_size=batch_size,
    #class_mode='binary',
    subset='validation') # set as validation data
    model.fit_generator(
    train_generator,
    steps_per_epoch = train_generator.samples // batch_size,
    validation_data = validation_generator, 
    validation_steps = validation_generator.samples // batch_size,
    epochs = nb_epochs)
    
    model.save("Mobilenet.h5")
    
    
    
    
def model():
    #MOBILENET
    base_model = tf.keras.applications.mobilenet.MobileNet(
            input_shape = (128,128,3), alpha = 0.25,
            include_top = False)

    in_tensor = base_model.inputs[0] # Grab the input of base model
    out_tensor = base_model.outputs[0] # Grab the output of base model

    out_tensor = Flatten()(out_tensor)
    out_tensor = Dense(100, activation = 'relu')(out_tensor)
    out_tensor = Dense(17, activation = 'sigmoid')(out_tensor)


    model = tf.keras.models.Model(inputs = [in_tensor],
                                  outputs = [out_tensor])


    model.compile(loss=tf.keras.losses.categorical_crossentropy,
              optimizer=tf.keras.optimizers.Adadelta(),
              metrics=['accuracy'])

    model.summary()
    
    return model
    

    
    
    
    
    
    
def main():
    os.environ['CUDA_VISIBLE_DEVICES'] = '-1'
    modela = model()
    train(modela)
    
    
    

    
    
if __name__== "__main__":
    main()