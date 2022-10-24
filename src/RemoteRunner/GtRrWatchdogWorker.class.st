Class {
	#name : #GtRrWatchdogWorker,
	#superclass : #Object,
	#instVars : [
		'pid',
		'serverAddress',
		'lastPing',
		'timeout',
		'process',
		'application'
	],
	#category : #'RemoteRunner-Watchdog'
}

{ #category : #accessing }
GtRrWatchdogWorker >> buildStartScript: aPingAddress [
	^ '| worker |
		worker := GtRRWorker serverSocketAddress: ''{1}''; pingSocketAddress: ''{2}''.
		worker start.
		
		Semaphore new wait.' format: { serverAddress . aPingAddress }
]

{ #category : #accessing }
GtRrWatchdogWorker >> defaultTimeout [
	^ 60 seconds
]

{ #category : #accessing }
GtRrWatchdogWorker >> ping [

	[ 
	(application newCommandFactory sendAndWait: 'worker commandPing')
	= #ping ifTrue: [ lastPing := DateAndTime now ] ] asAsyncFuture await
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

	| startScript aPingAddress |
	serverAddress ifNil: [ 
		self error: 'I need a server address to start.' ].

	aPingAddress := PharoLinkPortAllocator next.
	application := PharoLinkApplication newWith:
		  (PharoLinkApplication defaultSettings
			   serverProcessClass: LanguageLinkManualProcess;
			   serverSocketAddress: (LanguageLinkSocketAddress from: aPingAddress printString);
			   debugMode: true;
			   yourself).

	startScript := self buildStartScript: aPingAddress.

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

	lastPing := DateAndTime now.
	
	application start.
]

{ #category : #accessing }
GtRrWatchdogWorker >> stop [

	process status isExitedWithCode ifFalse: [ 
		process kill.
		process := nil ]
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout [
	^ timeout ifNil: [ timeout := self defaultTimeout ].
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout: aTimeout [
	timeout := aTimeout
]
