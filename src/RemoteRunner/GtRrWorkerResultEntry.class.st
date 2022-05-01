"
GtRrWorkerResultEntry holds the result of a task, successful or not, to be sent back to the runner.
"
Class {
	#name : #GtRrWorkerResultEntry,
	#superclass : #Object,
	#instVars : [
		'task',
		'bindings',
		'command'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWorkerResultEntry class >> task: aTask bindings: aCollection command: aString [

	^ self new initializeTask: aTask bindings: aCollection command: aString
]

{ #category : #initialization }
GtRrWorkerResultEntry >> initializeTask: aTask bindings: aCollection command: aString [
	"bindings is a collection of Associations: variable name -> value"

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
	cf send: command.
	GtRrWorkerResponseSentAnnouncement new 
		task: task;
		result: self;
		emit.
]
