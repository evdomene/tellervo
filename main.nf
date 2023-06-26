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

def helpMessage() {
    log.info"""
    =========================================
     Tellu - Intestinal Organoid Classifier
    =========================================
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run evdomene/tellervo --inputdir '/images/folder/' 
    
    Required arguments:
         --inputdir      Path to directory where the images/videos are located. Default data/images
          
         
    Optional arguments:
        --outputdir         Name of the output directory. If not provided results are stored in results
        --weights        Path to model weights. By default data/models/Telluweights.pt
         
    
    """.stripIndent()
}

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}


log.info """\
         ***       TELLU - INTESTINAL ORGANOID CLASSIFIER       *** 
         ==========================================================
         images: ${params.inputdir}
         output dir: ${params.outputdir}
         """
         .stripIndent()


//Inference process
process RunTellu {

    publishDir path: params.outputdir, mode: 'copy'

    input:
    path images 
    val tellu

    output:
    path 'out/exp/labels/*.txt', emit: detections, optional: true
    file ("out/exp/*") 

    script:
    """
    python /usr/src/app/detect.py --weights $tellu --img 416 --conf 0.35 --project out --source $images --save-txt  --save-conf --hide-labels 
    """

   

   

}


//Join predictions in a single file with header and class labels

process TidyData {
    debug true
    publishDir path: params.outputdir, mode: 'move'

    input:
    file detections 

    output:
    file 'AllDetections.csv' 
    file 'summary.csv'

    script:
    """
    tidydata.py $detections
    """

    
}


//Channels


workflow {
    tellu = Channel.fromPath(file("$params.weights"))
    images = Channel.fromPath("$params.inputdir")
        
    RunTellu(images, tellu)
    TidyData(RunTellu.out.detections.collect())
}