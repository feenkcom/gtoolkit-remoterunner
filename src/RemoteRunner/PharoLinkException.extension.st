Extension { #name : #PharoLinkException }

{ #category : #'*RemoteRunner' }
PharoLinkException >> isUnableToCompleteCheckError [
	^exceptionClassName sameContentAs:  #GtRrUnableToCompleteTestError
]
