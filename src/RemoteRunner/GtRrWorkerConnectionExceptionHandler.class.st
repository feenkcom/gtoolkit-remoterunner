Class {
	#name : #GtRrWorkerConnectionExceptionHandler,
	#superclass : #PharoLinkConnectionExceptionHandler,
	#category : 'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWorkerConnectionExceptionHandler >> handleExceptionsDuring: aBlock for: msgBroker [

	[ super handleExceptionsDuring: aBlock for: msgBroker ]
		on: ConnectionClosed
		do: [ :ex |
			"Announce that we're exiting"
			GtRrWorkerOperationShutdownAnnouncement new 
				reason: 'Connection Closed';
				emit.
			"Give other processes time to finish"
			Processor activeProcess priority: 15.
			Smalltalk snapshot: false andQuit: true ].
]
