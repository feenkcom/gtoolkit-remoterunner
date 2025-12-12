Extension { #name : #EpMethodModification }

{ #category : #'*RemoteRunner' }
EpMethodModification >> asGtRrCompactChange [
	"Answer the receiver with any information that isn't required by a worker discarded.
	Method modifications are converted to a method addition, which is treated in the same way during replay, but doesn't carry the old method definition with it."

	^ EpMethodAddition method: newMethod
]

{ #category : #'*RemoteRunner' }
EpMethodModification >> gtRrApproximateSize [
	"Answer the approximate size of the receiver in memory."
	
	^ self methodAffected gtRrApproximateSize + self oldMethod gtRrApproximateSize
]
