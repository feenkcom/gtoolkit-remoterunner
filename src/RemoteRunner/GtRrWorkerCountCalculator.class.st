"
GtResourceWorkerCountCalculator determines the number of workers to create based on available system resources:

- At least minWorkers are created.
- No more than maxWorkers are created.
- The algorithm is a subclass of {{gtClass:GtRrWorkerCountAlgorithm}} 

For resource based calculations, the number is the smaller of:
  - The number of CPU cores of the host machine
  - Memory / (VM memorySize * memorySizeMultiplier)
  
  Memory is dependent on the algorithm:
  
  - Physical memory: Memory = [physical RAM in the machine] - 4GB
  - Free memory: Memory = free memory as reported by the OS.
"
Class {
	#name : #GtRrWorkerCountCalculator,
	#superclass : #Object,
	#instVars : [
		'minWorkers',
		'maxWorkers',
		'memorySizeMultiplier',
		'algorithm'
	],
	#classVars : [
		'DefaultAlgorithm',
		'DefaultMaxWorkers',
		'DefaultMemorySizeMultiplier',
		'DefaultMinWorkers'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountCalculator class >> cleanUp [

	DefaultAlgorithm := DefaultMaxWorkers := DefaultMinWorkers := DefaultMemorySizeMultiplier := nil.
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultAlgorithm [
	^ DefaultAlgorithm ifNil: [ DefaultAlgorithm := GtRrWorkerCountResourceAlgorithm new ] 
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultAlgorithm: aGtRrWorkerCountAlgorithm [
	"Set the default algorithm to use when calculating the number of workers"
	"Backword compatibility with the previous incarnation:
	#workerCountFreeMemory = GtRrWorkerCountFreeMemoryAlgorithm.
	#workerCountPhysicalMemory = GtRrWorkerCountPhysicalMemoryAlgorithm."
	DefaultAlgorithm := aGtRrWorkerCountAlgorithm == #workerCountFreeMemory ifTrue:
		[ GtRrWorkerCountFixedCountAlgorithm new ]
	ifFalse: [ aGtRrWorkerCountAlgorithm == #workerCountPhysicalMemory ifTrue:
		[ GtRrWorkerCountResourceAlgorithm new ]
	ifFalse:
		[ aGtRrWorkerCountAlgorithm ] ].
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMaxWorkers [
	^ DefaultMaxWorkers ifNil: [ DefaultMaxWorkers := SmallInteger maxVal ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMaxWorkers: anInteger [

	DefaultMaxWorkers := anInteger
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMemorySizeMultiplier [

	^ DefaultMemorySizeMultiplier ifNil: [ DefaultMemorySizeMultiplier := 1.95 ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMemorySizeMultiplier: aNumber [

	DefaultMemorySizeMultiplier := aNumber
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMinWorkers [

	^ DefaultMinWorkers ifNil: [ DefaultMinWorkers := 1 ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> defaultMinWorkers: anInteger [

	DefaultMinWorkers := anInteger
]

{ #category : #'instance creation' }
GtRrWorkerCountCalculator class >> fixedCount: anInteger [

	^ self new
		algorithm: (GtRrWorkerCountFixedCountAlgorithm new
			workerCount: anInteger);
		minWorkers: anInteger;
		maxWorkers: anInteger.
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> gtViewAlgorithmsFor: aView [
	<gtView>
	<gtClassView>
	
	^ aView columnedList 
		title: 'Worker Count Algorithms';
		priority: 31;
		items: [ {
			'Default' -> GtRrWorkerCountCalculator defaultAlgorithm.
			'Physical memory' -> #workerCountPhysicalMemory.
			'Free memory' ->#workerCountFreeMemory} ];
		column: 'Algorithm' text: [ :each | each key ];
		column: 'Worker count' text:[ :each | self new
			algorithm: each value;
			workerCount ];
		column: 'Is Default' 
			text: [ :each | (each value = (self defaultAlgorithm
					ifNil: [ #workerCountPhysicalMemory ]))
				ifTrue: ['Yes']
				ifFalse: [''] ]
			width: 75;
		send: [ :each |
			self new 
				algorithm: each value ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> gtViewDefaultsFor: aView [
	<gtView>
	<gtClassView>

	^ aView columnedList
		title: 'Defaults';
		priority: 30;
		items: [ #(#defaultAlgorithm #defaultMinWorkers #defaultMaxWorkers #defaultMemorySizeMultiplier) ];
		column: 'Default' text: #yourself;
		column: 'Value' text: [ :item | self perform: item ];
		send: [ :item | self perform: item ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrWorkerCountCalculator class >> leJsonV4Name [

	^ #gtRrWorkerCountCalculator
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> algorithm [
	<return: #GtRrWorkerCountAlgorithm>

	algorithm ifNil: [ self algorithm: self class defaultAlgorithm copy ].
	^ algorithm
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> algorithm: aGtRrFixedWorkerCountAlgorithm [
	"Set the algorithm to be used in calculating the number of workers"

	algorithm := aGtRrFixedWorkerCountAlgorithm.
	"Backword compatibility with the previous incarnation:
	#workerCountFreeMemory = GtRrWorkerCountFreeMemoryAlgorithm.
	#workerCountPhysicalMemory = GtRrWorkerCountPhysicalMemoryAlgorithm."
	algorithm == #workerCountFreeMemory ifTrue:
		[ algorithm := GtRrWorkerCountResourceAlgorithm new
			availableMemoryModel: GtRrWorkerCountFreeMemoryModel new ]
	ifFalse: [ algorithm == #workerCountPhysicalMemory ifTrue:
		[ algorithm := GtRrWorkerCountResourceAlgorithm new
			availableMemoryModel: GtRrWorkerCountPhysicalMemoryModel new ] ]. 
	algorithm workerCountCalculator: self.
]

{ #category : #ui }
GtRrWorkerCountCalculator >> calculationAttributes [

	^ Array streamContents: [ :stream |
		stream 
			nextPutAll: self algorithm calculationAttributes;
			nextPut: { 'Minimum Workers'. self minWorkers. };
			nextPut: { 'Maximum Workers'. self maxWorkers = SmallInteger maxVal
				ifTrue: [ 'unlimited' ]
				ifFalse: [ self maxWorkers ]. };
			nextPut: { 'Worker Count'. self workerCount. } ]
]

{ #category : #ui }
GtRrWorkerCountCalculator >> gtViewCalculationFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Calculation';
		priority: 10;
		items: [ self calculationAttributes ];
		column: 'Attribute' text: [ :item | item first ];
		column: 'Value' text: [ :item | item second ];
		send: [ :item | item last ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> gtViewDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 20;
		items: [ self parameterDetails ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Property' text: [ :assoc | assoc value ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> maxWorkers [

	^ maxWorkers ifNil: [ maxWorkers := DefaultMaxWorkers ifNil: [ SmallInteger maxVal ] ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> maxWorkers: anInteger [

	(minWorkers isNotNil and: [ anInteger < minWorkers ]) ifTrue:
		[ self error: 'minWorkers must be <= maxWorkers' ].
	maxWorkers := anInteger
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> memorySizeMultiplier [

	^ memorySizeMultiplier ifNil: [ memorySizeMultiplier :=
		DefaultMemorySizeMultiplier ifNil: [ 1.95 ] ].
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> memorySizeMultiplier: anObject [

	memorySizeMultiplier := anObject
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> minWorkers [

	^ minWorkers ifNil: [ minWorkers := DefaultMinWorkers ifNil: [ 1 ] ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> minWorkers: anInteger [

	(maxWorkers isNotNil and: [ anInteger > maxWorkers ]) ifTrue:
		[ self error: 'minWorkers must be <= maxWorkers' ].
	minWorkers := anInteger
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> parameterDetails [ 
	^ {
		'System CPU Cores' -> GtOsSystemInfo current numberOfCores.
		'System Physical memory'
					-> GtOsSystemInfo current physicalMemory humanReadableSISizeString.
		'System Free Memory' -> GtOsSystemInfo current freeMemory humanReadableSISizeString.
		'Current VM Memory Size'
					-> SmalltalkImage current vm memorySize humanReadableSISizeString.
		}, (self algorithm parameterDetailsWithCalculator: self) ,
		{ 'Algorithm Computed Workers Count' -> self workerCount }
]

{ #category : #initialization }
GtRrWorkerCountCalculator >> reset [
	"Reset cached run-time parameters, forcing the calculation to be updated."

	algorithm ifNotNil: [ algorithm reset ]
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> workerCount [
	"Answer the number of workers to start"

	^ self algorithm value
		min: self maxWorkers max: self minWorkers.
]
