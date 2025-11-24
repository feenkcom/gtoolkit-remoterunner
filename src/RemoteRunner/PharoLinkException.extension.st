Extension { #name : #PharoLinkException }

{ #category : #'*RemoteRunner' }
PharoLinkException >> isUnableToRunTestError [
	^exceptionClassName sameContentAs:  #GtRrUnableToRunTestError
]
