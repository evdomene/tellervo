#!/usr/bin/env nextflow

//Channels
model_ch = Channel.fromPath("$params.weights")
<<<<<<< HEAD
images_ch = Channel.fromPath("$params.img/*.jpeg")
=======
images_ch = Channel.fromPath("$params.img")
>>>>>>> 94ef54f9ea6f8122518feff038edd5f89f94ffad
conf_ch = Channel.from("$params.confidence")

//Inference process
process predict {

<<<<<<< HEAD
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
    input:
    file predictions from predictions_ch

    output:
    file '*tidy.txt' into results_ch

    script:
    """
    #!/usr/bin/env Rscript

    library(tidyverse)
    
    filename <- c("${predictions}")
    data <- read.table("${predictions}", sep=" ", header = F) %>% 
        rename(class=V1, x=V2, y=V3, w=V4, h=V5, precision=V6) %>% 
        mutate(filename = str_replace(filename, " ", ""),
                filename=str_replace(filename, ".txt", ""), 
             class = case_when(
             class==0 ~ "organoid0",
             class==1 ~ "organoid1",
             class==2 ~ "organoid3",
             class==3 ~ "spheroid"
           ))

    write_tsv(data, paste0(filename, "tidy.txt"))
    
    """
}

//Get image with detections and table with all predictions in a results folder
results_ch.collectFile(name: "AllPredictions.txt", storeDir: 'results', keepHeader:true)

=======
publishDir 'results', mode:'copy'

input:
path images from images_ch
file weights from model_ch
val c from conf_ch

output:
file 'out' into results_ch

script:
"""
python /usr/src/app/detect.py --weights ${weights} --img 416 --conf ${c} --project out --source ${images} --save-txt  --save-conf 
"""

}
>>>>>>> 94ef54f9ea6f8122518feff038edd5f89f94ffad
