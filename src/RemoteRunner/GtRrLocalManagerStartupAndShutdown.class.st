Class {
	#name : #GtRrLocalManagerStartupAndShutdown,
	#superclass : #GtRrManagerStartupAndShutdown,
	#instVars : [
		'inMemoryLog',
		'workerIndex',
		'autoRestart',
		'watchDog',
		'watchdogSemaphore',
		'processes',
		'workerCountCalculator',
		'connectionStrategyId',
		'changesSync',
		'workerManager'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> autoRestart [
	"Answer a boolean indicating whether the workers should be automatically restarted when they fail"

	^ self workerManager autoRestart
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> autoRestart: aBoolean [

	self workerManager autoRestart: aBoolean
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> changesSync [
	"Answer a boolean indicating whether workers should be started with changesSync enabled."
	<return: #Boolean>

	^ self workerManager changesSync
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> changesSync: aBoolean [
	"Set the flag indicating whether workers should be started with changesSync enabled."

	self workerManager changesSync: aBoolean
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> connectionStrategyId [
	"Answer the id of the strategy used by the worker to connect to the runner.
	For a list of valid values, see {{gtMethod:GtRrWorker class>>#commandLine}}"
	<return: #Symbol>

	^ self workerManager connectionStrategyId
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> connectionStrategyId: aSymbol [

	self workerManager connectionStrategyId: aSymbol
]

{ #category : #'gt-extension' }
GtRrLocalManagerStartupAndShutdown >> gtProcessesFor: aView [
	<gtView>

	^ aView list
		title: 'Processes';
		priority: 20;
		items: [ self workerManager processes ];
		actionUpdateButton.
]

{ #category : #ui }
GtRrLocalManagerStartupAndShutdown >> gtSummaryFor: aView [

	<gtView>
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item third ];
		  updateWhen: GtRrWorkerAnnouncement in: [ remoteRunner announcer ];
		  actionUpdateButton
]

{ #category : #testing }
GtRrLocalManagerStartupAndShutdown >> isRunning [

	^ self workerManager isRunning
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize [

	^ self workerManager poolSize
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> poolSize: anInteger [

	self workerManager poolSize: anInteger
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> processCount [

	^ self workerManager processCount
]

{ #category : #'startup - shutdown' }
GtRrLocalManagerStartupAndShutdown >> shutdown [ 

	self workerManager shutdownLocalWorkers.
	super shutdown.
]

{ #category : #'running tests' }
GtRrLocalManagerStartupAndShutdown >> signalWatchdog [
	"Signal the watchdog to check immediately.
	Used for testing."

	self workerManager signalWatchdog.
]

{ #category : #'startup - shutdown' }
GtRrLocalManagerStartupAndShutdown >> startup [ 

	self assert: self isRunning not.
	super startup.

	self workerManager startLocalWorkers.
]

{ #category : #ui }
GtRrLocalManagerStartupAndShutdown >> summaryAttributes [

	^ OrderedCollection new
		add: { #Running. self isRunning. self. };
		add: { #ProcessCount. self processCount. self workerManager. };
		yourself
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> workerCountCalculator [

	^ self workerManager workerCountCalculator
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> workerCountCalculator: anObject [

	self workerManager workerCountCalculator: anObject
]

{ #category : #accessing }
GtRrLocalManagerStartupAndShutdown >> workerManager [

	^ workerManager ifNil:
 		[ workerManager := GtRrWorkerManager new
 			remoteRunner: remoteRunner;
 			remoteIpAddress: remoteRunner port.
 		workerCountCalculator ifNotNil:
 			[ workerManager workerCountCalculator: workerCountCalculator ].
 		workerManager ].
]
