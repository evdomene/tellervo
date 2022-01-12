#!/usr/bin/env nextflow

//Image Annotation Conversion base on https://gist.github.com/vdalv/321876a7076caaa771d47216f382cba5](https://gist.github.com/vdalv/321876a7076caaa771d47216f382cba5


//Prepare dataset train/val/test using splitfolder


//Train process 

process train {
input:
//datayaml file check right paths
//weights?

output:
//model file and tensorboard. All in run folder 

script:
'''
python train.py --img 416 --batch 8 --epochs 500 --data $datayaml --weights yolov5s.pt --cache
'''

}

//Inference process