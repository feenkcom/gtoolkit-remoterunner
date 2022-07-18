Class {
	#name : #PlpoGtRrJob,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TPlpoGtWithAnnouncementsQueueListener',
	#classTraits : 'TPlpoGtWithAnnouncementsQueueListener classTrait',
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrJob class >> remoteClassName [

	^ #GtRrJob
]

{ #category : #initiailize }
PlpoGtRrJob >> actOnProxyObjectCreated [
	super actOnProxyObjectCreated.
	
	"We can start receiving announcements right after the proxy object has been fully initialized.
	The code that creates the remote job is responsible with attaching the queue before any relevant action that can trigger annoouncements is executed."
	self initializeAnnouncementsQueueListener.
]

{ #category : #'announcements - queue' }
PlpoGtRrJob >> announcementQueue [
	^ self proxyPerform: #announcementQueue
]

{ #category : #initiailize }
PlpoGtRrJob >> configureAnnouncementsQueueListener: aListener [
	aListener
		"timeout: self jobTimeout;"
		terminationCondition: [ self isFinished]
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

{ #category : #accessing }
PlpoGtRrJob >> results [
	"Answer the results from the job as an Array.
	Leave the return type as a proxy object as the size may be large."

	^ self newCommandFactory 
		<< 'results asArray';
		sendAndWait.
]

{ #category : #notifications }
PlpoGtRrJob >> showExamplesProgressNotification [
	"Open a global notification showing the progress of the receiver assuming all tasks are exmples / test related.
	This method is explicitly added to the proxy object, so that the notification will open on the actual proxy."

	^ GtRrExamplesProgressNotification job: self.
]

{ #category : #notifications }
PlpoGtRrJob >> showProgressNotification [
	"Open a global notification showing the progress of the receiver.
	This method is explicitly added to the proxy object, so that the notification will open on the actual proxy."

	^ GtRrJobProgressNotification job: self.
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
