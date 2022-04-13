# Tellu - Intestinal Organoid Classifier

<p align="center">
<img src="./data/src/tellu_logo_c.svg#gh-light-mode-only" alt="Tellu Logo" width="400"/>
<img src="./data/src/tellu_logo_c_w.svg#gh-dark-mode-only" alt="Tellu Logo" width="400"/>
</p>
<br>


# Documentation

Tellu is a deep convolutional network (Yolov5) trained to classify mouse intestinal organoids from light-transmitted images into 4 classes based on morphology: 

//Add figure with organoid classes and paper DOI. 

Tellu works best with images taken from EVOS FL microscope or NikoPrimo3 microscope at 4X. 

Tellu outputs a folder with all the detections drawn in the images and also a text file where each row is a detected organoid, the class, confidence of the prediction and relative area of the bounding box (arbitrary units).

<p align="center">
<img src="./data/src/outputimage.png" alt="Representative output file" width="1000">
</p>

There are two ways to use Tellu: You can run Tellu using the Google Collaboraty enviroment or locally in your computer.

## 1. Google Collab (No coding experience needed)

The easiest way to use Tellu for inference of your own data is through Google Collab notebook. [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1j-jutA52LlPuB4WGBDaoAhimqXC3xguX?usp=sharing)
<br>

## 2. Nextflow pipeline (requires basic interaction with the terminal)

In case you prefer to run Tellu locally, we have created a nextflow pipeline that runs Tellu and tidies the output detections in a single file with an extra column with the filename information. The pipeline also outputs the images with the detections drawn so you can assess how good has it been.  

### Installation

- Install docker desktop and start it if not started automatically (<https://www.docker.com/get-started/>).  
- Install Nextflow by running the following code in the terminal (macOS/Unix):
  
```bash
curl -s https://get.nextflow.io | bash
```

  This will install nextflow in the home directory. Nextflow is a self-installing program, remember to add it to your $PATH if you want to run it from any directory on your computer. If you don't add it you will have to be in the home directory every time you want to use nextflow.

```bash
export PATH=~:$PATH
```

### Run Tellu

You can run the pipeline by typing in the terminal:  

```bash
nextflow run evdomene/tellervo --ext tif --inputdir /path/to/your/images 
```

An easy way to get the path to your image folder is after typing --inputdir drag the folder from finder to the terminal and it will write the whole path automatically.  

Note that the first time the pipeline is run, it will need to download the GitHub repository and the docker images needed to run Tellu, and therefore it will take more time than the second time you use it.  

For help and options available you can run:  

```bash
nextflow run evdomene/tellervo --help
```

After the run, you will find a results folder with an "AllDetections.txt" file and and image folder with the images with the bounding boxes drawn.  

You can find more help about nextflow at <https://www.nextflow.io/docs/latest/getstarted.html>

# Downstream analysis

After obtaining the detection file a common downstream analysis would be to read the file in R and add the metadata with the treatment and condition information to be able to summarize the data.  

**Option 1: Metadata is in a separate file**

 If the metadata information is in a separate file that has the filename of the images and the rest of the biological information you can add this information in R using left_join() from *tidyverse* package:

 ```r
 library(tidyverse)

 metadata <- read_tsv("metadata.txt")

 data <- read_tsv("AllDetections.txt") %>%
    left_join(., metadata, by=c("filename")) #filename is the name of the column that has the filename information. 

    #Note if the column in metadata is called different you can use by=c("filename"="nameinmetadata"))

 ```

**Option 2: Metadata is in the filename**

If the metadata information is in the filename (e.g Date_Treatment_Well1.txt) this information can easily be added as columns in R using the separate() function from *tidyverse*. Note that is important that the separator used between information is constant and preferentially the same pattern is consistent between filenames.  

```r
library(tidyverse)

cols = c("date", "treatment", "well")

data <- read.table("AllDetections.txt", sep=" ", header=T) %>%
  separate(filename, into=cols, sep="_", extra="merge") #extra tells what to do if there is more info after treatment. 
  #In this case it adds it to the last column. You can set it to "drop" if you want to discard it.  

```

After the metadata is added to the table, a common analysis in R would be:  

```r
#Quantify the ratio of each organoid class within each well.  

quantification <- data %>% 
  add_count( date, condition,  well) %>% #get total detections per well and add it in "n" column.
  group_by( date, condition, well, class) %>% 
  summarise(count = n(), 
            total = unique(n), 
            ratio = count/total)

#Plot results
library(ggpubr)
library(patchwork)

boxplot <- quantification %>% 
  mutate(class = fct_relevel(class, "spheroid", after=0L)) %>%  #order classes with spheroid class first. 
  ggboxplot(., x="class", color="treatment", y="ratio", facet.by = "date", add = "jitter")
  

barplotstacked <-  quantification %>%
    ggplot(aes(x=condition, y=ratio, fill=class))+
    geom_bar(position="fill", stat="identity")+
    facet_wrap(~date)+
    theme_minimal()

boxplot | barplotstacked

```
