Extension { #name : #BeaconSignal }

{ #category : #'*RemoteRunner' }
BeaconSignal >> gtRrDescription [
	"Answer a string describing what the receiver represents.
	Subclasses should override with something useful."
	
	^ self class name asString
]
