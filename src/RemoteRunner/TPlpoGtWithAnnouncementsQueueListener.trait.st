"
{{gtClass:TPlpoGtWithAnnouncementsQueueListener}} is an utility trait that can be added to a proxy object to propagate  locally announcements from the remote object.

This trait does not manage automatically the lifecycle of the queue listener. The proxy object, or its clients, should manage the lifecycle using:
	- {{gtMethod:name=TPlpoGtWithAnnouncementsQueueListener>>initializeAnnouncementsQueueListener|label=#selector}} 
	- {{gtMethod:name=TPlpoGtWithAnnouncementsQueueListener>>startAnnouncementsListener|label=#selector}}
	
The remote instance must have a queue attached. The queue is not attached automatically.
"
Trait {
	#name : #TPlpoGtWithAnnouncementsQueueListener,
	#instVars : [
		'announcementQueueListener'
	],
	#category : #'RemoteRunner-AnnouncementQueue'
}

{ #category : #accessing }
TPlpoGtWithAnnouncementsQueueListener >> announcer [
	^ announcementQueueListener announcer
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> configureAnnouncementsQueueListener: aLisstener [
	"Method that can be implemented in proxy classes to control how the listener is configured"
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> ensureAnnouncementsListener [
	"Ensure annoucnements are being propagated."

	announcementQueueListener isPolling ifFalse:
		[ announcementQueueListener startPoll ].
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> initializeAnnouncementsQueueListener [
	"Initialize and configure the queue listener. 
	Should be called only after the proxy object has been fully initialize, and there should be no calls to the remote object."
	
	announcementQueueListener := GtRrAnnouncementQueueLocalListener forAnnouncingProxy: self.
	self configureAnnouncementsQueueListener: announcementQueueListener
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> pollSerializedAnnouncementQueue [
	^ self proxyPerformSerialized: #pollSerializedAnnouncementQueue
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> registerAnnouncementsQueue [
	"Provides a manual way to start the collection of announcements in the remote object. Can be used in case the queue is not registered when creating the initial object, before returning a proxy to it."
	
	^ self proxyPerform: #registerAnnouncementsQueue
]

{ #category : #'announcements - queue' }
TPlpoGtWithAnnouncementsQueueListener >> startAnnouncementsListener [
	"Start propagating locally announcements from the remote queue."
	self assert: [ announcementQueueListener notNil ].
	
	announcementQueueListener startPoll
]
