Class {
	#name : #GtRemoteRunnerStats,
	#superclass : #Object,
	#instVars : [
		'totalJobCount',
		'totalTaskCount',
		'state',
		'taskQueueSize',
		'currentlyExecutingJobCount',
		'currentlyExecutingTaskCount',
		'defaultWorkerTimeout',
		'defaultTaskTimeout',
		'portNumber',
		'sharedAccessCount',
		'isRunning',
		'registeredWorkerCounts',
		'availableWorkerCounts',
		'jobStartupAndShutdown',
		'managerStartupAndShutdown',
		'registeredWorkerAttributes',
		'availableWorkerAttributes'
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
GtRemoteRunnerStats >> availableWorkerAttributes [
	^availableWorkerAttributes
]

{ #category : #accessing }
GtRemoteRunnerStats >> availableWorkerAttributes: anObject [
	availableWorkerAttributes := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> availableWorkerCount [
	^ availableWorkerCounts
		inject: 0
		into: [ :s :v | s + v ]
]

{ #category : #accessing }
GtRemoteRunnerStats >> availableWorkerCounts [

	^ availableWorkerCounts
]

{ #category : #serialisation }
GtRemoteRunnerStats >> availableWorkerCounts: anObject [
	^ availableWorkerCounts := anObject
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
	(registeredWorkerCounts isEmpty and:
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
		currentlyExecutingJobCount :=
		currentlyExecutingTaskCount :=
		sharedAccessCount := 0.
	isRunning := false.
	registeredWorkerCounts :=
		availableWorkerCounts := Dictionary new.
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
GtRemoteRunnerStats >> jobStartupAndShutdown [
	^ jobStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunnerStats >> jobStartupAndShutdown: anObject [
	jobStartupAndShutdown := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> managerStartupAndShutdown [
	^ managerStartupAndShutdown
]

{ #category : #accessing }
GtRemoteRunnerStats >> managerStartupAndShutdown: anObject [
	managerStartupAndShutdown := anObject
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
GtRemoteRunnerStats >> registeredWorkerAttributes [
	^registeredWorkerAttributes
]

{ #category : #accessing }
GtRemoteRunnerStats >> registeredWorkerAttributes: anObject [
	registeredWorkerAttributes := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> registeredWorkerCount [
	^ registeredWorkerCounts
		inject: 0
		into: [ :s :v | s + v ]
]

{ #category : #accessing }
GtRemoteRunnerStats >> registeredWorkerCounts [

	^ registeredWorkerCounts
]

{ #category : #serialisation }
GtRemoteRunnerStats >> registeredWorkerCounts: anObject [
	registeredWorkerCounts := anObject
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
GtRemoteRunnerStats >> state: anObject [
	state := anObject
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
GtRemoteRunnerStats >> totalJobCount: anObject [
	totalJobCount := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalTaskCount [

	^ totalTaskCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalTaskCount: anObject [
	^ totalTaskCount := anObject
]

{ #category : #accessing }
GtRemoteRunnerStats >> updateAvailableWorkerCounts: aDictionary [
	"Update the receiver's available worker counts from the runner's availableWorkers dictionary.
	Must be called within the runners sharedAccess."
	| bag counts |

	bag := Bag new.
	aDictionary do: [ :worker |
		bag add: worker remoteAddress ].
	counts := Dictionary new.
	bag keysAndValuesDo: [ :ipAddress :count |
		counts
			at: (GtRemoteRunner printIpAddress: ipAddress)
			put: count ].
	availableWorkerCounts := counts.
	availableWorkerAttributes := aDictionary values collect: [ :worker |
		worker attributes ].
]

{ #category : #accessing }
GtRemoteRunnerStats >> updateJobStartupAndShutdown: aJobStartupAndShutdown [

	jobStartupAndShutdown := aJobStartupAndShutdown asStatsDictionary.
]

{ #category : #accessing }
GtRemoteRunnerStats >> updateManagerStartupAndShutdown: aManagerStartupAndShutdown [

	managerStartupAndShutdown := aManagerStartupAndShutdown asStatsDictionary.
]

{ #category : #accessing }
GtRemoteRunnerStats >> updateRegisteredWorkerCounts: aDictionary [
	"Update the receiver's registered worker counts from the runner's registeredWorkers dictionary.
	Must be called within the runners sharedAccess."
	| bag counts |

	bag := Bag new.
	aDictionary do: [ :worker |
		bag add: worker remoteAddress ].
	counts := Dictionary new.
	bag keysAndValuesDo: [ :ipAddress :count |
		counts
			at: (GtRemoteRunner printIpAddress: ipAddress)
			put: count ].
	registeredWorkerCounts := counts.
	registeredWorkerAttributes := aDictionary values collect: [ :worker |
		worker attributes ].
]

{ #category : #accessing }
GtRemoteRunnerStats >> workersStateDescription [
	^ '{1} registered workers [{2} busy]' format: {
		self registeredWorkerCount. 
		self registeredWorkerCount - self availableWorkerCount }
]
