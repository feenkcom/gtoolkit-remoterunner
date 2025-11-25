Extension { #name : #PharoLinkTestCaseExceptionAnnouncement }

{ #category : #'*RemoteRunner' }
PharoLinkTestCaseExceptionAnnouncement >> isErrorInCheckLogic [
	^ self isError and: [self isUnableToCompleteCheckError not ]
]

{ #category : #'*RemoteRunner' }
PharoLinkTestCaseExceptionAnnouncement >> isUnableToCompleteCheckError [
	^ self primaryException notNil and: [
		self primaryException isUnableToCompleteCheckError ]
]
