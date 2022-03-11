Class {
	#name : #GtRrWatchdogWorker,
	#superclass : #Object,
	#instVars : [
		'pid',
		'serverAddress',
		'lastPing',
		'timeout'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrWatchdogWorker >> defaultTimeout [
	^ 60 seconds
]

{ #category : #accessing }
GtRrWatchdogWorker >> pingAndCleanupIfNecessary [
	"TODO: lookup PID and see whether the process is still running"
	
	"TODO: ping"
	
	(DateAndTime now - lastPing > self timeout) ifTrue: [
	"TODO: kill it with fire"
	]
	
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

	startScript := '
		| worker |
		worker := GtRRWorker serverSocketAddress: ''{{1}}''.
		worker start.
		
		Semaphore new wait.' format: { serverAddress }.


	"TODO: and then we execute this and save the pid"
	Smalltalk vm fileName , ' --headless ' , Smalltalk image imagePath
	, '" eval --no-quit "' , startScript , '"'.
	
	lastPing := DateAndTime now.
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout [
	^ timeout ifNil: [ timeout := self defaultTimeout ].
]

{ #category : #accessing }
GtRrWatchdogWorker >> timeout: aTimeout [
	timeout := aTimeout
]
