Class {
	#name : #GtRemoteRunnerStats,
	#superclass : #Object,
	#instVars : [
		'totalJobCount',
		'totalTaskCount',
		'state',
		'taskQueueSize',
		'registeredWorkerCount',
		'availableWorkerCount',
		'currentlyExecutingJobCount',
		'currentlyExecutingTaskCount',
		'defaultWorkerTimeout',
		'defaultTaskTimeout',
		'portNumber',
		'sharedAccessCount',
		'isRunning'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRemoteRunnerStats >> asDictionaryForExport [
	| dict |

	dict := Dictionary new.
	self class instVarNames do: [ :aSymbol |
		dict at: aSymbol put: (self perform: aSymbol) ].
	^ dict
]

{ #category : #accessing }
GtRemoteRunnerStats >> availableWorkerCount [
	^ availableWorkerCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> availableWorkerCount: anObject [

	availableWorkerCount := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> currentlyExecutingJobCount [
	^ currentlyExecutingJobCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> currentlyExecutingJobCount: anInteger [

	currentlyExecutingJobCount := anInteger.
	state := nil.
]

{ #category : #accessing }
GtRemoteRunnerStats >> currentlyExecutingTaskCount [
	^ currentlyExecutingTaskCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> currentlyExecutingTaskCount: anObject [
	currentlyExecutingTaskCount := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> defaultTaskTimeout [
	^ defaultTaskTimeout
]

{ #category : #accessing }
GtRemoteRunnerStats >> defaultTaskTimeout: anObject [
	defaultTaskTimeout := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> defaultWorkerTimeout [
	^ defaultWorkerTimeout
]

{ #category : #accessing }
GtRemoteRunnerStats >> defaultWorkerTimeout: anObject [
	defaultWorkerTimeout := anObject
]

{ #category : #private }
GtRemoteRunnerStats >> getState [
	isRunning ifFalse: [ ^ #stopped ].
	(registeredWorkerCount = 0 and:
		[ taskQueueSize > 0 or: [ currentlyExecutingJobCount > 0 ] ]) ifTrue: [ ^ #waitingForWorkers ].
	(taskQueueSize = 0 and: [ currentlyExecutingJobCount = 0 ]) ifTrue: [ ^ #idle ].
	(taskQueueSize > 0 or: [ currentlyExecutingJobCount > 0 ]) ifTrue: [ ^ #busy ].
	^ #'Unknown state'.
]

{ #category : #actions }
GtRemoteRunnerStats >> incrementJobCount [

	totalJobCount := totalJobCount + 1.
]

{ #category : #actions }
GtRemoteRunnerStats >> incrementTaskCount [

	totalTaskCount := totalTaskCount + 1.
]

{ #category : #initialization }
GtRemoteRunnerStats >> initialize [

	super initialize.
	totalJobCount := 
		totalTaskCount :=
		taskQueueSize :=
		registeredWorkerCount :=
		availableWorkerCount :=
		currentlyExecutingJobCount :=
		currentlyExecutingTaskCount :=
		sharedAccessCount := 0.
	isRunning := false.
]

{ #category : #initialization }
GtRemoteRunnerStats >> initializeFromDictionary: aDictionary [

	aDictionary keysAndValuesDo: [ :key :value |
		self perform: key asSymbol asMutator withArguments: { value } ]
]

{ #category : #accessing }
GtRemoteRunnerStats >> isRunning [
	^ isRunning
]

{ #category : #accessing }
GtRemoteRunnerStats >> isRunning: aBoolean [

	isRunning := aBoolean.
	state := nil.
]

{ #category : #accessing }
GtRemoteRunnerStats >> portNumber [
	^ portNumber
]

{ #category : #accessing }
GtRemoteRunnerStats >> portNumber: anObject [
	portNumber := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> registeredWorkerCount [
	^ registeredWorkerCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> registeredWorkerCount: anInteger [

	registeredWorkerCount := anInteger.
	state := nil.
]

{ #category : #accessing }
GtRemoteRunnerStats >> sharedAccessCount [
	^ sharedAccessCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> sharedAccessCount: anObject [
	sharedAccessCount := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> state [
	^ state ifNil: [ state := self getState ]
]

{ #category : #accessing }
GtRemoteRunnerStats >> taskQueueSize [
	^ taskQueueSize
]

{ #category : #accessing }
GtRemoteRunnerStats >> taskQueueSize: anInteger [

	taskQueueSize := anInteger.
	state := nil.
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalJobCount [

	^ totalJobCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalTaskCount [

	^ totalTaskCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> workersStateDescription [
	^ '{1} registered workers [{2} busy]' format: {
		registeredWorkerCount. 
		registeredWorkerCount - availableWorkerCount }
]
