"
GtDtsManager manages the running of tests or examples in a distributed system across one or more machines.

The original scenarios used to design the  system were:

- Individual developer: A developer is working in an image and wants to run tests / examples in one or more worker images on their local machine.
- Internal team: A team of developers are working, and pool their worker images for common use.
- CI: An automated system runs all tests / examples on all supported platforms, e.g. linux, mac, windows, on each commit.


The main components of the system are:

- GtDtsManager provides the primary interface to the system and the main control.
- A {{gtClass:GtDtsWorker}} is created for each client image that will run tests or examples.
- A {{gtClass:GtDtsJob}} is submitted by users for each collection or tests or examples to be executed.  The user will be notified of the progress of the job.
- {{gtClass:GtDtsTestScheduler}} is responsible for taking all the tests / examples in a job and ordering and grouping them for equitable distribution amongst the workers.


The following phases are defined as part of the system.  Each of these phases is pluggable, so can be customised for individual scenarios:

- Manager Startup: this is run once when the manager starts.  It may be used to start worker machines, etc.
- Job Startup: this may include starting the worker images on the worker machines.
- Job Execution: the phase where tests / examples are being handed out to the workers.
- Job Shutdown: this may include stopping the worker images on the worker machines.
- Manager shutdown: this is run once when the manager is stopped.  It may be used to shut down worker machines, etc.


The worker images are assumed to be up to date when the Job Execution phase is run.

The current architecture assumes that it is possible for the manager to contact all worker machines, update the images and start and stop them as required.  A WorkerManager is planned that will run on each worker machine and can contact the GtDtsManager to perform these tasks, removing the need for the GtDtsManager to know how many workers there are and be able to directly control them, e.g. via SSH.
"
Class {
	#name : #GtDtsManager,
	#superclass : #Object,
	#instVars : [
		'port',
		'server',
		'jobExecutor',
		'jobStartupAndShutdown',
		'managerStartupAndShutdown'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #initialization }
GtDtsManager >> resetImagesFilesOnS3 [
	remoteHostCluster
		runCommand: 'powershell.exe'
		arguments: (Array
				with: '-File'
				with: 'C:\Users\Administrator\git\lifeware-source\Reset-LifewareWorkerImage.ps1'
				with: '-region'
				with: 'us-east-1')
		named: 'AWS: RESET IMAGES FILES ON S3'
]

{ #category : #'as yet unclassified' }
GtDtsManager >> restartRemoteCluster [
	"managerConfiguration startRemoteImages ifFalse: [^self].
	remoteHostCluster isAwsHost ifFalse: [^self].
	timestampsCollector registerNowAs: #beginRestartRemoteAwsCluster."
	self resetImagesFilesOnS3.
	"timestampsCollector registerNowAs: #resetImagesFilesOnS3."
	self stopRemoteAwsMachines.
	"timestampsCollector registerNowAs: #stoppedRemoteAwsMachines."
	self startRemoteAwsMachines.
	"timestampsCollector registerNowAs: #startedRemoteAwsMachines"
]

{ #category : #phases }
GtDtsManager >> runJobExecution [
	"Actually run all the tests"

	jobExecutor run
]

{ #category : #phases }
GtDtsManager >> runJobShutdown [
	"Perform any actions associated with finishing the current job"

	jobStartupAndShutdown shutdown
]

{ #category : #phases }
GtDtsManager >> runJobStartup [
	"Perform any actions associated with starting a new job"

	jobStartupAndShutdown startup
]

{ #category : #phases }
GtDtsManager >> runManagerShutdown [
	"Perform any actions associated with stopping the DTS cluster"

	managerStartupAndShutdown shutdown
]

{ #category : #phases }
GtDtsManager >> runManagerStartup [
	"Perform any actions associated with starting the DTS cluster"

	managerStartupAndShutdown startup
]

{ #category : #accessing }
GtDtsManager >> server [

	^ server
]

{ #category : #accessing }
GtDtsManager >> server: anObject [

	server := anObject
]

{ #category : #'as yet unclassified' }
GtDtsManager >> startRemoteAwsMachines [
	remoteHostCluster
		runCommand: 'go.exe'
		arguments: #('run'
			'C:\Users\Administrator\git\lifeware-source\startstop.go'
			'-region'
			'us-east-1'
			'-action'
			'START'
			'-instancescount'
			'50')
		named: 'AWS: START WORKER MACHINES'
]

{ #category : #snapshot }
GtDtsManager >> stopRemoteAwsMachines [
	remoteHostCluster
		runCommand: 'go.exe'
		arguments: (Array
				with: 'run'
				with: 'C:\Users\Administrator\git\lifeware-source\startstop.go'
				with: '-region'
				with: 'us-east-1'
				with: '-action'
				with: 'STOP')
		named: 'AWS: STOP LEFTOVER WORKER MACHINES'
]
