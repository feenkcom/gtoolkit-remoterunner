Extension { #name : #Symbol }

{ #category : #'*RemoteRunner' }
Symbol >> gtRrEquals: aString [

	^ GtRrEqualsConstraint attribute: self value: aString
]
