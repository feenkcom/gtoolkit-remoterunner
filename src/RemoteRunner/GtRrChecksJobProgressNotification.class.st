Class {
	#name : #GtRrChecksJobProgressNotification,
	#superclass : #GtRrJobProgressNotification,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrChecksJobProgressNotification >> constructStates [
	
	^ {
		GtRrDataGroupState new
			name: 'All';
			color: Color transparent;
			items: self job allExamples.
		GtRrDataGroupState new
			name: 'Success';
			color: Color lightGreen;
			items: self job successfulExamples.
		GtRrDataGroupState new
			name: 'Skipped';
			color: Color veryVeryLightGray;
			items: self job skippedExamples.
		GtRrDataGroupState new
			name: 'Failure';
			color: Color lightOrange;
			items: self job failedExamples.
		GtRrDataGroupState new
			name: 'Error';
			color: Color red;
			items: self job erroredExamples.
		GtRrDataGroupState new
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
