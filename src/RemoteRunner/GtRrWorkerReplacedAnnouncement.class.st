Class {
	#name : #GtRrWorkerReplacedAnnouncement,
	#superclass : #GtRrWorkerAnnouncement,
	#instVars : [
		'newWorker'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #ui }
GtRrWorkerReplacedAnnouncement >> gtStderrFor: aView [
	<gtView>

	worker ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'stderr';
		priority: 10;
		object: [ worker ];
		view: #gtStderrFor:
	
]

{ #category : #ui }
GtRrWorkerReplacedAnnouncement >> gtStdoutFor: aView [
	<gtView>

	worker ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'stdout';
		priority: 10;
		object: [ worker ];
		view: #gtStdoutFor:
	
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> newWorker [

	^ newWorker
]

{ #category : #accessing }
GtRrWorkerReplacedAnnouncement >> newWorker: anObject [

	newWorker := anObject
]
