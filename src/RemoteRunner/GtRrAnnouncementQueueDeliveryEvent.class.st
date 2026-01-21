Class {
	#name : #GtRrAnnouncementQueueDeliveryEvent,
	#superclass : #GtRrAnnouncementQueueEvent,
	#category : 'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryEvent class >> compositeEventType [
	^ GtRrAnnouncementQueueUpdateCycleEvent
]

{ #category : #accessing }
GtRrAnnouncementQueueDeliveryEvent class >> eventLabel [
	^ 'Announcements Delivery'
]

{ #category : #testing }
GtRrAnnouncementQueueDeliveryEvent class >> needComposition [
	^ true
]
