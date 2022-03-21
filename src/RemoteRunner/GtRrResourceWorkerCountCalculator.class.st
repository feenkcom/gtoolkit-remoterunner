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
		'memorySizeMultiplier'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #initialization }
GtRrResourceWorkerCountCalculator >> initialize [

	super initialize.
	minWorkers := 1.
	maxWorkers := SmallInteger maxVal. 
	memorySizeMultiplier := 2.
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
GtRrResourceWorkerCountCalculator >> workerCount [
	"Answer the number of workers to start"
	| systemInfo cpuCores freeMem memorySize |

	systemInfo := GtOsSystemInfo current.
	cpuCores := systemInfo numberOfCores.
	freeMem := systemInfo freeMemory.
	memorySize := SmalltalkImage current vm memorySize.
	^ self 
		workerCountFromVmMemory: memorySize
		cpuCores: cpuCores 
		freeMemory: freeMem.
]

{ #category : #private }
GtRrResourceWorkerCountCalculator >> workerCountFromVmMemory: vmMemorySize cpuCores: cpuCores freeMemory: freeMem [
	| freeMemCount |

	freeMemCount := (freeMem / vmMemorySize / memorySizeMultiplier) truncated.
	^ ((minWorkers max: cpuCores)
		min: freeMemCount)
		min: maxWorkers.
]
