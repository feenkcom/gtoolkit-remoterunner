Extension { #name : #PharoLinkTestCaseExceptionAnnouncement }

{ #category : #'*RemoteRunner' }
PharoLinkTestCaseExceptionAnnouncement >> isErrorInCheckLogic [
	^ self isError and: [self isUnableToCompleteTestError not ]
]

{ #category : #'*RemoteRunner' }
PharoLinkTestCaseExceptionAnnouncement >> isUnableToCompleteTestError [
	^ self primaryException notNil and: [
		self primaryException isUnableToCompleteTestError ]
]
