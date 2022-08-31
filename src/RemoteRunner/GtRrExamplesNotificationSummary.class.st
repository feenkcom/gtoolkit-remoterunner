Class {
	#name : #GtRrExamplesNotificationSummary,
	#superclass : #GtRrJobNotificationSummary,
	#category : #'RemoteRunner-UI'
}

{ #category : #updating }
GtRrExamplesNotificationSummary >> updateSummaryContent [
	| successfulCounter notStartedCounter failedCounter |
	
	successfulCounter := 0.
	notStartedCounter := 0.
	failedCounter := 0.
	
	self notifications
		do: [ :aNotification | 
			successfulCounter := successfulCounter + aNotification successfulChecksCount.
			notStartedCounter := notStartedCounter 
				+ aNotification totalChecksCount
				- aNotification executedChecksCount.
			failedCounter := failedCounter 
				+ aNotification failedChecksCount
				+ aNotification erroredChecksCount ].

	failedLabel text: failedCounter asString.
	successfulLabel text: successfulCounter asString.
	notStartedLabel text: notStartedCounter asString.
	
	failedLabel
		visibility: (failedCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
	successfulLabel
		visibility: (successfulCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
	notStartedLabel
		visibility: (notStartedCounter = 0 
			ifTrue: [ BlVisibility gone ] 
			ifFalse: [ BlVisibility visible ]).
]
