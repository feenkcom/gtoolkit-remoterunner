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
GtRrResourceWorkerCountCalculator >> algorithm [
	^ algorithm ifNil: [ algorithm := DefaultAlgorithm ifNil: [ #workerCountPhysicalMemory ] ]
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> algorithm: anObject [
	algorithm := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> gtViewDetailsFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Details';
		priority: 10;
		items: [ 
			{
				'CPU Cores'  -> GtOsSystemInfo current numberOfCores.
				'Physical memory' -> (GtOsSystemInfo current 
					physicalMemory humanReadableSIByteSize).
				'Free Memory' -> (GtOsSystemInfo current 
					freeMemory humanReadableSIByteSize).
				'VM Memory Size' -> SmalltalkImage current vm 
					memorySize humanReadableSIByteSize.
				'VM Memory Multiplier' -> self memorySizeMultiplier.
				'Computed Workers Count' ->  self workerCount
			} ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Property' text: [ :assoc | assoc value ];
		actionUpdateButton.
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

{ #category : #accessing }
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

{ #category : #accessing }
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
