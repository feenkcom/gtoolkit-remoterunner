Class {
	#name : #GtRrTimeoutAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'context'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrTimeoutAnnouncement class >> context: aGtRrContext [

	^ self new context: aGtRrContext 
]

{ #category : #accessing }
GtRrTimeoutAnnouncement >> context [

	^ context
]

{ #category : #accessing }
GtRrTimeoutAnnouncement >> context: anObject [

	context := anObject
]

{ #category : #printing }
GtRrTimeoutAnnouncement >> printOneLineContentsOn: stream [

	context ifNil: [ ^ self ].
	stream print: context.

]
