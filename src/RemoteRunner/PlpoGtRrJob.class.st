Class {
	#name : #PlpoGtRrJob,
	#superclass : #PharoLinkProxyObject,
	#instVars : [
		'announcer'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrJob class >> remoteClassName [

	^ #GtRrJob
]

{ #category : #initiailize }
PlpoGtRrJob >> actOnProxyObjectInitialized [
	announcer := Announcer new.
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> announcementQueue [
	^ self proxyPerform: #announcementQueue
]

{ #category : #accessing }
PlpoGtRrJob >> announcer [
	^ announcer
]

{ #category : #accessing }
PlpoGtRrJob >> isFinished [

	^ self proxyPerform: #isFinished
]

{ #category : #accessing }
PlpoGtRrJob >> jobName [
	
	^ self proxyPerform: #jobName
]

{ #category : #accessing }
PlpoGtRrJob >> jobTimeout [
	"Answer the receiver's timeout"

	^ self proxyPerform: #jobTimeout
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> pollAnnouncementQueue [
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

{ #category : #'announcements - queue' }
PlpoGtRrJob >> pollForAnnouncements [
	| newAnnouncements |
	newAnnouncements := self pollAnnouncementQueue.
	newAnnouncements do: [ :anAnnouncement | 
		self announcer announce: anAnnouncement ]
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> pollSerializedAnnouncementQueue [
	^ self newCommandFactory
		setBySerialized;
		<< ('self ', #pollSerializedAnnouncementQueue asString);
		sendAndWait
]

{ #category : #accessing }
PlpoGtRrJob >> results [
	"Answer the results from the job as an Array.
	Leave the return type as a proxy object as the size may be large."

	^ self newCommandFactory 
		<< 'results asArray';
		sendAndWait.
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> startPollForAnnouncementsListener [
	| duration count  |
	duration := 1.
	count := (self jobTimeout ifNil: [ 10 hours]) totalSeconds // 10 + 10.
	
	[
		[ self isFinished not and: [ count > 0 ] ]
			whileTrue: [ 
				duration seconds wait.
				self pollForAnnouncements.
				count := count - 1.
				duration < 10 ifTrue: [ duration := duration + 1 ] ].
		"Ensure there is at least one check of the completed tasks"
		self pollForAnnouncements 
	]
		forkAt: Processor userBackgroundPriority
		named: 'Poll for job announcements'
]

{ #category : #accessing }
PlpoGtRrJob >> state [
	
	^ self proxyPerform: #state
]

{ #category : #'announcer - subscription' }
PlpoGtRrJob >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"
	
	^ self announcer unsubscribe: anObject
]

{ #category : #'announcer - subscription' }
PlpoGtRrJob >> when: anAnnouncementClass send: aSelector to: anObject [

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]
