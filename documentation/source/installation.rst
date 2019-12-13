.. _installation:

Installation & Run instructions
===============================

To run the ACEseq-workflow multiple components are needed:

  * The `Roddy workflow management framework <https://github.com/TheRoddyWMS/Roddy>`_
  * ACEseq workflow plugin
  * `COWorkflowsBasePlugin <https://github.com/TheRoddyWMS/COWorkflowsBasePlugin>`_
  * `PluginBase <https://github.com/TheRoddyWMS/Roddy-Base-Plugin>`_
  * `DefaultPlugin <https://github.com/TheRoddyWMS/Roddy-Default-Plugin>`_
  * Software stack
  * Reference data

The :ref:`standard way` to install the workflow is described below and involves the installation of each of these components. For the older 1.2.10 release we currently also provide prepackaged files and a Docker container. See :ref:`prepackaged-installation` below for instructions.

.. _standard way:

The Standard Way
----------------

The standard way to install the workflow is the manual installation of all components (sorry). The first step is to have a matching Roddy installation.

If you have not done so yet, please first read a bit about how Roddy requires the plugins to be installed. Please see `here <https://roddy-documentation.readthedocs.io/>`_. In short, the Roddy core component and the "PluginBase" and the "DefaultPlugin" are installed with a specific directory layout that you get by cloning the Roddy repository or from the zip-archive in the Roddy Github Releases ("dist/plugins/" directory).

The file "buildinfo.txt" in the ACEseq repository shows you the Roddy API version that you need. We suggest you use the Roddy version with a matching major version number and the highest released minor number. For instance, if the plugin requires Roddy 3.0, use e.g. Roddy 3.5.1. To install that Roddy version please follow the instructions at the `Roddy repository <https://github.com/TheRoddyWMS/Roddy>`_ or documentation. Note that the installation also requires you to install the "PluginBase" plugin and the "DefaulPlugin" in the versions stated in the buildinfo.txt files of the plugins in the "dist/plugins/" directory of Roddy installation.

With a Roddy installation you can install the ACEseq workflow and its dependencies. To manually resolve the plugin's versions you again need to look at the "buildinfo.txt". You start from the ACEseqWorkflow plugin and recurse to its dependencies. Usually, you will probably want to install the released versions of these plugins from the zip-archives that can be found in the Github-Releases of the respective plugin or component, but you can also use the cloned repositories with the correct release tag (or just commit) checked out.

Note that the ACEseqWorkflow and the COWorkflowBasePlugin can be installed in any directory, as long as all subdirectories there match the pattern for plugin directories of Roddy. So ideally this directory should only contain installations of plugins.

The following two sections show you how to install the Conda-based software stack and the reference data.

.. _install-software-stack:

Software Stack (Conda)
^^^^^^^^^^^^^^^^^^^^^^

The workflow contains a description of a `Conda <https://conda.io/docs/>`_ environment. A number of Conda packages from `BioConda <https://bioconda.github.io/index.html>`_ are required. You should set up the Conda environment at a centralized position available from all compute hosts.

First install the BioConda channels:

::

    conda config --add channels r

::

    conda config --add channels defaults

::

    conda config --add channels conda-forge

::

    conda config --add channels bioconda

Then install the environment

::

    conda env create -n ACEseqWorkflow -f $PATH_TO_PLUGIN_DIRECTORY/resources/analysisTools/copyNumberEstimationWorkflow/environments/conda.yml

The name of the Conda environment is arbitrary but needs to be consistent with the `condaEnvironmentName` variable. You can set the `condaEnvironmentName` variable in any of the loaded configuration files (see `Roddy documentation <http://roddy-documentation.readthedocs.io/>`_) or even directly in your Roddy call via `--cvalues="condaEnvironmentName:$value"`.

