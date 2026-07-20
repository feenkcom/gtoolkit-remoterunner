Extension { #name : #EpMethodAddition }

{ #category : #'*RemoteRunner' }
EpMethodAddition >> gtRrApproximateSize [
	"Answer the approximate size of the receiver in memory."
	
	^ self methodAffected gtRrApproximateSize
]
