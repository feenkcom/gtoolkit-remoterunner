"
nil
"
Class {
	#name : #GtRrSyslogSignal,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'ipAddress',
		'messageText'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrSyslogSignal >> ipAddress [

	^ ipAddress
]

{ #category : #accessing }
GtRrSyslogSignal >> ipAddress: anObject [

	ipAddress := anObject
]

{ #category : #accessing }
GtRrSyslogSignal >> messageText [

	^ messageText
]

{ #category : #accessing }
GtRrSyslogSignal >> messageText: anObject [

	messageText := anObject
]

{ #category : #accessing }
GtRrSyslogSignal >> printOneLineContentsOn: stream [

	messageText ifNil: [ ^ self ].
	stream << messageText
]
