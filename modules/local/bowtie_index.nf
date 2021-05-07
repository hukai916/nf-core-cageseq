// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process BOWTIE_INDEX {
    tag "$fasta"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "bioconda::bowtie=1.2.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bowtie:1.2.3--py36hf1ae8f4_2"
    } else {
        container "quay.io/biocontainers/bowtie:1.2.3--py36hf1ae8f4_2"
    }

    input:
    path fasta
    path gtf

    output:
    path "*.index*"          , emit: index
    path "*.version.txt"    , emit: version

    script:
    def software  = getSoftwareName(task.process)
    """
    bowtie-build --threads $task.cpus ${fasta} ${fasta.baseName}.index
    bowtie --version | head -n 1 | cut -d" " -f3 > ${software}.version.txt
    """
}
