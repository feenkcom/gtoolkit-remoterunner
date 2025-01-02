Class {
	#name : #GtRrJobStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #serialisation }
GtRrJobStartupAndShutdown >> asStatsDictionary [

	^ Dictionary new
		at: #name put: self class name;
		yourself
]

{ #category : #testing }
GtRrJobStartupAndShutdown >> finishedWithWorkerFuture: taskFuture [
	"Answer a boolean indicating whether the supplied worker is no longer required.
	By default, workers are kept indefinitely.
	Must be called within sharedAccess."

	^ false
]

{ #category : #accessing }
GtRrJobStartupAndShutdown >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrJobStartupAndShutdown >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #testing }
GtRrJobStartupAndShutdown >> shouldTerminateJobsOnNoWorkers [
	"Answer a boolean indicating whether jobs should be terminated if the last worker unregisters."
	
	^ false
]

{ #category : #'api - shutdown' }
GtRrJobStartupAndShutdown >> shutdown [ 
	"Perform any actions associated with stopping the DTS cluster:
	Subclasses can perform additional actions"

]

{ #category : #'api - shutdown' }
GtRrJobStartupAndShutdown >> shutdownJob: aJobContext [
	| job |

	remoteRunner announceStatusMessageWithString: 'Performing job shutdown - Remove currently executing job'.
	remoteRunner removeCurrentlyExecutingJob: aJobContext jobId.
	job := aJobContext job.
	job markJobCompleted.
	remoteRunner announceAndLog: (GtRrJobCompletedAnnouncement job: job).
	
]

{ #category : #'api - startup' }
GtRrJobStartupAndShutdown >> startup [ 
	"Perform any actions associated with starting the RemoteRunner:
	Subclasses can perform additional actions"
]

{ #category : #'api - startup' }
GtRrJobStartupAndShutdown >> startupJob: aGtRrJobContext [
	"Perform actions to start the supplied job context.
	- Use the scheduler to group all the tests in to tasks.
	Must be called within sharedAccess."

	remoteRunner logEmitter emitJobStartupStartFor: aGtRrJobContext.
	aGtRrJobContext 
		markJobStarted;
		submitTasks.
	remoteRunner timeoutManager addContext: aGtRrJobContext.
	remoteRunner logEmitter emitJobStartupEndFor: aGtRrJobContext.
]
