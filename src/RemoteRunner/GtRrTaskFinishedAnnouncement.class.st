Class {
	#name : #GtRrTaskFinishedAnnouncement,
	#superclass : #GtRrTaskAnnouncement,
	#instVars : [
		'retryTaskInfo'
	],
	#category : 'RemoteRunner-Announcements'
}

{ #category : #'instance creation' }
GtRrTaskFinishedAnnouncement class >> fromStonDictionary: aDictionary [

	^ (super fromStonDictionary: aDictionary)
		task: (aDictionary at: #retryTaskInfo);
		yourself

]

{ #category : #'as yet unclassified' }
GtRrTaskFinishedAnnouncement >> asDataForRemoteSerialize [
	^ super asDataForRemoteSerialize
		at: #retryTaskInfo put: retryTaskInfo;
		yourself.
]

{ #category : #'as yet unclassified' }
GtRrTaskFinishedAnnouncement >> asDictionary [

	^ super asDictionary
		at: #retryTaskInfo put: retryTaskInfo;
		yourself.
]

{ #category : #'as yet unclassified' }
GtRrTaskFinishedAnnouncement >> initializeFromSlotData: aDictionary [
	super initializeFromSlotData: aDictionary.

	self properties at: #retryTaskInfo put: (aDictionary at: #retryTaskInfo).
]

{ #category : #printing }
GtRrTaskFinishedAnnouncement >> printOneLineContentsOn: stream [

	super printOneLineContentsOn: stream.
	retryTaskInfo ifNil: [ ^ self ].
	stream 
		<< '| ';
		print: retryTaskInfo.
]

{ #category : #accessing }
GtRrTaskFinishedAnnouncement >> retryTaskInfo [
	^ retryTaskInfo
		ifNil: [ self properties at: #retryTaskInfo ]
]

{ #category : #accessing }
GtRrTaskFinishedAnnouncement >> retryTaskInfo: anObject [
	retryTaskInfo := anObject
]
