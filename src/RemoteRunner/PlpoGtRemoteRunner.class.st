Class {
	#name : #PlpoGtRemoteRunner,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TPlpoGtWithAnnouncementsQueueListener',
	#classTraits : 'TPlpoGtWithAnnouncementsQueueListener classTrait',
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRemoteRunner class >> remoteClassName [

	^ #GtRemoteRunner
]

{ #category : #accessing }
PlpoGtRemoteRunner >> actOnProxyObjectCreated [
	super actOnProxyObjectCreated.
	
	"We can start receiving announcements right after the proxy object has been fully initialized.
	The code that creates the remote job is responsible with attaching the queue before any relevant action that can trigger announcements is executed."
	self initializeAnnouncementsQueueListener.
]

{ #category : #'announcements - queue' }
PlpoGtRemoteRunner >> configureAnnouncementsQueueListener: aListener [
	aListener
		"timeout: self jobTimeout;"
		terminationCondition: [ self isRunning not ]
]

{ #category : #testing }
PlpoGtRemoteRunner >> isIdle [

	^ self proxyPerform: #isIdle.
]

{ #category : #testing }
PlpoGtRemoteRunner >> isRunning [

	^ self proxyPerform: #isRunning.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> jobStartupAndShutdown [

	^ self proxyPerform: #jobStartupAndShutdown.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> port [

	^ self proxyPerform: #port.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> registerAndStartAnnouncementsQueue [
	"A manual way to start collecting announcements in the remote object and delivering them locally."

	self registerAnnouncementsQueueForJobsAndWorkers.
	self startAnnouncementsListener.
]

{ #category : #'announcements - queue' }
PlpoGtRemoteRunner >> registerAnnouncementsQueueForJobsAndWorkers [
	"Start the announcements queue only for announcements for job and workers."
	
	^ self proxyPerform: #registerAnnouncementsQueueForJobsAndWorkers
]

{ #category : #'code sync' }
PlpoGtRemoteRunner >> startCodeSync [
	"Start the code sync listener, submitting changes to the receiver"

	^ GtRrCodeSync new
		remoteRunner: self;
		start.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> state [

	^ [ self proxyPerform: #state ]
		on: LanguageLinkServerNotRunningError
		do: [ :ex | #disconnected ].
]

{ #category : #accessing }
PlpoGtRemoteRunner >> stop [
	"We should be telling the remote to shut down, however in some circumstances it is terminating the listen process and shutting down existing connections, but not getting to the point of shutting down the server socket.
	Also, we should stop the PharoLinkApplication from listening for incoming messages since the connection is about to be closed.
	For now just shut down the application.
	TODO"

	application stop.
	"[ self newCommandFactory
		<< 'self stop';
		send ]
			on: Error
			do: [ :ex | ]"
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> submitJob: aGtRrJob [
	| jobProxy |
	"Submit the supplied job to the runner"

	jobProxy := self
		proxyPerform: #submitSerializedJob:
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize: aGtRrJob }.
		
	"Start manually here the listening for announcements, in tandem with #submitSerializedJob:, that registers the announcements queue."
	jobProxy startAnnouncementsListener.
	
	^ jobProxy
]

{ #category : #accessing }
PlpoGtRemoteRunner >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"
	
	^ self announcer unsubscribe: anObject
]

{ #category : #accessing }
PlpoGtRemoteRunner >> when: anAnnouncementClass send: aSelector to: anObject [

		^ self announcer when: anAnnouncementClass send: aSelector to: anObject
]
