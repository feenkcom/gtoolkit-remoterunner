Class {
	#name : #GtRrWatchdog,
	#superclass : #TKTService,
	#instVars : [
		'workers',
		'serverSocketAddress',
		'future'
	],
	#category : #'RemoteRunner-Watchdog'
}

{ #category : #'instance creation' }
GtRrWatchdog class >> serverSocketAddress: aString [
	self new serverSocketAddress: aString
]

{ #category : #starting }
GtRrWatchdog >> addWorker [
	workers add: self newWorker.
]

{ #category : #accessing }
GtRrWatchdog >> initialize [
	super initialize.
	
	workers := OrderedCollection new.
]

{ #category : #'private - setup' }
GtRrWatchdog >> newWorker [
	^ (GtRrWatchdogWorker new serverAddress: serverSocketAddress)
]

{ #category : #accessing }
GtRrWatchdog >> pingAll [
	workers do: [:aWorker |
		aWorker pingAndCleanupIfNecessary.
	].
]

{ #category : #accessing }
GtRrWatchdog >> schedulePingAll [

	future := [ 
	self pingAll.
	self schedulePingAll ] asAsyncFuture delayed: 1 second await
]

{ #category : #accessing }
GtRrWatchdog >> serverSocketAddress: aString [
	serverSocketAddress := aString
]

{ #category : #accessing }
GtRrWatchdog >> start [
	workers do: [ :aWorker | aWorker start ].
	
	self schedulePingAll.
]

{ #category : #accessing }
GtRrWatchdog >> stop [
	workers do: [:aWorker | aWorker stop ].
	
	future cancelHard
]
