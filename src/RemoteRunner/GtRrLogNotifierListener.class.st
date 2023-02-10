Class {
	#name : #GtRrLogNotifierListener,
	#superclass : #Object,
	#instVars : [
		'runner',
		'notification',
		'openTime',
		'announcements'
	],
	#category : #'RemoteRunner-Jobs-Notifications'
}

{ #category : #accessing }
GtRrLogNotifierListener >> announcements [
	^ announcements
]

{ #category : #accessing }
GtRrLogNotifierListener >> announcements: anObject [
	announcements := anObject
]

{ #category : #'private - accessing' }
GtRrLogNotifierListener >> defaultAnnouncements [
	"Answer the default collection of announcements that will be displayed."
	
	^ { GtRrResultProcessingErrorAnnouncement.
		GtRrWorkerChangesSyncErrorAnnouncement.
		}.
]

{ #category : #accessing }
GtRrLogNotifierListener >> gtUserNotificationsFor: aView [
	<gtView>

	^ aView columnedList
		title: 'User Notifications';
		priority: 10;
		items: [ self userNotifications reversed ];
		column: 'Time' text: [ :item | item timestamp ];
		column: 'Message' text: [ :item | item printString ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrLogNotifierListener >> initialize [

	super initialize.
	announcements := self defaultAnnouncements.
]

{ #category : #'private - accessing' }
GtRrLogNotifierListener >> notification [

	^ notification
]

{ #category : #private }
GtRrLogNotifierListener >> notificationCount [
	"Answer the number of notifications in the log"
	| count |

	count := 0.
	runner log recordings
		select: [ :each | (announcements includes: each class) and:
			[ each timestamp >= openTime ] ]
		thenDo: [ :each | count := count + 1 ].
	^ count
]

{ #category : #private }
GtRrLogNotifierListener >> onAnnouncement: aGtRemoteRunnerAnnouncement [

	(announcements includes: aGtRemoteRunnerAnnouncement class) ifFalse: [ ^ self ].
	notification 
		ifNil: 
			[ openTime := aGtRemoteRunnerAnnouncement timestamp.
			self openNotification ]
		ifNotNil: 
			[ notification message: self notificationCount asString, ' Remote Runner User Notifications' ].
]

{ #category : #accessing }
GtRrLogNotifierListener >> onNotificationClosed [

	notification := nil.
]

{ #category : #private }
GtRrLogNotifierListener >> openNotification [

	notification := GtObjectNotificationMessage new
		object: self;
		message: self notificationCount asString, ' Remote Runner User Notifications';
		registerNotifications.
	notification
		onRemovalRequestSend: #onNotificationClosed
		to: self
]

{ #category : #accessing }
GtRrLogNotifierListener >> runner [
	^ runner
]

{ #category : #accessing }
GtRrLogNotifierListener >> runner: aGtRemoteRunner [

	runner ifNotNil:
		[ runner unsubscribe: self ].
	runner := aGtRemoteRunner.
	runner log announcer
		when: GtRemoteRunnerAnnouncement
		send: #onAnnouncement:
		to: self.
]

{ #category : #'start - stop' }
GtRrLogNotifierListener >> stop [

	runner unsubscribe: self.
]

{ #category : #accessing }
GtRrLogNotifierListener >> userNotifications [
	"Answer the user notifications from the runner's log"

	^ runner log recordings select: [ :each | 
		(announcements includes: each class) and:
			[ each timestamp >= openTime ] ]
]
