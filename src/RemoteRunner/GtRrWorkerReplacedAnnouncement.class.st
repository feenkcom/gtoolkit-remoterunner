Class {
	#name : #GtRrWorkerReplacedAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'oldProcess',
		'newProcess'
	],
	#category : #'RemoteRunner-Announcements'
}

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

	stream
		<< 'old: ';
		print: oldProcess;
		<< ', new: ';
		print: newProcess
]
