Class {
	#name : #GtRemoteRunnerAnnouncement,
	#superclass : #BeaconSignal,
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRemoteRunnerAnnouncement class >> fromSerializedData: anAnnouncementData [
	| announcementClass |
	announcementClass := (anAnnouncementData at: 'className') asClass.
	^ announcementClass new 
		initializeFromSlotData: (anAnnouncementData at: 'data')
]

{ #category : #serialization }
GtRemoteRunnerAnnouncement >> asDataForRemoteSerialize [
	^Dictionary new
		at: #timestamp put: timestamp;
		at: #processId put: processId;
		at: #properties put: properties;
		yourself.
]

{ #category : #serialization }
GtRemoteRunnerAnnouncement >> initializeFromSlotData: aDictionary [ 
	self 
		basicTimestamp: (aDictionary at: #timestamp);
		basicProcessId: (aDictionary at: #processId);
		basicProperties: (aDictionary at: #properties)
]

{ #category : #'as yet unclassified' }
GtRemoteRunnerAnnouncement >> printOneLineContentsOn: aStream [

	aStream
		<< '| ';
		<< self signalTypeLabel;
		<< ' | ';
		<< processId asString
]

{ #category : #serialization }
GtRemoteRunnerAnnouncement >> serializeForRemoteDelivery [
	^ {
		'className' -> self className.
		'data' -> self asDataForRemoteSerialize
	} asDictionary
]

{ #category : #accessing }
GtRemoteRunnerAnnouncement >> signalTypeLabel [

	^ 'GtRemoteRunnerAnnouncement'
]
