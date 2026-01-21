Class {
	#name : #GtRrWorkerChangesSyncErrorAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'exception',
		'workerId'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #workerId put: workerId;
		at: #exception put: (GtRrErrorDetails fromException: exception);
		yourself.
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> exception [
	^ exception
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> exception: anObject [
	exception := anObject
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.

	exception := (aDictionary at: #exception).
	workerId := (aDictionary at: #workerId).
]

{ #category : #printing }
GtRrWorkerChangesSyncErrorAnnouncement >> printOn: stream [

	stream
		print: exception;
		<< ' @ ';
		<< workerId asString.
]

{ #category : #printing }
GtRrWorkerChangesSyncErrorAnnouncement >> printOneLineContentsOn: stream [

	stream
		print: exception;
		<< ' @ ';
		print: workerId.
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> workerId [
	^ workerId
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> workerId: anObject [
	workerId := anObject
]
