Class {
	#name : #GtRrWorkerConnectionExceptionHandler,
	#superclass : #PharoLinkConnectionExceptionHandler,
	#instVars : [
		'worker'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorkerConnectionExceptionHandler >> handleExceptionsDuring: aBlock for: msgBroker [

	aBlock
		"Sockets signal SocketError instead of PrimitiveFailed in Pharo 11, 
		MessagePack doesn't catch the socket closing, which means that nil can be returned, instead of a character, triggering a MNU.
		NetworkError is a superclass of ConnectionClosed."
		on: (ExceptionSet withClassNames: #(#PrimitiveFailed #SocketError #NetworkError #MessageNotUnderstood))
		do: [ :ex |
			"Announce that we're exiting"
			GtRrWorkerOperationShutdownAnnouncement new 
				reason: 'Connection Closed';
				emit.
			[ worker stopAndQuit: 'Connection Closed' ] fork ].
]

{ #category : #accessing }
GtRrWorkerConnectionExceptionHandler >> worker [
	^ worker
]

{ #category : #accessing }
GtRrWorkerConnectionExceptionHandler >> worker: anObject [
	worker := anObject
]
