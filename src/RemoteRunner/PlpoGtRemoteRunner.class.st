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
