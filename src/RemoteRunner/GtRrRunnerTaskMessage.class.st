Class {
	#name : #GtRrRunnerTaskMessage,
	#superclass : #GtRrRunnerMessage,
	#instVars : [
		'task'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #'as yet unclassified' }
GtRrRunnerTaskMessage >> processMq: mqMessage processor: aGtRrProcessor for: anOwner [

	(mqMessage headerAt: #redelivered ifAbsent: [ false ]) = 'true'
		ifTrue: [ anOwner rejectRedeliveredTask: task ackFrame: mqMessage ackFrame ]
		ifFalse: [ anOwner setNextTask: task ackFrame: mqMessage ackFrame ].
]

{ #category : #accessing }
GtRrRunnerTaskMessage >> task [
	^ task
]

{ #category : #accessing }
GtRrRunnerTaskMessage >> task: anObject [
	task := anObject
]