If you do not want to use Conda, you can get a complete list of all packages and package versions Conda would install from the  `$PATH_TO_PLUGIN_DIRECTORY/resources/analysisTools/copyNumberEstimationWorkflow/environments/conda.yml`.

.. _install-reference-files:

Reference files
^^^^^^^^^^^^^^^

The workflow uses various files as reference files, such as a reference genome or annotation files. Depending on the contents of these files also the outcome of your analysis may change. We provide installation scripts in the `installation/` directory (currently only in the `github` branch of the repository). To download and prepare the reference files please check out the ACEseq repository and do

::

   bash $PATH_TO_PLUGIN_DIRECTORY/installation/downloadRefrences $targetDirectory

with `$targetDirectory` being the directory into which you want to install the files. The variable `baseDirectoryReference` in your configurations needs to be set to the `$targetDirectory` path.

Note that the current plugin version is tuned to be run on the hg19 human assembly, but a liftover of all files should probably enable a run on GRch38.

Note on the versioning of the dbSNP file:
The dbSNP database only maintains the newest version and has no archives of older versions. Therefore this download script will always download the newest version and subsequently filter entries according to `$DBSNP_VERSION`. However, as newer dbSNP versions might drop certain entries, the database might still change in the future. This has to be kept in mind with respect to the reproducibility of the whole workflow.


.. _prepackaged-installation:

Prepackaged files (ACEseq 1.2.10 only)
--------------------------------------

On http://bfg-nfs3.ipmb.uni-heidelberg.de you can find archives for the 1.2.10 plugin version. The prepackaged zip files contains a full Roddy / Plugin setup and include different scripts to install all necessary software and download the required reference files. Currently, we do not intent to update these prepackaged installation files or the Docker version. Note that the Roddy version packaged not capable of submitting to LSF.

Please see the standard way to install recent workflow versions.

Stand-alone Roddy for Execution on HTC Cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To run the Roddy-based version of ACEseq please download the pre-packed zip file from http://bfg-nfs3.ipmb.uni-heidelberg.de. Three steps are required to ensure running of ACEseq.

1. Run the "prepareRoddyInstallation.sh" script.
2. Download all reference files as specified in the section "Reference files" (below).
3. Set up the Conda environment or install the necessary software as specified in the section "Software" (below).

Before running ACEseq a few parameters need to be adjusted in the configuration files. The output directory is specified in $PATH_TO_ACEseq_RODDY_VERSION/configurations/projectsACEseqTest.xml. Here the variables "baseDirectoryReference", "inputBaseDirectory", "outputBaseDirectory", "outputAnalysisBaseDirectory" need to be set. If no SVs should be included the following configuration values (cvalues) should be included:

.. code-block:: ini

    <cvalue name='runWithSv' value='true' type="boolean"/>
    <cvalue name='SV' value='yes' type="boolean"/>


Otherwise "svOutputDirectory" and the SV bedpe filename in the filenames section need to be set.

.. code-block:: ini

    <configurationvalues>
      <cvalue name='svOutputDirectory' value='${outputAnalysisBaseDirectory}/nameOfDirectoryWithSVResults' type="path"/>
    </configurationvalues>

    <filenames package='de.dkfz.b080.co.files' filestagesbase='de.dkfz.b080.co.files.COFileStage'>
       <filename class="TextFile" onMethod="de.dkfz.b080.co.aceseq.ACESeqMethods.mergeSv"
                selectiontag="svFileTag"
                pattern='${svOutputDirectory}/${pid}_svs.bedpe'/>
    </filenames>

Technical specifications are set in the file $PATH_TO_ACEseq_RODDY_VERSION/configurations/applicationProperties.ini. The path to the project.xml and the path to the plugins ($PATH_TO_ACEseq_RODDY_VERSION/Roddy/dist/plugins/) need to be set under configurationDirectories and pluginDirectories. Finally the job manager and execution host need to be set.

Please have a look at the following default applicationProperties.ini file:

