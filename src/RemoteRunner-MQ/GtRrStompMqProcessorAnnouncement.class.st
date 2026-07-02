Class {
	#name : #GtRrStompMqProcessorAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'mqProcessor'
	],
	#category : #'RemoteRunner-MQ-Runner'
}

{ #category : #accessing }
GtRrStompMqProcessorAnnouncement >> mqProcessor [
	^ mqProcessor
]

{ #category : #accessing }
GtRrStompMqProcessorAnnouncement >> mqProcessor: anObject [
	mqProcessor := anObject
]
