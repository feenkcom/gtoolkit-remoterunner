"
{{gtClass:GtRrAnnouncementQueueLocalListener}} retries remote announcements and announces them locally.

This object wraps an announcement queue and starts a background process that retries announcements and announces them locally. The announcements queue can be a local or proxy object.

There are several methods for configuring the listener:
	- {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>processLabel:|label=#selector}}
	-  {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>timeout:|label=#selector}}
	-  {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>terminationCondition::|label=#selector}}
	
There is no support currently provided for force-stopping or restarting listening for announcements.
"
Class {
	#name : #GtRrAnnouncementQueueLocalListener,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'processLabel',
		'terminationCondition',
		'timeout',
		'isPolling',
		'proxy'
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
	proxy := aProxy.
	announcer := Announcer new.
]

{ #category : #testing }
GtRrAnnouncementQueueLocalListener >> isPolling [
	^ isPolling ifNil: [ false] 
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
	^ proxy pollSerializedAnnouncementQueue
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> processLabel: aLabel [
	processLabel := aLabel
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> startPoll [
	"Start polling annoucements from the current announcement queue"
	| duration count  |
	
	self assert: [ proxy  notNil ].
	self assert: [ self isPolling not ].
	
	isPolling := true.
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
		self pollAndDeliverAnnouncements .
		isPolling := false.
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
