Trait {
	#name : #TGtRrExampleHelp,
	#category : 'RemoteRunner-Examples'
}

{ #category : #semaphores }
TGtRrExampleHelp >> waitOn: aSemaphore for: anInteger description: descriptionString [

	(aSemaphore waitTimeoutSeconds: anInteger)
		ifTrue: [ self error: descriptionString ]
]
