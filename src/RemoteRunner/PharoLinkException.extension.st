Extension { #name : #PharoLinkException }

{ #category : #'*RemoteRunner' }
PharoLinkException >> isUnableToCompleteTestError [
	^exceptionClassName sameContentAs:  #GtRrUnableToCompleteTestError
]
