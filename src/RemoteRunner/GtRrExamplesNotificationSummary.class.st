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

	self updateLabel: failedLabel withCount: failedCounter.
	self updateLabel: successfulLabel withCount: successfulCounter.
	self updateLabel: notStartedLabel withCount: notStartedCounter.
]
