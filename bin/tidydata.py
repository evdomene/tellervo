#!/usr/local/bin/python

import glob
import sys
import pandas as pd

file_list=list(sys.argv[1].split(' '))

#read files and add the filename in a new column
frames = []
for file in file_list: 
    df=pd.read_csv(file, header=None, sep=" ")
    df['filename'] = file
    frames.append(df)

#join different file rows in a single table
df = pd.concat(frames, axis=0) 

#add columnames
df.columns=['class', 'x', 'y', 'w', 'h', 'precision', 'filename'] 

#The w h are the width and height of the bounding box divided by the size of the image. 
#To get px^2 you should multiply each value by the size of the image. 
df['area'] = df["w"]*df["h"]
df = df[["class", "precision", "area", "filename"]]

#match class to human label
mtch = {0: "organoid0", 1: "organoid1", 2:"organoid3", 3:"spheroid" }
df = df.replace({"class":mtch})

#Write file
df.to_csv(r'AllPredictions.txt', index=None, sep=' ') 
df.head()