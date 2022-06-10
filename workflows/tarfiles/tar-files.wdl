version 1.0


workflow tarfiles {

	# takes in tar files
	input {
		File tarFile
		String dockerImage = "tpesout/megalodon:latest"
	}
	

	call unzipFile {
		input:
			tarFile=tarFile,
			dockerImage = dockerImage
	}

		# array of unzipped tar files

	# workflow output

	output {
		Array[File] final = unzipFile.output_files

	}

}


task unzipFile {

	input {
		File tarFile

		Int diskSizeGB = 512
		String dockerImage
	}

	command {
		mkdir output
		cd output

		tar xvf ${tarFile}

	}

	output {
		Array[File] output_files = glob("output/*")
	}

	runtime {
		memory: "2 GB"
		cpu: 1
		disks: "local-disk " + diskSizeGB + " SSD"
		docker: dockerImage
		preemptible: 1
	}
	

}