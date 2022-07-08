Class {
	#name : #PlpoGtRemoteRunner,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
PlpoGtRemoteRunner class >> remoteClassName [

	^ #GtRemoteRunner
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

{ #category : #'api - jobs' }
PlpoGtRemoteRunner >> submitJob: aGtRrJob [
	"Submit the supplied job to the runner"

	^ self
		proxyPerform: #submitSerializedJob:
		withPrimitiveArguments: { LeJsonV4 uniqueInstance serialize: aGtRrJob }
]
