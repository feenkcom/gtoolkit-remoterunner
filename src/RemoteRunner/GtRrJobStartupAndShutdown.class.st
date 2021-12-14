Class {
	#name : #GtRrJobStartupAndShutdown,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrJobStartupAndShutdown >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrJobStartupAndShutdown >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #'api - shutdown' }
GtRrJobStartupAndShutdown >> shutdownJob: aJobContext [
	| job |

	remoteRunner removeCurrentlyExecutingJob: aJobContext id.
	job := aJobContext job.
	job markJobCompleted.

]

{ #category : #'api - startup' }
GtRrJobStartupAndShutdown >> startupJob: aGtRrJobContext [
	"Perform actions to start the supplied job context.
	- Use the scheduler to group all the tests in to tasks"

	aGtRrJobContext 
		getTasks;
		createPlatformContexts;
		markJobStarted.
]
