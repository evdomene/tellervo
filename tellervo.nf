#!/usr/bin/env nextflow

//Channels
model_ch = Channel.fromPath("$params.weights")
images_ch = Channel.fromPath("$params.img")



//Inference process
process predict {

publishDir 'results', mode:'copy'

input:
path images from images_ch
file weights from model_ch

output:
file 'out' into results_ch

script:
"""
python /usr/src/app/detect.py --weights ${weights} --img 416 --conf 0.5 --project out --source ${images} --save-txt  --save-conf 
"""

}