Class {
	#name : #PlpoGtRrJobContext,
	#superclass : #PlpoGtRrContext,
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
PlpoGtRrJobContext class >> remoteClassName [

	^ #GtRrJobContext
]

{ #category : #testing }
PlpoGtRrJobContext >> changesSync [

	^ self proxyPerform: #changesSync
]

{ #category : #accessing }
PlpoGtRrJobContext >> gtActionCancelFor: anAction [
	"Terminate the receiver's job.
	Note that this will kill the worker."
	<gtAction>

	self isStarted ifFalse: [ 
		^ anAction noAction ].
	^ anAction button
		  tooltip: 'Cancel';
		  icon: BrGlamorousVectorIcons cancel;
		  priority: 3;
		  action: [ :aButton | 
		  	self terminate.
			  aButton phlow fireToolUpdateWish ]
]

{ #category : #testing }
PlpoGtRrJobContext >> isStarted [

	^ self proxyPerform: #isStarted
]

{ #category : #accessing }
PlpoGtRrJobContext >> terminate [

	^ self proxyPerform: #terminate
]
