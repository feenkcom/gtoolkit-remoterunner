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
	^ GtRrChecksJobNotificationSummary
]

{ #category : #accessing }
GtRrExamplesProgressNotification >> updateSummaryWithTaskResult: aTaskResult [
	super updateSummaryWithTaskResult: aTaskResult.
	
	self incrementSuccessfulChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isSuccess ]).
	self incrementSkippedChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isSkipped ]).
	self incrementFailedChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isFailure ]).
	self incrementErrorChecksCountWith: (aTaskResult count: [ :aResult | 
		aResult isError or: [ aResult isWarning ] ]).
	
	self notifyNotificationDataChanged.
]
