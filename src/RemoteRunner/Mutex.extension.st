Extension { #name : #Mutex }

{ #category : #'*RemoteRunner' }
Mutex >> assertIsOwner [
	"Assert that the calling process is the owner of the receiver."

	self
		assert: owner == Processor activeProcess
		description: 'Active process is not the Mutex owner'.
]

{ #category : #'*RemoteRunner' }
Mutex >> size [

	^ semaphore size
]
