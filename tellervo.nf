#!/usr/bin/env nextflow

//Channels
model_ch = Channel.fromPath("$params.weights")
images_ch = Channel.fromPath("$params.img/*.jpeg")
conf_ch = Channel.from("$params.confidence")


log.info """\
         ***      TELLU CLASSIFIER       *** 
         ===================================
         model: ${params.weights}
         images: ${params.img}
         confidence: ${params.confidence}
         """
         .stripIndent()




//Inference process
 process predict {
    publishDir "results", pattern: 'images/exp/*.jpeg', mode:'move'

    input:
    path images from images_ch
    val weights from model_ch.first()
    val c from conf_ch.first()

     output:
     file 'images/exp/labels/*.txt' into predictions_ch
     file ("images/exp/*.jpeg") 

     script:
     """
     python /usr/src/app/detect.py --weights $weights --img 416 --conf $c --project images --source ${images} --save-txt  --save-conf 
     """

}

//Join predictions in a single file with header and class labels
process tidydata {
    echo true
    publishDir "results", patter:'AllPredictions.txt', mode:'move'

    input:
    file predictions from predictions_ch.collect()

    output:
    file 'AllPredictions.txt' 

    script:
    """
    tidydata.py "${predictions}"
    """
}


