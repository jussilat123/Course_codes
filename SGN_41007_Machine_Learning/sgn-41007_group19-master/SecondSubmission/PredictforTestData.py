# -*- coding: utf-8 -*-
"""
Created on Tue Dec  3 16:55:43 2019

@author: Tuomo
"""
import os
#import tensorflow as tf
import matplotlib.pyplot as plt
import cv2
import numpy as np
#from sklearn.model_selection import train_test_split
#from sklearn.linear_model import LogisticRegression
#from sklearn.svm import SVC
#from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
#from sklearn.ensemble import RandomForestClassifier
#from sklearn.metrics import accuracy_score
from tqdm import tqdm
from tensorflow.keras.models import load_model
                
def make_sub_file(model):
    
    class_names = sorted(os.listdir(r"C:\Opiskelu\SGN-41007_data\train\train"))
    
    with open ('submission.csv','w') as fp:
        fp.write('id,Category\n',)
        for root, dirs,files in os.walk(r"C:\Opiskelu\SGN-41007_data\test\testset"):
            for file in tqdm(files):
#               
                #extract image and transforming it
                img = plt.imread(root + os.sep + file)
                img = cv2.resize( img , (128,128))
                img = img.astype(np.float32)
                img -= 128
                
                #predicting label and saving name and predicted class
                pred = model.predict(img[np.newaxis, ...])
                index = np.argmax(pred)
                label = class_names[int(index)]
                
                fp.write("%s,%s\n"%(file[:-4],label))
                

def load_model_():
    
    model = load_model("Mobilenet.h5")

    return model
    
def main():
    
    model = load_model_()
    make_sub_file(model)
    
    
    

    
    
if __name__== "__main__":
    main()