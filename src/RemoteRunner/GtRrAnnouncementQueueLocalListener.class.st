Class {
	#name : #GtRrAnnouncementQueueLocalListener,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'announcementQueue',
		'processLabel',
		'terminationCondition',
		'timeout'
	],
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #'instance - creation' }
GtRrAnnouncementQueueLocalListener class >> forAnnouncingProxy: aProxy [
	^ self new 
		initializeForAnnouncingProxy: aProxy 
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> announcer [ 
	^ announcer
]

{ #category : #initialization }
GtRrAnnouncementQueueLocalListener >> initializeForAnnouncingProxy: aProxy [ 
	announcementQueue := aProxy announcementQueue.
	announcer := Announcer new.
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> pollAndDeliverAnnouncements [
	| newAnnouncements |
	newAnnouncements := self pollAnnouncementQueue.
	
	GtRrAnnouncementQueueDeliveryInitiatedAnnouncement new 
		announcementsCount: newAnnouncements size;
		emit.
	
	newAnnouncements do: [ :anAnnouncement | 
		self announcer announce: anAnnouncement ].
		
	GtRrAnnouncementQueueDeliveryCompletedAnnouncement new 
		announcementsCount: newAnnouncements size;
		emit.
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> pollAnnouncementQueue [
	| pulledAnnouncements |
	GtRrAnnouncementQueuePullInitiatedAnnouncement new emit.
	
	pulledAnnouncements := self pollSerializedAnnouncementQueue 
		collect: [ :anAnnouncementData |
			GtRemoteRunnerAnnouncement fromSerializedData: anAnnouncementData ].
	
	GtRrAnnouncementQueuePullCompletedAnnouncement new 
		retrivedAnnouncementCount:  pulledAnnouncements size;
		emit.
	
	^ pulledAnnouncements
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> pollSerializedAnnouncementQueue [
	^ announcementQueue pollSerialized
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> processLabel: aLabel [
	processLabel := aLabel
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> startPoll [
	| duration count  |
	duration := 1.
	count := (self timeout ifNil: [ 10 hours]) totalSeconds // 10 + 10.
	
	[
		[ terminationCondition value not and: [ count > 0 ] ]
			whileTrue: [ 
				duration seconds wait.
				self pollAndDeliverAnnouncements.
				count := count - 1.
				duration < 10 ifTrue: [ duration := duration + 1 ] ].
		"Ensure there is at least one check of the completed tasks"
		self pollAndDeliverAnnouncements 
	]
		forkAt: Processor userBackgroundPriority
		named: (processLabel ifNil: [ 'Poll for Announcements' ])
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> terminationCondition: aBlock [
	terminationCondition := aBlock
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> timeout [
	^ timeout 
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> timeout: aTimeout [
]
