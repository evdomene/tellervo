#!/usr/local/bin/python

#import glob
import sys
import pandas as pd

file_list=sys.argv[1:]


#read files and add the filename in a new column
frames = []
for file in file_list: 
    df=pd.read_csv(file, header=None, sep=" ")
    df['filename'] = file
    frames.append(df)

#join different file rows in a single table
df = pd.concat(frames, axis=0) 

#add columnames
df.columns=['classorg', 'x', 'y', 'w', 'h', 'confidence', 'filename'] 

#The w h are the width and height of the bounding box divided by the size of the image. 
#To get px^2 you should multiply each value by the size of the image. 
df['area'] = df["w"]*df["h"]
df = df[["classorg", "confidence", "area", "filename"]]

#match class to human label
mtch = {0: "organoid0", 1: "organoid1", 2:"organoid3", 3:"spheroid" }
df = df.replace({"classorg":mtch})

#Write file
df.to_csv(r'AllDetections.csv', index=None) 

#Summary by filename
df.classorg=df.classorg.astype('category') 

grouped_df = df.groupby('filename')

classorg_counts = grouped_df['classorg'].value_counts()

print(classorg_counts)
#this changes organoid class to category type so zero occurences are counted.
summary = pd.DataFrame(df.groupby('filename')['classorg'].value_counts())
summary.to_csv(r'summary.csv')