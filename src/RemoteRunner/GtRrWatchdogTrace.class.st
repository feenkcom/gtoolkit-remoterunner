Class {
	#name : #GtRrWatchdogTrace,
	#superclass : #GtRrTrace,
	#instVars : [
		'failedProcess',
		'newProcess'
	],
	#category : #'RemoteRunner-Beacon'
}

{ #category : #accessing }
GtRrWatchdogTrace >> failedProcess [

	^ failedProcess
]

{ #category : #accessing }
GtRrWatchdogTrace >> failedProcess: anObject [

	failedProcess := anObject
]

{ #category : #accessing }
GtRrWatchdogTrace >> newProcess [

	^ newProcess
]

{ #category : #accessing }
GtRrWatchdogTrace >> newProcess: anObject [

	newProcess := anObject
]
