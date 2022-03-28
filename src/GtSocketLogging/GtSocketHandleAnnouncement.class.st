Class {
	#name : #GtSocketHandleAnnouncement,
	#superclass : #BeaconSignal,
	#instVars : [
		'handle',
		'bufferSize',
		'message',
		'buffer'
	],
	#category : #GtSocketLogging
}

{ #category : #'instance creation' }
GtSocketHandleAnnouncement class >> handle: aHandle bufferSize: aNumber message: aString [

	^ self new
		handle: aHandle;
		bufferSize: aNumber;
		message: aString
]

{ #category : #'instance creation' }
GtSocketHandleAnnouncement class >> socket: aSocket bufferSize: aNumber message: aString [

	^ self new
		handle: aSocket socketHandle;
		bufferSize: aNumber;
		message: aString
]

{ #category : #'instance creation' }
GtSocketHandleAnnouncement class >> socketStream: aSocketStream [

	^ self new handle: aSocketStream socket socketHandle
]

{ #category : #'instance creation' }
GtSocketHandleAnnouncement class >> socketStream: aSocketStream buffer: aCollection message: aString [

	^ self new
		handle: aSocketStream socket socketHandle;
		buffer: aCollection;
		bufferSize: aCollection size;
		message: aString
]

{ #category : #'instance creation' }
GtSocketHandleAnnouncement class >> socketStream: aSocketStream bufferSize: aNumber message: aString [

	^ self new
		handle: aSocketStream socket socketHandle;
		bufferSize: aNumber;
		message: aString
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> buffer [

	^ buffer
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> buffer: aCollection [

	buffer := aCollection.
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> bufferSize [

	^ bufferSize
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> bufferSize: anObject [

	bufferSize := anObject
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> handle [

	^ handle
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> handle: anObject [

	handle := anObject
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> message [

	^ message
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> message: anObject [

	message := anObject
]

{ #category : #accessing }
GtSocketHandleAnnouncement >> prepareForDelivery [

	(bufferSize isInteger not or: [ buffer isCollection not ]) ifTrue: [ ^ self ].
	buffer := buffer copyFrom: 1 to: bufferSize.
]

{ #category : #printing }
GtSocketHandleAnnouncement >> printOneLineContentsOn: aStream [

	aStream
		print: handle;
		<< ': ';
		<< message asString;
		<< ' ';
		print: bufferSize.
]
