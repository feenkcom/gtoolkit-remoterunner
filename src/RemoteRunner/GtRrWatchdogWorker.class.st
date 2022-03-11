Class {
	#name : #GtRrWatchdogWorker,
	#superclass : #Object,
	#instVars : [
		'pid',
		'serverAddress',
		'lastPing',
		'timeout',
		'process'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWatchdogWorker >> buildStartScript [

	^ '| worker |
		worker := GtRRWorker serverSocketAddress: ''{{1}}''.
		worker start.
		
		Semaphore new wait.' format: { serverAddress }
]

{ #category : #accessing }
GtRrWatchdogWorker >> defaultTimeout [
	^ 60 seconds
]

{ #category : #accessing }
GtRrWatchdogWorker >> pingAndCleanupIfNecessary [
	process status isExitedWithCode ifTrue: [
		^ self start.
	].
	
	(DateAndTime now - lastPing > self timeout) ifTrue: [
		process kill.
		^ self start.
	]
	
	"TODO: ping"
]

{ #category : #accessing }
GtRrWatchdogWorker >> serverAddress: aString [
	serverAddress := aString
]

{ #category : #accessing }
GtRrWatchdogWorker >> start [

	| startScript |
	serverAddress ifNil: [ 
		self error: 'I need a server address to start.' ].

	startScript := self buildStartScript.


	process := GtExternalProcessBuilder new
		           command: Smalltalk vm fileName;
		           args: { 
				           '--headless'.
				           Smalltalk image imagePath.
				           'eval'.
				           '--no-quit'.
				           startScript };
		           spawm.

	lastPing := DateAndTime now
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout [
	^ timeout ifNil: [ timeout := self defaultTimeout ].
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout: aTimeout [
	timeout := aTimeout
]
