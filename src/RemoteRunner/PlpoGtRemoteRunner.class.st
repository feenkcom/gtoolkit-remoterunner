Class {
	#name : #PlpoGtRemoteRunner,
	#superclass : #PharoLinkProxyObject,
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
PlpoGtRemoteRunner >> port [

	^ self proxyPerform: #port.
]

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> queues [
	^ self newCommandFactory
		<< 'self queues asArray';
		sendAndWait
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
	"Submit the supplied job to the runner"

	^ self
		proxyPerform: #submitSerializedJob:
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize: aGtRrJob }
]
