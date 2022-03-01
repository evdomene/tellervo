#!/usr/bin/env nextflow

//Channels
model_ch = Channel.fromPath("$params.weights")
images_ch = Channel.fromPath("$params.img")


//Inference process
process predict {

publishDir 'runs', mode:'copy'

input:
path images from images_ch
val weights from model_ch

output:
file 'runs/detect' into results_ch

script:
'''
echo python detect.py --weights $weights --img 416 --conf 0.1 --source $images --save-txt  --save-conf 
'''

}