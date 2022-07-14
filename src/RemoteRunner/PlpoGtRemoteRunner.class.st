Class {
	#name : #PlpoGtRemoteRunner,
	#superclass : #PharoLinkProxyObject,
	#instVars : [
		'announcementsQueue'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRemoteRunner class >> remoteClassName [

	^ #GtRemoteRunner
]

{ #category : #testing }
PlpoGtRemoteRunner >> isIdle [

	^ self proxyPerform: #isIdle.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> jobStartupAndShutdown [

	^ self proxyPerform: #jobStartupAndShutdown.
]

{ #category : #accessing }
PlpoGtRemoteRunner >> port [

	^ self proxyPerform: #port.
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> queues [
	^ (self newCommandFactory
		<< 'self queues';
		sendAndWait) getValue
]

{ #category : #accessing }
PlpoGtRemoteRunner >> remoteAnnouncementQueue [
	^ self newCommandFactory
		<< 'GtRemoteAnnouncementQueue onAnnouncer: self';
		sendAndWait
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

	^ self proxyPerform: #state
]

{ #category : #accessing }
PlpoGtRemoteRunner >> stop [
	"Make a best attempt at stopping the remote, but don't raise an exception."

	[ self proxyPerform: #stop ]
		on: Error
		do: [ :ex | ]
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> submitJob: aGtRrJob [
	| jobProxy |
	"Submit the supplied job to the runner"

	jobProxy := self
		proxyPerform: #submitSerializedJob:
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize: aGtRrJob }.
		
	"Start manually here the listening for announcements, in tandem with #submitSerializedJob:, that registers the announcements queue."
	jobProxy startPollForAnnouncementsListener.
	
	^ jobProxy
]
