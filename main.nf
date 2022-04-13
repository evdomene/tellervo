#!/usr/bin/env nextflow
/*
========================================================================================
                         Tellu - Intestinal Organoid Classifier
========================================================================================
 #### Homepage / Documentation
 https://github.com/evdomene/tellervo
 #### Authors
 Eva Domenech <eva.domenechmoreno@helsinki.fi>
========================================================================================
========================================================================================
*/
nextflow.enable.dsl=1

def helpMessage() {
    log.info"""
    =========================================
     Tellu - Intestinal Organoid Classifier
    =========================================
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run evdomene/tellervo --ext 'tif' --inputdir '/images/folder/' 
    
    Required arguments:
         --inputdir      Path to directory where the images/videos are located. Default data/images
         --ext           Extension of the files to be analyzed. Default jpeg (jpeg, tiff, tif, png, bmp, avi, mp4, mov, m4v, wmv, mkv) 
         
    Optional arguments:
        --outdir         Name of the output directory. If not provided results are stored in results
        --weights        Path to model weights. By default data/models/Telluweights.pt
         
    
    """.stripIndent()
}

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}

//Channels
model_ch = Channel.fromPath("$params.weights")
images_ch = Channel.fromPath("$params.inputdir/*.$params.ext")


log.info """\
         ***       TELLU - INTESTINAL ORGANOID CLASSIFIER       *** 
         ==========================================================
         images: ${params.inputdir}
         output dir: results/${params.outdir}
         """
         .stripIndent()


//Inference process
 process predict {
    publishDir "results/${params.outdir}", pattern: "images/exp/*${params.ext}", mode:'move'

    input:
    path images from images_ch
    val weights from model_ch.first()
   
     output:
     file 'images/exp/labels/*.txt' optional true into predictions_ch
     file ("images/exp/*.$params.ext") 

     script:
     """
     python /usr/src/app/detect.py --weights $weights --img 416 --conf 0.35 --project images --source ${images} --save-txt  --save-conf --hide-labels 
     """

}

//Join predictions in a single file with header and class labels
process tidydata {
    echo true
    publishDir "results/${params.outdir}", pattern:'AllDetections.txt', mode:'move'

    input:
    file predictions from predictions_ch.collect()

    output:
    file 'AllDetections.txt' 

    script:
    """
    tidydata.py "${predictions}"
    """
}


