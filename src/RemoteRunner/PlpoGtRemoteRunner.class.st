Class {
	#name : #PlpoGtRemoteRunner,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TPlpoGtWithAnnouncementsQueueListener',
	#classTraits : 'TPlpoGtWithAnnouncementsQueueListener classTrait',
	#instVars : [
		'announcementNotifier'
	],
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

{ #category : #accessing }
PlpoGtRemoteRunner >> changesSyncEvents: aGtRrChangesSyncEncodedEvents [

	self 
		proxyPerform: #changesSyncEventsSerialized: 
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize:  aGtRrChangesSyncEncodedEvents }
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
PlpoGtRemoteRunner >> managerStartupAndShutdown [

	^ self proxyPerform: #managerStartupAndShutdown.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> port [

	^ self proxyPerform: #port.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> registerAndStartAnnouncementsQueue [
	"A manual way to start collecting announcements in the remote object and delivering them locally."

	self registerAnnouncementsQueueForHeadlessRunner.
	self startAnnouncementsListener.
]

{ #category : #'announcements - queue' }
PlpoGtRemoteRunner >> registerAnnouncementsQueueForHeadlessRunner [
	"Start the announcements queue only for announcements for job and workers."
	
	^ self proxyPerform: #registerAnnouncementsQueueForHeadlessRunner
]

{ #category : #accessing }
PlpoGtRemoteRunner >> registerJob: aGtRrJob [
	"Answer the proxy for the job when using a headless runner."
	| jobProxy |

	jobProxy := application proxyForObject: aGtRrJob.
	jobProxy originalJob: aGtRrJob.
	^ jobProxy
]

{ #category : #accessing }
PlpoGtRemoteRunner >> runnerStats [

	^ GtRemoteRunnerStats new initializeFromDictionary: 
		(self newCommandFactory
			setBySerialized;
			<< 'self runnerStats asDictionaryForExport';
			sendAndWait)
]

{ #category : #initialize }
PlpoGtRemoteRunner >> startAnnouncementsNotifier [

	announcementNotifier ifNotNil: [ ^ self ].
	self proxyPerform: #ensureAnnouncementsQueue.
	self ensureAnnouncementsListener.
	announcementNotifier := GtAnnouncementNotifier new
		addAnnouncer: self announcer;
		addAllWatching: GtRemoteRunner defaultWatchedAnnouncements.
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
	"Stop the remote runner in a mostly orderly fashion"

	StringSignal emit: 'Shut down proxy remote runner'.
	"Terminate any running jobs and stop the job manager first to allow completion before the connection is closed."
	[ self newCommandFactory
		<< 'self runJobShutdown';
		sendAndWait ]
			on: Error
			do: [ :ex | ].
	self stopAnnouncementNotifier.
	"Tell the runner to stop.  
	The connection will be closed by the runner as part of this, so don't wait."
	[ self newCommandFactory
		<< 'self stopAndQuit';
		send ]
			on: Error
			do: [ :ex | ].
	application stop.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> stopAnnouncementNotifier [

	announcementNotifier ifNil: [ ^ self ].
	announcementNotifier stop.
	announcementNotifier := nil.
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> submitJob: aGtRrJob [
	| jobProxy |
	"Submit the supplied job to the runner"

	jobProxy := aGtRrJob isLanguageLinkProxyObject ifTrue:
		[ self
			proxyPerform: #submitJobFromProxy:
			withPrimitiveArguments: { aGtRrJob } ]
	ifFalse: [ self
		proxyPerform: #submitSerializedJob:
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize: aGtRrJob } ].
		
	"Start manually here the listening for announcements, in tandem with #submitSerializedJob:, that registers the announcements queue."
	jobProxy startAnnouncementsListener.
	
	^ jobProxy
]

{ #category : #'code sync' }
PlpoGtRemoteRunner >> syncChanges [
	"Send changes from the current image to the remote runner"
	| omReference encodedChanges |

	omReference := STON fromString: (self newCommandFactory
		<< 'STON toString: GtRrChangesSync headReference';
		sendAndWait).
	encodedChanges := GtRrChangesSync uniqueInstance encodedChangesFrom: omReference.
	self newCommandFactory
		bindingAt: #encodedChanges put: encodedChanges;
		<< 'GtRrChangesSync applyChanges: encodedChanges';
		sendAndWait.
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> terminateJobId: anId [

	self 
		proxyPerform: #terminateJobId: 
		withPrimitiveArguments: {anId}
]

{ #category : #accessing }
PlpoGtRemoteRunner >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"
	
	^ self announcer unsubscribe: anObject
]

{ #category : #accessing }
PlpoGtRemoteRunner >> when: anAnnouncementClass send: aSelector to: anObject [

		^ self announcer weak when: anAnnouncementClass send: aSelector to: anObject
]

{ #category : #accessing }
PlpoGtRemoteRunner >> workersStateDescription [

	^[ self proxyPerform: #workersStateDescription ]
		on: LanguageLinkServerNotRunningError
		do: [ :ex | '<not connected>' ].
]
