Class {
	#name : #GtRrExecutorFutureExecution,
	#superclass : #TKTFutureExecution,
	#traits : 'TGtRrWorkerExecution',
	#classTraits : 'TGtRrWorkerExecution classTrait',
	#category : #'RemoteRunner-Runner'
}

{ #category : #converting }
GtRrExecutorFutureExecution >> asElement [

	^ state gtRrAsElement
]

{ #category : #'as yet unclassified' }
GtRrExecutorFutureExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deployFailure: aGtRrError ]
]

{ #category : #'as yet unclassified' }
GtRrExecutorFutureExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deploySuccess: anObject ]
]

{ #category : #initialization }
GtRrExecutorFutureExecution >> initialize [

	super initialize.
	state := GtRrExecutorReadyTaskState new
]

{ #category : #accessing }
GtRrExecutorFutureExecution >> runner [

	^ runner
]