.. code-block:: ini

    [COMMON]
    useRoddyVersion=current                     # Use the most current version for tests

    [DIRECTORIES]
    configurationDirectories=[FOLDER_WITH_CONFIGURATION_FILES]
    pluginDirectories=[FOLDER_WITH_PLUGINS]

    [COMMANDS]
    jobManagerClass=de.dkfz.roddy.execution.jobs.direct.synchronousexecution.DirectSynchronousExecutionJobManager
    #jobManagerClass=de.dkfz.roddy.execution.jobs.cluster.pbs.PBSJobManager
    #jobManagerClass=de.dkfz.roddy.execution.jobs.cluster.sge.SGEJobManager
    #jobManagerClass=de.dkfz.roddy.execution.jobs.cluster.slurm.SlurmJobManager
    #jobManagerClass=de.dkfz.roddy.execution.jobs.cluster.lsf.rest.LSFRestJobManager
    commandFactoryUpdateInterval=300
    commandLogTruncate=80                       # Truncate logged commands to this length. If <= 0, then no truncation.

    [COMMANDLINE]
    CLI.executionServiceUser=USERNAME
    CLI.executionServiceClass=de.dkfz.roddy.execution.io.LocalExecutionService
    #CLI.executionServiceClass=de.dkfz.roddy.execution.io.SSHExecutionService
    CLI.executionServiceHost=[YOURHOST]
    CLI.executionServiceAuth=keyfile
    #CLI.executionServiceAuth=password
    CLI.executionServicePasswd=
    CLI.executionServiceStorePassword=false
    CLI.executionServiceUseCompression=false
    CLI.fileSystemInfoProviderClass=de.dkfz.roddy.execution.io.fs.FileSystemInfoProvider


To execute ACEseq run

::

    sh $PATH_TO_ACEseq_RODDY_VERSION//Roddy/roddy.sh rerun ACEseq@copyNumberEstimation $pid \
    --useconfig=$PATH_TO_ACEseq_RODDY_VERSION/configuration/applicationProperties.ini \
    --cvalues="bamfile_list:$pathToControlBamFile;$pathToTumorBamFile,sample_list:control;tumor,possibleControlSampleNamePrefixes:control,possibleTumorSampleNamePrefixes:tumor"


More information on Roddy can be found `here <https://roddy-documentation.readthedocs.io/>`_.

Docker version
^^^^^^^^^^^^^^

1. Download all reference files as specified in the section below.
2. Download the Base and ACEseq Docker images from the website: http://bfg-nfs3.ipmb.uni-heidelberg.de
3. Import both files with (names might differ based on supplied version):

::

	docker load < BaseDockerContainer.tar.gz

::

	docker load < ACEseqDockerContainer.tar.gz

4. Download the control files archive and extract them. The directory contains the file "roddy.sh". Please call this script with: bash roddy.sh. You will see:

::

        #!/bin/bash
        # 1: Run mode, which might be "run" or "testrun"
        # 2: Configuration identifier, normally "ACEseq"
        # 3: Configuration directory
        # 4: Dataset identifier / PID
        # 5: Control bam file
        # 6: Tumor bam file
        # 7: Control bam sample name
        # 8: Tumor bam sample name
        # 9: Reference files path
        # 10: Output folder
        # 11: Optional: The SV file

An example call is:

::

        bash roddy.sh run ACEseq ./config/ stds /home/roddy/someproject/control_MB99_merged.mdup.bam /home/roddy/someproject/tumor_MB99_merged.mdup.bam control tumor /icgc/ngs_share/assemblies/hg19_GRCh37_1000genomes ./output

Here you tell roddy to run the ACEseq configuration using the config folder in the current directory with a control and tumor bam. Also you tell Roddy the samples for both files namely control and tumor. Finally, you supply the path to the reference files and the folder where you will store your output data.



.. _Github-Releases: https://github.com/eilslabs/ACEseqWorkflow/releases

