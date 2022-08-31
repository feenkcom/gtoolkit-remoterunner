Class {
	#name : #GtRrExamplesProgressNotification,
	#superclass : #GtRrChecksJobProgressNotification,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>
	
	^ GtRrJobNotificationElement 
]

{ #category : #accessing }
GtRrExamplesProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrExamplesNotificationSummary
]

{ #category : #accessing }
GtRrExamplesProgressNotification >> updateSummaryWithTaskResult: aTaskResult [
	super updateSummaryWithTaskResult: aTaskResult.
	
	self incrementSuccessfulChecksCountWith: aTaskResult successfulExamplesCount.
	self incrementSkippedChecksCountWith: aTaskResult skippedExamplesCount.
	self incrementFailedChecksCountWith: aTaskResult failedExamplesCount.
	self incrementErrorChecksCountWith: aTaskResult erroredExamplesCount.
	
	self notifyNotificationDataChanged.
]
