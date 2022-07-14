Class {
	#name : #GtRrExamplesNotificationSummary,
	#superclass : #GtRrJobNotificationSummary,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesNotificationSummary >> updateSummaryContent [
	| successfulCounter notStartedCounter failedCounter |
	
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	
	self notifications
		do: [ :aNotification | 
			| currentJob |
			currentJob := aNotification job.
			successfulCounter := successfulCounter + currentJob successfulExamplesCount.
			notStartedCounter := notStartedCounter 
				+ currentJob totalExamplesCount
				- currentJob executedExamplesCount.
			failedCounter := failedCounter 
				+ currentJob failedExamplesCount
				+ currentJob erroredExamplesCount ].
				
	failed text: failedCounter asString.
	successful text: successfulCounter asString.
	notStarted text: notStartedCounter asString.
	
	failed
		visibility: (failedCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
	successful
		visibility: (successfulCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
	notStarted
		visibility: (notStartedCounter = 0 ifTrue: [ BlVisibility gone ] ifFalse: [ BlVisibility visible ]).
]
