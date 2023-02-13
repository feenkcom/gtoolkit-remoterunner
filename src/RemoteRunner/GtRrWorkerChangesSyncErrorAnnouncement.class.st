Class {
	#name : #GtRrWorkerChangesSyncErrorAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'exception',
		'ipAddress'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #ipAddress put: ipAddress;
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
	ipAddress := (aDictionary at: #ipAddress).
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> ipAddress [
	^ ipAddress
]

{ #category : #accessing }
GtRrWorkerChangesSyncErrorAnnouncement >> ipAddress: anObject [
	ipAddress := anObject
]

{ #category : #printing }
GtRrWorkerChangesSyncErrorAnnouncement >> printOn: stream [

	stream
		print: exception;
		<< ' @ ';
		<< ipAddress asString.
]

{ #category : #printing }
GtRrWorkerChangesSyncErrorAnnouncement >> printOneLineContentsOn: stream [

	stream
		print: exception;
		<< ' @ ';
		print: ipAddress.
]
