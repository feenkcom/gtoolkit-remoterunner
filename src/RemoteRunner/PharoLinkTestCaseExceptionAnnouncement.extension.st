Extension { #name : #PharoLinkTestCaseExceptionAnnouncement }

{ #category : #'*RemoteRunner' }
PharoLinkTestCaseExceptionAnnouncement >> isUnableToRunTestError [
	^ self primaryException notNil and: [
		self primaryException isUnableToRunTestError ]
]
