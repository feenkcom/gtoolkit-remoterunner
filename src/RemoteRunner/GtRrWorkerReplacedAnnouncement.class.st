Class {
	#name : #GtRrWorkerReplacedAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'oldProcess',
		'newProcess'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerReplacedAnnouncement >> initializeFromTimestamp: aTimestamp andData: dataParts [

	super initializeFromTimestamp: aTimestamp andData: dataParts.
	oldProcess := dataParts at: 7.
	newProcess := dataParts at: 8.
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> newProcess [

	^ newProcess
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> newProcess: anObject [

	newProcess := anObject
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> oldProcess [

	^ oldProcess
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> oldProcess: anObject [

	oldProcess := anObject
]

{ #category : #printing }
GtRrWorkerReplacedAnnouncement >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	stream
		<< ' | ';
		<< oldProcess asString;
		<< ' | ';
		<< newProcess asString
]
