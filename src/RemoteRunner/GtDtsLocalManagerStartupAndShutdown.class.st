Class {
	#name : #GtDtsLocalManagerStartupAndShutdown,
	#superclass : #GtDtsManagerStartupAndShutdown,
	#instVars : [
		'watchDog',
		'processes',
		'poolSize'
	],
	#category : #'RemoteRunner-Model'
}

{ #category : #initialization }
GtDtsLocalManagerStartupAndShutdown >> initialize [

	super initialize.
	poolSize := 2.
	processes := OrderedCollection new.

]

{ #category : #testing }
GtDtsLocalManagerStartupAndShutdown >> isRunning [

	^ watchDog isNotNil
]

{ #category : #private }
GtDtsLocalManagerStartupAndShutdown >> newWorkerLocalProcess [
	| settings args |

	self flag: 'TODO settings should come from outside'.
	settings := LanguageLinkSettings pharoDefaultSettings.
	args := OrderedCollection new.
	args
		add: settings serverImage fullName;
		add: 'clap';
		add: 'pharoLinkWorker'.
	remoteRunner debugMode ifTrue: [ args add: '--log' ].
	args
		add: '--taskPollForever';
		add: remoteRunner listenPort asString;
		add: '--detachChangesFromFileSystem'.
	^ GtSubprocessWithInMemoryOutput new
		  command: settings serverExecutable fullName;
		  arguments: args;
		  workingDirectory: settings workingDirectory resolve fullName;
		  terminateOnShutdown;
		  yourself
]

{ #category : #accessing }
GtDtsLocalManagerStartupAndShutdown >> poolSize [

	^ poolSize
]

{ #category : #accessing }
GtDtsLocalManagerStartupAndShutdown >> poolSize: anInteger [

	poolSize := anInteger
]

{ #category : #'startup - shutdown' }
GtDtsLocalManagerStartupAndShutdown >> shutdown [ 

	self isRunning ifFalse: [ ^ self ].
	[ watchDog terminate ]
		on: ProcessAlreadyTerminating
		do: [ "noop" ].
	watchDog := nil.
	processes
		do: #terminate;
		removeAll.
	super shutdown.

]

{ #category : #private }
GtDtsLocalManagerStartupAndShutdown >> startWatchDog [

	watchDog := [ 
	            [ 
	            | broken |
	            broken := processes reject: #isRunning.
	            broken do: [ :e | 
		            | process |
		            process := self newWorkerLocalProcess.
		            process run.
		            processes
			            remove: e;
			            add: process ].
	            1 minute wait ] repeat ] forkNamed:
		            'GtRemoteRunner local watch dog'.

]

{ #category : #'startup - shutdown' }
GtDtsLocalManagerStartupAndShutdown >> startup [ 

	self assert: processes isEmpty.
	self assert: self isRunning not.
	super startup.

	self startWatchDog.
	poolSize timesRepeat: [ 
		| process |
		process := self newWorkerLocalProcess.
		process run.
		processes add: process ]
]
