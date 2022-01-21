Class {
	#name : #GtRrWorkerFutureExecution,
	#superclass : #TKTFutureExecution,
	#traits : 'TGtRrWorkerExecution',
	#classTraits : 'TGtRrWorkerExecution classTrait',
	#category : #'RemoteRunner-Runner'
}

{ #category : #'as yet unclassified' }
GtRrWorkerFutureExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deployFailure: aGtRrError ]
]

{ #category : #'as yet unclassified' }
GtRrWorkerFutureExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deploySuccess: anObject ]
]

{ #category : #accessing }
GtRrWorkerFutureExecution >> runner [

	^ runner
]

{ #category : #'as yet unclassified' }
GtRrWorkerFutureExecution >> terminateWithReason: aReason [

	self setExplicitlyTerminatedStateWithReason: aReason.
	runner deployFailure: aReason
]
