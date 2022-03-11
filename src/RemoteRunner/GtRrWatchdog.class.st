Class {
	#name : #GtRrWatchdog,
	#superclass : #TKTService,
	#instVars : [
		'workers',
		'serverSocketAddress'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance creation' }
GtRrWatchdog class >> serverSocketAddress: aString [
	self new serverSocketAddress: aString
]

{ #category : #starting }
GtRrWatchdog >> addWorker [
	workers add: self startWorker.
]

{ #category : #accessing }
GtRrWatchdog >> initialize [
	super initialize.
	
	workers := OrderedCollection new.
]

{ #category : #accessing }
GtRrWatchdog >> pingAll [
	workers do: [:aWorker |
		aWorker pingAndCleanupIfNecessary.
	].
]

{ #category : #accessing }
GtRrWatchdog >> serverSocketAddress: aString [
	serverSocketAddress := aString
]

{ #category : #'private - setup' }
GtRrWatchdog >> startWorker [
	^ (GtRrWatchdogWorker new serverAddress: serverSocketAddress) start
]
