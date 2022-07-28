Class {
	#name : #GtRrChecksJobProgressNotification,
	#superclass : #GtRrJobProgressNotification,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrChecksJobProgressNotification >> constructStates [
	
	^ {
		(GtRrDataGroupState forNotification: self)
			name: 'All';
			color: Color transparent;
			items: self job allExamples.
		(GtRrDataGroupState forNotification: self)
			name: 'Success';
			color: Color lightGreen;
			items: self job successfulExamples.
		(GtRrDataGroupState forNotification: self)
			name: 'Skipped';
			color: Color veryVeryLightGray;
			items: self job skippedExamples.
		(GtRrDataGroupState forNotification: self)
			name: 'Failure';
			color: Color lightOrange;
			items: self job failedExamples.
		(GtRrDataGroupState forNotification: self)
			name: 'Error';
			color: Color red;
			items: self job erroredExamples.
		(GtRrDataGroupState forNotification: self)
			name: 'Not executed';
			color: Color veryVeryLightGray;
			items: self job notExecutedExamples} 
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> notificationLabel [
	^ 'Run Examples (', self job  state, ')'
]

{ #category : #accessing }
GtRrChecksJobProgressNotification >> runJobAgain [
	"Create a copy of the receiver's job and run it with progress notifications"
	| jobCopy |

	jobCopy := self job copy.
	jobCopy showExamplesProgressNotification.
	
	GtRemoteRunner default submitJob: jobCopy.
]
