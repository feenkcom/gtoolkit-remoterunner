"
GtResourceWorkerCountCalculator determines the number of workers to create based on available system resources:

- At least minWorkers are created.
- No more than maxWorkers are created.
- The number is the smaller of:
  - The number of CPU cores of the host machine
  - Memory / (VM memorySize * memorySizeMultiplier)
  
  Memory is dependent on the algorithm:
  
  - Physical memory: Memory = [physical RAM in the machine] - 4GB
  - Free memory: Memory = free memory as reported by the OS.
"
Class {
	#name : #GtRrResourceWorkerCountCalculator,
	#superclass : #GtRrWorkerCountCalculator,
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
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultAlgorithm [
	^ DefaultAlgorithm
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultAlgorithm: aSymbol [

	(#(#workerCountPhysicalMemory #workerCountFreeMemory) includes: aSymbol) ifFalse:
		[ self error: 'Invalid algorithm: ', aSymbol printString ] .
	DefaultAlgorithm := aSymbol
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMaxWorkers [
	^ DefaultMaxWorkers
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMaxWorkers: anObject [
	DefaultMaxWorkers := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMemorySizeMultiplier [
	^ DefaultMemorySizeMultiplier
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMemorySizeMultiplier: anObject [
	DefaultMemorySizeMultiplier := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMinWorkers [
	^ DefaultMinWorkers
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> defaultMinWorkers: anObject [
	DefaultMinWorkers := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator class >> gtViewAlgorithmsFor: aView [
	<gtView>
	<gtClassView>
	
	^ aView columnedList 
		title: 'Worker Count Algorithms';
		priority: 31;
		items: [ {
			'Based on physical memory' -> #workerCountPhysicalMemory.
			'Based on free memory' ->#workerCountFreeMemory} ];
		column: 'Algorithm' text: [ :each | each key ];
		column: 'Worker count' text:[ :each | self new
			perform: each value ];
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
GtRrResourceWorkerCountCalculator class >> gtViewDefaultsFor: aView [
	<gtView>
	<gtClassView>
	
	^ aView columnedList 
		title: 'Defaults';
		priority: 34;
		items: [ {
			{'Min workers' . 
				self defaultMinWorkers . 
				self new minWorkers}.
			{'Max workers' . 
				self defaultMaxWorkers. 
				self new maxWorkers}.
			{'Algorithm' . 
				self defaultAlgorithm. 
				self new algorithm}.
			{'Memory multiplier' . 
				self defaultMemorySizeMultiplier. 
				self new memorySizeMultiplier}.
		} ];
		column: 'Property' text: [ :each | each first ];
		column: 'Current value' text:[ :each | each third ];
		column: 'Saved value' text:[ :each | each second ];
		send: [ :each | each second ]
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> algorithm [
	^ algorithm ifNil: [ algorithm := DefaultAlgorithm ifNil: [ #workerCountPhysicalMemory ] ]
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> algorithm: anObject [
	algorithm := anObject
]

{ #category : #'gt - extensions' }
GtRrResourceWorkerCountCalculator >> gtViewDetailsFor: aView [
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
				'VM Multiplied Memory' -> (SmalltalkImage current vm memorySize * self memorySizeMultiplier) asInteger humanReadableSISizeString.
				'Computed Workers Count' -> self workerCount} ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Property' text: [ :assoc | assoc value ];
		actionUpdateButton
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> maxWorkers [

	^ maxWorkers ifNil: [ maxWorkers := DefaultMaxWorkers ifNil: [ SmallInteger maxVal ] ].
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> maxWorkers: anInteger [

	anInteger < self minWorkers ifTrue:
		[ self error: 'minWorkers must be <= maxWorkers' ].
	maxWorkers := anInteger
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> memorySizeMultiplier [

	^ memorySizeMultiplier ifNil: [ memorySizeMultiplier :=
		DefaultMemorySizeMultiplier ifNil: [ 1.95 ] ].
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> memorySizeMultiplier: anObject [

	memorySizeMultiplier := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> minWorkers [

	^ minWorkers ifNil: [ minWorkers := DefaultMinWorkers ifNil: [ 1 ] ].
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> minWorkers: anInteger [

	anInteger > self maxWorkers ifTrue:
		[ self error: 'minWorkers must be <= maxWorkers' ].
	minWorkers := anInteger
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> workerCount [
	"Answer the number of workers to start"

	^ self algorithm value: self.
]

{ #category : #algorithm }
GtRrResourceWorkerCountCalculator >> workerCountFreeMemory [
	"Answer the number of workers to start"
	| systemInfo cpuCores freeMemory memorySize |

	systemInfo := GtOsSystemInfo current.
	cpuCores := systemInfo numberOfCores.
	freeMemory := systemInfo freeMemory.
	memorySize := SmalltalkImage current vm memorySize.
	^ self 
		workerCountFromVmMemory: memorySize
		cpuCores: cpuCores 
		freeMemory: freeMemory.
]

{ #category : #private }
GtRrResourceWorkerCountCalculator >> workerCountFromVmMemory: vmMemorySize cpuCores: cpuCores freeMemory: freeMem [
	| freeMemCount |

	freeMemCount := (freeMem / (vmMemorySize * self memorySizeMultiplier)) truncated.
	self minWorkers <= self maxWorkers ifFalse: [ 
		self error: 'minWorkers must be <= maxWorkers' ].
	^ ((cpuCores min: freeMemCount) min: self maxWorkers) max: self minWorkers
]

{ #category : #private }
GtRrResourceWorkerCountCalculator >> workerCountFromVmMemory: vmMemorySize cpuCores: cpuCores physicalMemory: physicalMem [
	| physicalMemCount |

	physicalMemCount := ((physicalMem - 4) / (vmMemorySize * self memorySizeMultiplier)) truncated.
	^ ((cpuCores min: physicalMemCount) min: self maxWorkers) max: self minWorkers
]

{ #category : #algorithm }
GtRrResourceWorkerCountCalculator >> workerCountPhysicalMemory [
	"Answer the number of workers to start"
	| systemInfo cpuCores physicalMem memorySize |

	systemInfo := GtOsSystemInfo current.
	cpuCores := systemInfo numberOfCores.
	physicalMem := systemInfo physicalMemory.
	memorySize := SmalltalkImage current vm memorySize.
	^ self 
		workerCountFromVmMemory: memorySize
		cpuCores: cpuCores 
		physicalMemory: physicalMem.
]
