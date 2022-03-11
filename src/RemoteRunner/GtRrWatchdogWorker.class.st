Class {
	#name : #GtRrWatchdogWorker,
	#superclass : #Object,
	#instVars : [
		'pid',
		'serverAddress',
		'lastPing',
		'timeout',
		'process',
		'pingAddress'
	],
	#category : #'RemoteRunner-Watchdog'
}

{ #category : #accessing }
GtRrWatchdogWorker >> buildStartScript [
	^ '| worker |
		worker := GtRRWorker serverSocketAddress: ''{{1}}''; pingSocketAddress: ''{{2}}''.
		worker start.
		
		Semaphore new wait.' format: { serverAddress . pingAddress }
]

{ #category : #accessing }
GtRrWatchdogWorker >> defaultTimeout [
	^ 60 seconds
]

{ #category : #accessing }
GtRrWatchdogWorker >> ping [

	| aMessage |
	aMessage := Message selector: #commandPing.
	"TODO: send message to pingAddress"
]

{ #category : #accessing }
GtRrWatchdogWorker >> pingAndCleanupIfNecessary [
	process status isExitedWithCode ifTrue: [
		^ self start.
	].
	
	(DateAndTime now - lastPing > self timeout) ifTrue: [
		process kill.
		^ self start.
	].
	
	self ping
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

	pingAddress := PharoLinkPortAllocator next.

	startScript := self buildStartScript.


	process := GtExternalProcessBuilder new
		           command: Smalltalk vm fileName;
		           args: { 
				           '--headless'.
				           Smalltalk image imagePath.
				           'eval'.
				           '--no-quit'.
				           startScript };
				   "pipeStdin;
				   pipdeStdout;"
		           spawn.

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
