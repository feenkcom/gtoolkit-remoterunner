Class {
	#name : #GtRrEnvironment,
	#superclass : #Object,
	#instVars : [
		'remoteRunner'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrEnvironment >> scheduler [

	^ remoteRunner
]

{ #category : #accessing }
GtRrEnvironment >> scheduler: anObject [

	remoteRunner := anObject
]

{ #category : #'startup - shutdown' }
GtRrEnvironment >> start [

	
]

{ #category : #'startup - shutdown' }
GtRrEnvironment >> stop [

	
]
