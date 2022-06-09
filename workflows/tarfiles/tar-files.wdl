version 1.0


workflow tester_tar {

    # takes in tar files
    input {
        Array[File] tar_files
        String dockerImage = "tpesout/megalodon:latest"
    }
    

    scatter (file in tar_files) {

        # unzip one tar file at a time

        call unzipFile {
            input:
                tarFile=file,
                dockerImage = dockerImage
        }

        # array of unzipped tar files

        Array[File] files = unzipFile.output_files


        # zip files again as a tester
        call tarFiles {
            input:
                files_to_tar = files,
                dockerImage = dockerImage

        }


    }

    # workflow output

    output {
        Array[File] final = tarFiles.out
    }

    
}


task tarFiles {

    input {
        Array[File] files_to_tar
        String outname

        Int diskSizeGB = 512
        Array[String] zones = ['us-west1-b']
        String dockerImage
    }


    command {
        tar -czvf ${outname}.tar.gz ${sep=" " files_to_tar}
    }

    output {
        File out = "${outname}.tar.gz"
    }

    runtime {
        memory:"2 GB"
        cpu: 1
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: dockerImage
        preemptible: 1
        zones: zones
    }
}

task unzipFile {

    input {
        File tarFile

        Int diskSizeGB = 512
        Array[String] zones = ['us-west1-b']
        String dockerImage
    }

    command {
        mkdir output
        cd output

        if [[ "${tarFile}" == *.tar ]] || [[ "${tarFile}" == *.tar.gz ]]
        then
            tar xvf ${tarFile}
            echo "true" >../untarred
        else
            echo "false" >../untarred
        fi
        
    }


    output {
        Boolean unzipped = read_boolean("untarred")
        Array[File] output_files = glob("output/*")
    }

    runtime {
        memory: "2 GB"
        cpu: 1
        disks: "local-disk " + diskSizeGB + " SSD"
        #docker: dockerImage
        preemptible: 1
        zones: zones
    }
    

}
