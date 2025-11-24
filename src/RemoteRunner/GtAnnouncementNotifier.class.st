Class {
	#name : #GtAnnouncementNotifier,
	#superclass : #Object,
	#instVars : [
		'notification',
		'announcements',
		'watching',
		'announcers'
	],
	#category : 'RemoteRunner-Jobs-Notifications'
}

{ #category : #accessing }
GtAnnouncementNotifier >> addAllWatching: anAnnouncementClassCollection [
	"Add the supplied classes to the list of announcements that the user is notified of"

	anAnnouncementClassCollection do: [ :each |
		self addWatching: each ].
]

{ #category : #accessing }
GtAnnouncementNotifier >> addAnnouncer: anAnnouncer [
	"Add the supplied announcer to the collection that are listend to for user notifications"

	announcers add: anAnnouncer.
	watching do: [ :announcementClass |
		anAnnouncer
			when: announcementClass
			send: #onAnnouncement:
			to: self ].
]

{ #category : #accessing }
GtAnnouncementNotifier >> addWatching: anAnnouncementClass [
	"Add the supplied class to the list of announcements that the user is notified of"

	watching add: anAnnouncementClass.
	announcers do: [ :announcer |
		announcer
			when: anAnnouncementClass 
			send: #onAnnouncement:
			to: self ].
]

{ #category : #private }
GtAnnouncementNotifier >> announcementCount [
	"Answer the number of announcements received"

	^ announcements size
]

{ #category : #accessing }
GtAnnouncementNotifier >> announcements [

	^ announcements
]

{ #category : #accessing }
GtAnnouncementNotifier >> gtUserNotificationsFor: aView [
	<gtView>

	^ aView columnedList
		title: 'User notifications';
		priority: 10;
		items: [ announcements reversed ];
		column: 'Time' text: [ :item | item timestamp ];
		column: 'Message' text: [ :item | item printString ];
		actionUpdateButton
]

{ #category : #accessing }
GtAnnouncementNotifier >> initialize [

	super initialize.
	announcers := OrderedCollection new.
	announcements := OrderedCollection new.
	watching := OrderedCollection new.
]

{ #category : #'private - accessing' }
GtAnnouncementNotifier >> notification [

	^ notification
]

{ #category : #private }
GtAnnouncementNotifier >> notificationMessage [
	| count |

	count := self announcementCount.
	^ count asString, (' Remote Runner User Notification' asPluralBasedOn: count)

]

{ #category : #private }
GtAnnouncementNotifier >> onAnnouncement: anAnnouncement [

	(watching includes: anAnnouncement class) ifFalse: [ ^ self ].
	announcements add: anAnnouncement asBeaconSignal.
	notification 
		ifNil: [ self openNotification ]
		ifNotNil: [ notification message: self notificationMessage ].
]

{ #category : #accessing }
GtAnnouncementNotifier >> onNotificationClosed [

	notification := nil.
	announcements := OrderedCollection new.
]

{ #category : #private }
GtAnnouncementNotifier >> openNotification [

	notification := GtObjectNotificationMessage new
		object: self;
		message: self notificationMessage;
		registerNotifications.
	notification
		onRemovalRequestSend: #onNotificationClosed
		to: self
]

{ #category : #'start - stop' }
GtAnnouncementNotifier >> stop [

	announcers do: [ :announcer | announcer unsubscribe: self ].
]
