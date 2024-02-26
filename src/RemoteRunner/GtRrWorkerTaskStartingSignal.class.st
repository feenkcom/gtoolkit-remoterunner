Class {
	#name : #GtRrWorkerTaskStartingSignal,
	#superclass : #GtRrWorkerTaskSignal,
	#category : #'RemoteRunner-Signals'
}

{ #category : #printing }
GtRrWorkerTaskStartingSignal >> printOneLineContentsOn: stream [

	task ifNil: [ ^ self ].
	stream print: task taskId
]
