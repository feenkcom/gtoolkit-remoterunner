Class {
	#name : #GtRrWorkerTaskExecution,
	#superclass : #TKTTaskExecution,
	#traits : 'TGtRrWorkerExecution',
	#classTraits : 'TGtRrWorkerExecution classTrait',
	#instVars : [
		'timeout'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrWorkerTaskExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ]
]

{ #category : #accessing }
GtRrWorkerTaskExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ]
]

{ #category : #accessing }
GtRrWorkerTaskExecution >> runner [

	^ runner
]

{ #category : #accessing }
GtRrWorkerTaskExecution >> timeout [

	^ timeout
]

{ #category : #accessing }
GtRrWorkerTaskExecution >> timeout: anObject [

	timeout := anObject
]
