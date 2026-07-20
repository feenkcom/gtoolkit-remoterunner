Class {
	#name : #GtRrCodeSyncExamples,
	#superclass : #Object,
	#classVars : [
		'TestValue'
	],
	#category : 'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrCodeSyncExamples class >> testValue [
	^ TestValue
]

{ #category : #accessing }
GtRrCodeSyncExamples class >> testValue: anObject [
	TestValue := anObject
]

{ #category : #examples }
GtRrCodeSyncExamples >> addRemoveMethod [
	<gtExample>
	<shouldLogWithEpicea>
	| runner codeSync semaphore |
	runner := self simpleRunner.
	codeSync := runner managerStartupAndShutdown codeSync.
	runner managerStartupAndShutdown poolSize: 1.
	[ semaphore := Semaphore new.
	runner 
		when: GtRrWorkerRegisteredAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	runner start.
	semaphore
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected registration announcement' ].
	"Signal the semaphore when a code sync task completes so we can wait for changes to be propagated"
	runner
		when: GtRrTaskCompletedAnnouncement 
		do: [ :ann | semaphore signal ] 
		for: self.
	"add/remove method changes should be propagated to workers"
	self assert: (self hasMethodIn: runner) not.
	semaphore consumeAllSignals.
	self class compile: 'blub ^ 1'.
	semaphore
		waitTimeoutMilliseconds: 5 seconds asMilliSeconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 1' ].
	self assert: (self hasMethodIn: runner).
	semaphore consumeAllSignals.
	self class removeSelector: #blub.
	semaphore
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 2' ].
	self assert: (self hasMethodIn: runner) not.
	"stopping sync should no longer propagate changes"
	codeSync stop.
	self class compile: 'blub ^ 1'.
	self assert: (self hasMethodIn: runner) not ] ensure: [ 
		self class removeSelector: #blub.
		runner stop ].
	^ runner
]

{ #category : #examples }
GtRrCodeSyncExamples >> bufferedSerialisation [
	"Test the serialisation of GtRrBufferedCodeSyncTask"
	<gtExample>
	| methodSource omEntries codeSyncTask deserializedEntries |

	methodSource := 'a1 ^1'.
	omEntries := self omEntriesWithSource: methodSource.
	codeSyncTask := GtRrBufferedCodeSyncTask entries: omEntries.
	self assert: omEntries size equals: 1.
	self assert: codeSyncTask serializedChanges
			equals: (STON toString: omEntries first).
	deserializedEntries := codeSyncTask entries.
	self assert: deserializedEntries size equals: 1.
	self assert: deserializedEntries first content sourceCode equals: methodSource.
]

{ #category : #examples }
GtRrCodeSyncExamples >> codeSyncTaskSelection [
	"Test the code sync task class selection"
	<gtExample>
	| omEntries |

	self assert: (GtRrCodeSyncTask forChanges: (self omEntriesWithSource: 'a1 ^1'))
		equals: GtRrBufferedCodeSyncTask.

	omEntries := self omEntriesWithSource: 
		('a1 ^''', (String loremIpsum: GtRrCodeSyncTask maxBufferedSize), '''').
	self assert: (GtRrCodeSyncTask forChanges: omEntries)
		equals: GtRrFileCodeSyncTask.
]

{ #category : #examples }
GtRrCodeSyncExamples >> evaluateExpressionSize: anInteger taskClass: codeSyncTaskClass poolSize: poolSizeInteger [
	| runner codeSync semaphore timestamp task expression job codeSyncJob |

	runner := GtRemoteRunner new
			port: 0;
			startLogging;
			yourself.
	codeSync := runner managerStartupAndShutdown codeSync.
	runner managerStartupAndShutdown changesSync: false.
	poolSizeInteger ifNotNil:
		[ runner managerStartupAndShutdown poolSize: poolSizeInteger ].
	[ semaphore := Semaphore new.
	runner
		when: GtRrWorkerRegisteredAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	runner start.
	semaphore
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [  "noop" ]
		onTimeout: [ self error: 'Didn''t receive expected registration announcement' ].	"Signal the semaphore when a code sync task completes so we can wait for changes to be propagated"
	runner
		when: GtRrJobCompletedAnnouncement
		do: [ :ann | 
			job := ann job.
			semaphore signal ]
		for: self.
	timestamp := DateAndTime now printString.
	semaphore consumeAllSignals.
	expression := String streamContents: [ :stream |
		stream
			nextPut: $";
			<< (String loremIpsum: anInteger);
			nextPut: $";
			cr;
			<< 'GtRrCodeSyncExamples testValue: ''';
			<< timestamp;
			nextPut: $' ].
	SystemAnnouncer uniqueInstance announce: 
		(ExpressionEvaluated expression: expression).
	semaphore
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [  "noop" ]
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 1' ].
	self assert: job isNotNil
		description: 'Code Sync job missing'.
	self assert: job class equals: GtRrCodeSyncJob.
	self assert: job templateTask class = codeSyncTaskClass
		description: [ 'Code Sync task class wrong: ', codeSyncTaskClass printString ].
	codeSyncJob := job.
	semaphore consumeAllSignals.
	task := GtRrScriptTask script: 'GtRrCodeSyncExamples testValue'.
	runner submitJob: task asJob.
	semaphore
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [  "noop" ]
		onTimeout: [ self error: 'Didn''t receive expected code sync announcement 2' ].
	self assert: task result equals: timestamp ] 
		ensure: [ runner stop ].
	^ codeSyncJob
]

{ #category : #examples }
GtRrCodeSyncExamples >> evaluateLargeExpression [
	<gtExample>
	| job |

	GtRemoteRunnerExamples new ignoreWorkerExamples ifTrue: [ ^ nil ].

	job := self evaluateExpressionSize: GtRrCodeSyncTask maxBufferedSize 
		taskClass: GtRrFileCodeSyncTask
		poolSize: 1.
	self assert: job templateTask entriesFile exists not.
]

{ #category : #examples }
GtRrCodeSyncExamples >> evaluateSmallExpression [
	<gtExample>

	GtRemoteRunnerExamples new ignoreWorkerExamples ifTrue: [ ^ nil ].

	^ self evaluateExpressionSize: 100 
		taskClass: GtRrBufferedCodeSyncTask
		poolSize: 1.
]

{ #category : #examples }
GtRrCodeSyncExamples >> fileSerialisation [
	"Test the serialisation of GtRrFileCodeSyncTask"
	<gtExample>
	| codeSyncTask |

	[ | omEntries methodSource deserializedEntries |
	methodSource := 'a1 ^1'.
	omEntries := self omEntriesWithSource: methodSource.
	codeSyncTask := GtRrFileCodeSyncTask entries: omEntries.
	self assert: omEntries size equals: 1.
	self assert: codeSyncTask entriesFile contents
			equals: (STON toString: omEntries first).
	deserializedEntries := codeSyncTask entries.
	self assert: deserializedEntries size equals: 1.
	self assert: deserializedEntries first content sourceCode equals: 'a1 ^1' ]
		ensure: 
			[ (codeSyncTask isNotNil and:
			[ codeSyncTask entriesFile isNotNil ]) ifTrue:
				[ codeSyncTask entriesFile delete ] ].
]

{ #category : #accessing }
GtRrCodeSyncExamples >> hasMethodIn: aRunner [
	| job semaphore |

	job := GtRrJob script: self class name , ' includesSelector: #blub'.
	semaphore := Semaphore new.
	job
		when: GtRrJobCompletedAnnouncement
		doOnce: [ semaphore signal ]
		for: self.
	aRunner submitJob: job.
	semaphore 
		waitTimeoutMilliseconds: 30 seconds asMilliSeconds
		onCompletion: [ "noop" ] 
		onTimeout: [ self error: 'Didn''t receive expected job completion announcement' ].
	^ job tasks first result
]

{ #category : #'private - helpers' }
GtRrCodeSyncExamples >> omEntriesWithSource: aString [
	"Answer a collection of OmEntry"
	| eventFactory methodDefinition |

	eventFactory := GtEpiceaEventFactory new.
	methodDefinition := eventFactory
		methodDefinitionSelector: #a1
		className: self class name
		meta: false
		package: self class package asRingDefinition
		protocol: 'example temporary'
		sourceCode: aString
		stamp: 'ex ', DateAndTime now printString.
	eventFactory 
		addMethod: methodDefinition 
		tags: (self tagsUsing: eventFactory).
	^ eventFactory entries.
]

{ #category : #'private - helpers' }
GtRrCodeSyncExamples >> simpleRunner [
	"Answer a started RemoteRunner.
	It is up to the caller to stop the runner (and thus the workers)."
	| remoteRunner  |

	remoteRunner := GtRemoteRunner new.
	remoteRunner managerStartupAndShutdown 
		autoRestart: false;
		changesSync: false;
		poolSize: 1.

	self assert: remoteRunner taskQueue size equals: 0.
	self assert: remoteRunner currentlyExecutingJobs size equals: 0.
	self assert: remoteRunner currentlyExecutingTasks size equals: 0.
	^ remoteRunner
]

{ #category : #'private - helpers' }
GtRrCodeSyncExamples >> tagsUsing: eventFactory [ 
	| index |

	index := eventFactory entries size.
	
	^ (Array streamContents: [ :stream |
		stream
			nextPut: #author -> self class name asString;
			nextPut: #time -> DateAndTime now printString.
		index > 0 ifTrue:
			[ stream
				nextPut: #prior -> (OmReference
					globalName: self class name
					localName: index asString) ].
		stream nextPut: #self -> (OmReference
			globalName: self class name
			localName: (index + 1) asString). ])
				asDictionary
		.
]
