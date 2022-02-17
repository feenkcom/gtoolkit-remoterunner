Class {
	#name : #GtRrTimeoutScheduledAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'context'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrTimeoutScheduledAnnouncement >> context [

	^ context
]

{ #category : #accessing }
GtRrTimeoutScheduledAnnouncement >> context: anObject [

	context := anObject
]

{ #category : #printing }
GtRrTimeoutScheduledAnnouncement >> printOneLineContentsOn: stream [

	context ifNil: [ ^ self ].
	stream print: context.

]
