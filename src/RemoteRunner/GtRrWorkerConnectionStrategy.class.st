"
GtRrWorkerConnectionStrategys are responsible for maintaining the connection to the {{gtClass:GtRemoteRunner}}.

Strategies might include:

- permanently connected
- new connection per message

"
Class {
	#name : #GtRrWorkerConnectionStrategy,
	#superclass : #Object,
	#instVars : [
		'worker',
		'llSocketAddress'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWorkerConnectionStrategy class >> serverSocketAddress: aString worker: aGtRrWorker [

	^ self new
		socketAddress: aString;
		worker: aGtRrWorker
]

{ #category : #naming }
GtRrWorkerConnectionStrategy class >> strategyName [

	^ self subclassResponsibility 
]

{ #category : #'api - running' }
GtRrWorkerConnectionStrategy >> connectDuring: aBlock [
	"Evaluate aBlock passing in a connected PharoLinkApplication"

	^ self subclassResponsibility 
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> llSocketAddress [
	<return: #LanguageLinkSocketAddress>

	^ llSocketAddress
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> llSocketAddress: anObject [

	llSocketAddress := anObject
]

{ #category : #private }
GtRrWorkerConnectionStrategy >> newApplication [
	"Answer a new PharoLinkApplication.
	Subclasses will determine its lifetime"

	^ PharoLinkApplication newWith:
		  (PharoLinkApplication defaultSettings
			   serverProcessClass: LanguageLinkManualProcess;
			   serverSocketAddress: llSocketAddress;
			   debugMode: true;
			   yourself)
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> socketAddress: aString [

	self llSocketAddress: (LanguageLinkSocketAddress from: aString)
]

{ #category : #'start-stop' }
GtRrWorkerConnectionStrategy >> start [

	self subclassResponsibility 
]

{ #category : #'start-stop' }
GtRrWorkerConnectionStrategy >> stop [

	self subclassResponsibility 
]

{ #category : #naming }
GtRrWorkerConnectionStrategy >> strategyName [

	^ self class strategyName
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> worker [
	<return: #GtRrWorker>

	^ worker
]

{ #category : #accessing }
GtRrWorkerConnectionStrategy >> worker: anObject [

	worker := anObject
]
