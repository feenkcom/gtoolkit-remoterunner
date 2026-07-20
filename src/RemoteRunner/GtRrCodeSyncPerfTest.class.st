Class {
	#name : #GtRrCodeSyncPerfTest,
	#superclass : #Object,
	#instVars : [
		'literalSize',
		'stringLiteral',
		'methodSource',
		'entryFactory',
		'remoteRunner',
		'codeSyncJob',
		'startTime',
		'endTime',
		'runProcess',
		'vmStatsReport',
		'messageTally',
		'memoryLogger'
	],
	#category : 'RemoteRunner-Runner-CodeSync'
}

{ #category : #private }
GtRrCodeSyncPerfTest >> addDisableReplayEntries [
	"Add a method modification that disables actual replay of method events on the worker."
	| newSource methodDefinition |

	newSource := 'visitMethodAddition: aMethodCreated

	^ self'.
	methodDefinition := self eventFactory
		methodDefinitionSelector: #visitMethodAddition:
		className: #EpApplyVisitor
		meta: false
		package: EpApplyVisitor package asRingDefinition
		protocol: 'perf testing'
		sourceCode: newSource
		stamp: 'perf ', DateAndTime now printString.
	self eventFactory
		addMethod: methodDefinition
		tags: { #author -> 'Unknown'. #time -> DateAndTime now printString. #self -> (OmReference globalName: 'PerfTest' localName: '2'). #prior -> (OmReference globalName: 'PerfTest' localName: '1'). } asDictionary.

	newSource := 'visitMethodModification: aMethodCreated

	^ self'.
	methodDefinition := self eventFactory
		methodDefinitionSelector: #visitMethodModification:
		className: #EpApplyVisitor
		meta: false
		package: EpApplyVisitor package asRingDefinition
		protocol: 'perf testing'
		sourceCode: newSource
		stamp: 'perf ', DateAndTime now printString.
	self eventFactory
		addMethod: methodDefinition
		tags: { #author -> 'Unknown'. #time -> DateAndTime now printString. #self -> (OmReference globalName: 'PerfTest' localName: '2'). #prior -> (OmReference globalName: 'PerfTest' localName: '1'). } asDictionary.
]

{ #category : #private }
GtRrCodeSyncPerfTest >> addMethodEntry [
	| methodDefinition oldMethod |

	methodDefinition := self eventFactory
		methodDefinitionSelector: #answerLargeString
		className: self class name
		meta: true
		package: self class package asRingDefinition
		protocol: 'perf testing'
		sourceCode: self methodSource
		stamp: 'perf ', DateAndTime now printString.
	oldMethod := methodDefinition copy.
	oldMethod sourceCode: ' "The Start"', oldMethod sourceCode.
	self eventFactory
		modifyMethod: oldMethod
		to: methodDefinition
		tags: { #author -> 'Unknown'. #time -> DateAndTime now printString. #self -> (OmReference globalName: 'PerfTest' localName: '2'). #prior -> (OmReference globalName: 'PerfTest' localName: '1'). } asDictionary.
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncPerfTest >> codeSync [

	^ self remoteRunner managerStartupAndShutdown codeSync
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> durationString [

	startTime ifNil: [ ^ '<not started> '].
	^ endTime 
		ifNil: [ '{1}+' format: { (DateAndTime now - startTime) gtShortPrintString } ]
		ifNotNil: [ (endTime - startTime) gtShortPrintString ]
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> entryFactory: anObject [
	entryFactory := anObject
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> eventFactory [
	^ entryFactory ifNil: [ entryFactory := GtEpiceaEventFactory new ].
]

{ #category : #configuration }
GtRrCodeSyncPerfTest >> forceBufferedCodeSync [
"Force use of buffered code sync"
	GtRrCodeSyncTask class compile:
'maxBufferedSize
	^ SmallInteger maxVal'.
]

{ #category : #ui }
GtRrCodeSyncPerfTest >> gtSummaryFor: aView [
	<gtView>

	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item first ];
		  column: #Value text: [ :item | item second ];
		  send: [ :item | item last ];
		  actionUpdateButton
]

{ #category : #initialization }
GtRrCodeSyncPerfTest >> initialize [

	super initialize.
	literalSize := 50 * 1024 * 1024.
]

{ #category : #private }
GtRrCodeSyncPerfTest >> jobCompleted: anAnnouncement [

	endTime := DateAndTime now.
	codeSyncJob := anAnnouncement job.
	vmStatsReport recordTargetReport.
	self stop.
	memoryLogger stop.
	UIManager default inform: 'Perf job completed'.
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> literalSize [
	^ literalSize
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> literalSize: anObject [
	literalSize := anObject
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncPerfTest >> messageTally [

	messageTally := MessageTally new.
	messageTally reportOtherProcesses: true.
	[ messageTally 
				spyAllEvery: MessageTally defaultPollPeriod 
				on: [ [ endTime isNil ] whileTrue: [ 1 second wait ] ] ] forkAt: 41.
	^ messageTally.
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> methodSource [
	^ methodSource ifNil: [ methodSource := String streamContents: [ :stream |
	stream
		<< 'answerLargeString'; cr;
		cr; tab;
		<< '^ ''';
		<< self stringLiteral;
		nextPut: $';
		cr ] ].
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> methodSource: anObject [
	methodSource := anObject
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> remoteRunner [
	| registeredSemaphore |
	
	remoteRunner ifNotNil: [ ^ remoteRunner ].
	remoteRunner := GtRemoteRunner new
		port: 0;
		startLogging;
		yourself.
	remoteRunner managerStartupAndShutdown changesSync: false.
	remoteRunner
		when: GtRrJobCompletedAnnouncement
		send: #jobCompleted:
		to: self.
	registeredSemaphore := Semaphore new.
	remoteRunner
		when: GtRrWorkerRegisteredAnnouncement
		do: [ registeredSemaphore signal ]
		for: self.
	remoteRunner start.
	remoteRunner managerStartupAndShutdown poolSize timesRepeat:
		[ (registeredSemaphore waitTimeoutSeconds: 20) ifTrue:
			[ self error: 'No workers registered' ] ].
	^ remoteRunner
]

{ #category : #actions }
GtRrCodeSyncPerfTest >> run [

	runProcess := [
		"Add the events to the factory"
		self addDisableReplayEntries.
		self addMethodEntry.
		memoryLogger := MemoryLogger new.
		memoryLogger startFor: GtJustContextStackSignal, StringSignal.
		vmStatsReport := GtVmAllParametersDiffReport new.
		vmStatsReport recordSourceReport.
		"Notify the code sync that there are changes to be propagated"
		startTime := DateAndTime now.
		self messageTally.
		self eventFactory entries do:
			[ :omEntry |
				self codeSync onEntryAdded: (EpEntryAdded for: omEntry) ].
	] forkAt: Processor userBackgroundPriority - 5.
]

{ #category : #actions }
GtRrCodeSyncPerfTest >> runBufferedChanges [

	self forceBufferedCodeSync.
	self run.
]

{ #category : #actions }
GtRrCodeSyncPerfTest >> runFileChanges [

	self useFileCodeSync.
	self run.
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> status [

	endTime ifNotNil: [ ^ #completed ].
	startTime ifNotNil: [ ^ #running ].
	^ #notStarted
]

{ #category : #actions }
GtRrCodeSyncPerfTest >> stop [

	remoteRunner stop
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> stringLiteral [
	^ stringLiteral ifNil: [ stringLiteral := String loremIpsum: literalSize ]
]

{ #category : #accessing }
GtRrCodeSyncPerfTest >> stringLiteral: anObject [
	stringLiteral := anObject
]

{ #category : #ui }
GtRrCodeSyncPerfTest >> summaryAttributes [

	^ {
		{ 'Status'. self status. }.
		{ 'Duration'. self durationString. }.
	}
]

{ #category : #'as yet unclassified' }
GtRrCodeSyncPerfTest >> useFileCodeSync [
"Use file code sync"
	GtRrCodeSyncTask class compile:
'maxBufferedSize
	^ 256000'.
]
