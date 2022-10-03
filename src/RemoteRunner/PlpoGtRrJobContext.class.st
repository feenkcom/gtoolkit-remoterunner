Class {
	#name : #PlpoGtRrJobContext,
	#superclass : #PlpoGtRrContext,
	#category : #'RemoteRunner-Runner-State'
}

{ #category : #accessing }
PlpoGtRrJobContext >> gtActionCancelFor: anAction [
	<gtAction>

	self isStarted ifFalse: [ 
		^ anAction noAction ].
	^ anAction button
		  tooltip: 'Cancel';
		  icon: BrGlamorousVectorIcons cancel;
		  priority: 3;
		  action: [ :aButton | 
		  	self terminate.
			  aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
PlpoGtRrJobContext >> isStarted [

	^ self proxyPerform: #isStarted
]

{ #category : #accessing }
PlpoGtRrJobContext >> remoteClassName [

	^ #GtRrJobContext
]

{ #category : #accessing }
PlpoGtRrJobContext >> terminate [

	^ self proxyPerform: #terminate
]
