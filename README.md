Tellu README

# Documentation
## Google Collab
The easiest way to use Tellu for inference of your own data is through Google Collab notebook. [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1j-jutA52LlPuB4WGBDaoAhimqXC3xguX?usp=sharing) 

In this notebook, Tellu inference is run, and then the raw detections files are merged into a single file so you can proceed with your analysis. 

## Docker - Nextflow pipeline

If you have large files or you are working with sensitive data you might prefer to run the model locally. To run the inference you only need yolov5 docker image and the weights of tellu (*.pt file in https://). The output is a list of files (one per image) with each detection and precision score.
We have written a workflow with Nextflow that takes the output files and tidy them in a single file with the filenames as an extra column. The pipeline also outputs the images with the detection drawn so you can assess how good has it been. 

**Requirements**

- Docker installed (//link). 
- Nextflow installed (//link). Nextflow is a self-installing program, remember to add it to your $PATH (e.g for Linux/MACOS type xxx in the terminal)
- Git.

**Instructions**

1. Clone this repository. 
'''
git clone https://

''' 

2. Modify the config file parameters to point to your image folder. Change output directory name. 

Nextflow is used to create a pipeline. In this case, it is a simple workflow of two processes: the first process runs the images through Tellu, and the second process tidyies the output list of files into a single file with the filename information in a new column. If your filename has empty spaces or weird characters that might cause issues latter, so you should avoid it. 

Nextflow pipelines usually contain two main files, the configuration file (nextflow.config) where all the parameters are determined, and the proper nextflow (.nf file) file that describes the processes to run and their order. 
If you open the nextflow.config file you will see requires an input path for the location of your images. By default this path is data/images, you can either put your images there in the data/images and not change the config file, or you can modify the input path to point to the right folder. 
Note that to make sure nextflow finds the images you should put the whole path if the folder is not in the current folder. 

In this config file, you can also see that the confidence by default is set up at 0.5. This means that only the predictions with 0.5 or above will be written in the output file. You can modify this number if you want a more stringent threshold. 
We recommend leaving it at 0.5 and filtering detections afterward looking at the image detections if you think 0.5 was too loose. 

