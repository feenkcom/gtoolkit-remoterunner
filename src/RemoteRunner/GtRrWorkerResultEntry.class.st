"
GtRrWorkerResultEntry holds the result of a task, successful or not, to be sent back to the runner.
"
Class {
	#name : #GtRrWorkerResultEntry,
	#superclass : #Object,
	#instVars : [
		'task',
		'bindings',
		'command',
		'worker',
		'checkProcess',
		'promise'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWorkerResultEntry class >> worker: aGtRrWorker task: aTask bindings: aCollection command: aString [

	^ self new initializeWorker: aGtRrWorker task: aTask bindings: aCollection command: aString
]

{ #category : #accessing }
GtRrWorkerResultEntry >> checkPromise [
	"Check that the result was processed successfully.
	If not, notify the remote runner.
	If that fails signal the error."
	| errorDetails |

	promise wait.
	promise exception ifNil: [ ^ self ].

	worker connectDuring: [ :application |
		errorDetails := GtRrErrorDetails new
			errorMessage: 'RemoteRunner result processing error: ', promise exception errorMessage asString;
			trace: promise exception trace.
		application newCommandFactory
			bindingAt: #errorDetails put: (LeJsonV4 uniqueInstance serialize: errorDetails);
			bindingAt: #workerId put: worker uid;
			bindingAt: #taskContextId put: task taskContextId;
			<< 'GtAssignedRemoteRunner 
				workerResultProcessingError: (LeJsonV4 uniqueInstance deserialize: errorDetails readStream)
				workerId: workerId
				taskContextId: taskContextId';
			sendAndWait ].
]

{ #category : #initialization }
GtRrWorkerResultEntry >> initializeWorker: aGtRrWorker task: aTask bindings: aCollection command: aString [
	"bindings is a collection of Associations: variable name -> value"

	worker := aGtRrWorker.
	task := aTask.
	bindings := aCollection.
	command := aString.
]

{ #category : #'api - sending' }
GtRrWorkerResultEntry >> sendThroughApplication: aPharoLinkApplication [
	"Send the receiver's command through the supplied application, don't wait for the result"
	| cf |

	cf := aPharoLinkApplication newCommandFactory.
	bindings do: [ :assoc |
		cf bindingAt: assoc key put: assoc value ].
	promise := cf send: command.
	checkProcess := [ self checkPromise ] forkAt: Processor userBackgroundPriority.
	
	GtRrWorkerResponseSentSignal new 
		task: task;
		result: self;
		emit.
]

{ #category : #accessing }
GtRrWorkerResultEntry >> worker [

	^ worker
]

{ #category : #accessing }
GtRrWorkerResultEntry >> worker: anObject [

	worker := anObject
]
