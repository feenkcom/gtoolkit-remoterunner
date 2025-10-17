Extension { #name : #EpMethodRemoval }

{ #category : #'*RemoteRunner' }
EpMethodRemoval >> gtRrApproximateSize [
	"Answer the approximate size of the receiver in memory."
	
	^ self methodAffected sourceCode sizeInMemory
]
