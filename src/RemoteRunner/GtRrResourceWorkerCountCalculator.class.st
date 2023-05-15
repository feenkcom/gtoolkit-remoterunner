"
GtResourceWorkerCountCalculator determines the number of workers to create based on available system resources:

- At least minWorkers are created.
- No more than maxWorkers are created.
- The number is the smaller of:
  - The number of CPU cores of the host machine
  - Free Memory / (VM memorySize * memorySizeMultiplier)
"
Class {
	#name : #GtRrResourceWorkerCountCalculator,
	#superclass : #GtRrWorkerCountCalculator,
	#instVars : [
		'minWorkers',
		'maxWorkers',
		'memorySizeMultiplier',
		'spareCapacityMultiplier'
	],
	#category : #'RemoteRunner-Runner'
}

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
				'VM Memory Multiplier' -> memorySizeMultiplier.
				'Spare Capacity Multiplier' -> spareCapacityMultiplier.
				'Computed Workers Count' ->  self workerCount
			} ];
		column: 'Property' text: [ :assoc | assoc key ];
		column: 'Property' text: [ :assoc | assoc value ];
		actionUpdateButton.
]

{ #category : #initialization }
GtRrResourceWorkerCountCalculator >> initialize [

	super initialize.
	minWorkers := 1.
	maxWorkers := SmallInteger maxVal. 
	memorySizeMultiplier := 1.3.
	spareCapacityMultiplier := 1.5.
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> maxWorkers [

	^ maxWorkers
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> maxWorkers: anObject [

	maxWorkers := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> memorySizeMultiplier [

	^ memorySizeMultiplier
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> memorySizeMultiplier: anObject [

	memorySizeMultiplier := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> minWorkers [

	^ minWorkers
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> minWorkers: anObject [

	minWorkers := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> spareCapacityMultiplier [

	^ spareCapacityMultiplier
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> spareCapacityMultiplier: anObject [

	spareCapacityMultiplier := anObject
]

{ #category : #accessing }
GtRrResourceWorkerCountCalculator >> workerCount [
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

{ #category : #private }
GtRrResourceWorkerCountCalculator >> workerCountFromVmMemory: vmMemorySize cpuCores: cpuCores freeMemory: freeMem [
	| freeMemCount |

	freeMemCount := (freeMem / vmMemorySize / memorySizeMultiplier / spareCapacityMultiplier) truncated.
	minWorkers <= maxWorkers ifFalse: [ 
		self error: 'minWorkers must be <= maxWorkers' ].
	^ ((cpuCores min: freeMemCount) min: maxWorkers) max: minWorkers
]

{ #category : #private }
GtRrResourceWorkerCountCalculator >> workerCountFromVmMemory: vmMemorySize cpuCores: cpuCores physicalMemory: physicalMem [
	| physicalMemCount |

	physicalMemCount := ((physicalMem - 4) / vmMemorySize / memorySizeMultiplier / spareCapacityMultiplier) truncated.
	minWorkers <= maxWorkers ifFalse: [ 
		self error: 'minWorkers must be <= maxWorkers' ].
	^ ((cpuCores min: physicalMemCount) min: maxWorkers) max: minWorkers
]
