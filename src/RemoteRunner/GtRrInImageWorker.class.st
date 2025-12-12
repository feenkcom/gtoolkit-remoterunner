"
GtRrInImageWorker is a simple worker that runs in the same image as the RemoteRunner server.

"
Class {
	#name : #GtRrInImageWorker,
	#superclass : #GtRrWorker,
	#instVars : [
		'remoteRunner',
		'connection'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrInImageWorker >> connection [
	<return: #PharoLinkServerConnection>

	^ connection
]

{ #category : #accessing }
GtRrInImageWorker >> connection: aPharoLinkServerConnection [

	connection := aPharoLinkServerConnection
]

{ #category : #initialization }
GtRrInImageWorker >> initialize [

	super initialize.
	attributes
		at: #workerPriority put: 10;
		at: #workerInImage put: true.
	connection := GtRrPseudoPharoLinkServerConnection new
		worker: self.
	self connectionStrategy: GtRrWorkerInImageConnectionStrategy new.
]

{ #category : #private }
GtRrInImageWorker >> nextTask [
	"Send any queued results and get the next task"
	| nextTask |

	"Normally the task has been serialised and deserialised,
	so is a different instance.  Manually ensure that for the in-image worker."
	nextTask := (remoteRunner nextTaskForWorkerId: uid) copy.
	lastHeartbeat := DateAndTime now.
	^ nextTask
]

{ #category : #running }
GtRrInImageWorker >> registerWith: ignored [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

	PharoLinkServerCurrentConnection 
		value: connection
		during: [ remoteRunner registerWorkerWithDetails: attributes controlChannelAvailable: false ].

]

{ #category : #accessing }
GtRrInImageWorker >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrInImageWorker >> remoteRunner: anObject [

	remoteRunner := anObject
]

{ #category : #private }
GtRrInImageWorker >> sendHeartbeat [

	lastHeartbeat := DateAndTime now.
	remoteRunner heartbeatForWorkerId: uid.
]

{ #category : #running }
GtRrInImageWorker >> taskDone: aTaskContext with: anObject [
	| executionData |

	executionData := GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		additionalData: aTaskContext executionData additionalData.
	remoteRunner
		taskDone: aTaskContext taskContextId
		workerId: self uid
		jobId: aTaskContext jobId
		taskId: aTaskContext taskId
		executionData: executionData
		result: anObject.
]

{ #category : #running }
GtRrInImageWorker >> taskFailed: aTaskContext with: anError [
	| executionData |

	executionData := GtRrWorkerExecutionData new
		startTime: aTaskContext startTime;
		endTime: aTaskContext endTime;
		resourceReport: aTaskContext executionData resourceReport;
		errorDetails: (GtRrErrorDetails new
						errorMessage: (anError messageText ifEmpty:
							[ anError printString ]);
						trace: anError stackString);
		additionalData: aTaskContext executionData additionalData.
	remoteRunner
		taskFailed: aTaskContext taskContextId
		workerId: self uid
		jobId: aTaskContext jobId
		taskId: aTaskContext taskId
		executionData: executionData.
]

{ #category : #private }
GtRrInImageWorker >> unregisterWith: ignored [
	"Register the receiver with the remote runner associated with the supplied PharoLinkApplication"

]
