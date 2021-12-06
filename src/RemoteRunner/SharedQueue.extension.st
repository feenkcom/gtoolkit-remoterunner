Extension { #name : #SharedQueue }

{ #category : #'*RemoteRunner' }
SharedQueue >> items: aCollection [
	"Set the receiver's items"

	monitor critical: 
		[ self assert: items isEmpty.
		items := aCollection asOrderedCollection ]
]
