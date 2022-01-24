Class {
	#name : #GtRrExecutorFutureExecution,
	#superclass : #TKTFutureExecution,
	#traits : 'TGtRrExecutorExecution',
	#classTraits : 'TGtRrExecutorExecution classTrait',
	#category : #'RemoteRunner-Runner-Support'
}

{ #category : #accessing }
GtRrExecutorFutureExecution >> finishWithFailure: aGtRrError [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deployFailure: aGtRrError ]
]

{ #category : #accessing }
GtRrExecutorFutureExecution >> finishWithSuccess: anObject [

	self isFinished ifFalse: [ self setFinishedState ].
	future isFinished ifFalse: [ future deploySuccess: anObject ]
]

{ #category : #'gt-extension' }
GtRrExecutorFutureExecution >> gtLiveFor: aView [

	<gtView>
	^ aView explicit
		  title: 'Live';
		  priority: 9;
		  stencil: [ self asElement ]
]

{ #category : #initialization }
GtRrExecutorFutureExecution >> initialize [

	super initialize.
	state := GtRrExecutorReadyTaskState new
]
