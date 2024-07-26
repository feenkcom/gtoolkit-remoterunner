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

{ #category : #accessing }
GtRrWorkerCountCalculator class >> gtViewAlgorithmsFor: aView [
	<gtView>
	<gtClassView>
	
	^ aView columnedList 
		title: 'Worker Count Algorithms';
		priority: 31;
		items: [ {
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
GtRrWorkerCountCalculator >> algorithm [
	<return: #GtRrWorkerCountAlgorithm>

	^ algorithm ifNil: [ algorithm := self class defaultAlgorithm ] 
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> algorithm: aGtRrFixedWorkerCountAlgorithm [
	"Set the algorithm to be used in calculating the number of workers"

	algorithm := aGtRrFixedWorkerCountAlgorithm.
	"Backword compatibility with the previous incarnation:
	#workerCountFreeMemory = GtRrWorkerCountFreeMemoryAlgorithm.
	#workerCountPhysicalMemory = GtRrWorkerCountPhysicalMemoryAlgorithm."
	algorithm == #workerCountFreeMemory ifTrue:
		[ algorithm := GtRrWorkerCountFixedCountAlgorithm new ]
	ifFalse: [ algorithm == #workerCountPhysicalMemory ifTrue:
		[ algorithm := GtRrWorkerCountResourceAlgorithm new ] ]. 
]

{ #category : #accessing }
GtRrWorkerCountCalculator >> gtViewDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {'CPU Cores' -> GtOsSystemInfo current numberOfCores.
				'Physical memory'
					-> GtOsSystemInfo current physicalMemory humanReadableSISizeString.
				'Free Memory' -> GtOsSystemInfo current freeMemory humanReadableSISizeString.
				'VM Memory Size'
					-> SmalltalkImage current vm memorySize humanReadableSISizeString.
				'VM Memory Multiplier' -> self memorySizeMultiplier.
				'Computed Workers Count' -> self workerCount} ];
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
GtRrWorkerCountCalculator >> workerCount [
	"Answer the number of workers to start"

	^ (self algorithm value: self)
		min: self maxWorkers max: self minWorkers.
]
