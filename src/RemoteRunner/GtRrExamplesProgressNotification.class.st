Class {
	#name : #GtRrExamplesProgressNotification,
	#superclass : #GtRrChecksJobProgressNotification,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>

	^ GtRrExamplesNotificationElement
]

{ #category : #accessing }
GtRrExamplesProgressNotification >> summaryClass [
	"Return a class that when instantiated displays the notification summary to the user"
	^ GtRrExamplesNotificationSummary
]
