"
{{gtClass:GtRrAnnouncementQueueLocalListener}} retries remote announcements and announces them locally.

This object wraps a proxy that has an announcement queue and starts a background process that retries announcements and announces them locally. 

There are several methods for configuring the listener:
	- {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>processLabel:|label=#selector}}
	- {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>timeout:|label=#selector}}
	- {{gtMethod:name=GtRrAnnouncementQueueLocalListener>>terminationCondition:|label=#selector}}
	
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
		'proxy',
		'requestTermination'
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

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> doPoll [
	"Poll annoucements from the current announcement queue"
	| duration count  |

	duration := 1.
	count := (self timeout ifNil: [ 10 hours]) totalSeconds // 10 + 10.
	[ requestTermination not and: [ count > 0 and: [ terminationCondition value not ] ] ]
		whileTrue: [ 
			duration seconds wait.
			self pollAndDeliverAnnouncements.
			count := count - 1.
			duration < 10 ifTrue: [ duration := duration + 1 ] ].
	"Ensure there is at least one check of the completed tasks,
	but only if termination was not requested."
	requestTermination ifFalse: [
		self pollAndDeliverAnnouncements ].
	isPolling := false.
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> emitAnnouncementQueueDeliveryCompletedFor: aCollectionOfAnnouncements [ 
	GtRrAnnouncementQueueDeliveryCompletedSignal new 
		announcementsCount: aCollectionOfAnnouncements size;
		emit
]

{ #category : #signaling }
GtRrAnnouncementQueueLocalListener >> emitAnnouncementQueueDeliveryInitiatedFor: aCollectionOfAnnouncements [
	GtRrAnnouncementQueueDeliveryInitiatedSignal new 
		announcementsCount: aCollectionOfAnnouncements size;
		emit
]

{ #category : #signaling }
GtRrAnnouncementQueueLocalListener >> emitAnnouncementQueuePullCompletedWithCount: anInteger [
	GtRrAnnouncementQueuePullCompletedSignal new 
		retrivedAnnouncementCount:  anInteger;
		emit. 
]

{ #category : #signaling }
GtRrAnnouncementQueueLocalListener >> emitAnnouncementQueuePullInitiated [
	GtRrAnnouncementQueuePullInitiatedSignal new emit.
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
	
	self emitAnnouncementQueueDeliveryInitiatedFor: newAnnouncements.
	
	newAnnouncements do: [ :anAnnouncement | 
		self announcer announce: anAnnouncement ].
	
	self emitAnnouncementQueueDeliveryCompletedFor: newAnnouncements.
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> pollAnnouncementQueue [
	| pulledAnnouncements |
	
	self emitAnnouncementQueuePullInitiated.
	
	pulledAnnouncements := self pollSerializedAnnouncementQueue 
		collect: [ :anAnnouncementData |
			GtRemoteRunnerAnnouncement fromSerializedData: anAnnouncementData ].
	
	self emitAnnouncementQueuePullCompletedWithCount:pulledAnnouncements size.
	
	^ pulledAnnouncements
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> pollSerializedAnnouncementQueue [
	^ [ proxy pollSerializedAnnouncementQueue ] 
		on: LanguageLinkServerNotRunningError
		do: [ :anExeption |
			anExeption asBeaconSignal emit.
			requestTermination := true.
			#() ]
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> processLabel: aLabel [
	processLabel := aLabel
]

{ #category : #accessing }
GtRrAnnouncementQueueLocalListener >> startPoll [
	"Start polling annoucements from the current announcement queue"
	
	self assert: [ proxy  notNil ].
	self assert: [ self isPolling not ].
	
	isPolling := true.
	requestTermination := false.
	
	[
		[ self doPoll ]
			on: LanguageLinkServerNotRunningError
			do: [ :ex |
				isPolling := false.
				requestTermination := true ].
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
