Class {
	#name : #GtRrExamplesProgressNotification,
	#superclass : #GtRrJobProgressNotification,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesProgressNotification >> elementClass [
	"Return a class that when instantiated displayes the notification to user (as a widget)"
	<return: #GtNotificationEventElement>

	^ GtRrExamplesNotificationElement
]