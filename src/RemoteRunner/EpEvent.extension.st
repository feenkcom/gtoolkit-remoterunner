Extension { #name : #EpEvent }

{ #category : #'*RemoteRunner' }
EpEvent >> asGtRrCompactChange [
	"Answer the receiver with any information that isn't required by a worker discarded.
	The default is to keep the current event."

	^ self
]

{ #category : #'*RemoteRunner' }
EpEvent >> gtRrApproximateSize [
	"Answer the approximate size of the receiver in memory."
	
	^ 0
]
