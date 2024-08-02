Class {
	#name : #GtRrWorkerCountCalculatorExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #private }
GtRrWorkerCountCalculatorExamples >> assert: number1 equals: number2 within: percentage [

	self assert: ((number1 asFloat - number2 asFloat) abs / number2 asFloat) <= percentage
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> availableMemory [
	"Check the values returned by the available memory models"
	<gtExample>
	| calculator fixedAvailableModel freeAvailableModel physicalAvailableModel fixedAvailable freeAvailable physicalAvailable oldPriority |

	calculator := GtRrWorkerCountCalculator new.
	calculator algorithm: GtRrWorkerCountResourceAlgorithm new.
	fixedAvailableModel := GtRrWorkerCountFixedAvailableMemoryModel new
		availableMemory: 123456.
	freeAvailableModel := GtRrWorkerCountFreeMemoryModel new.
	physicalAvailableModel := GtRrWorkerCountPhysicalMemoryModel new.
	"Ensure there is free memory so old space doesn't change significantly during the run"
	Smalltalk growMemoryByAtLeast: (Smalltalk vm parameterAt: 2) * 2.
	oldPriority := Processor activeProcess priority.

	[ Processor activeProcess priority: Processor lowIOPriority.
	calculator algorithm availableMemoryModel: fixedAvailableModel.
	fixedAvailable := calculator algorithm availableMemoryModel availableMemory.
	calculator algorithm availableMemoryModel: freeAvailableModel.
	freeAvailable := calculator algorithm availableMemoryModel availableMemory.
	calculator algorithm availableMemoryModel: physicalAvailableModel.
	physicalAvailable := calculator algorithm availableMemoryModel availableMemory. ]
		ensure: [ Processor activeProcess priority: oldPriority ].

	self assert: fixedAvailable equals: 123456.
	self assert: freeAvailable
		equals: GtOsSystemInfo current freeMemory
		within: 0.2.
	self assert: physicalAvailable
		equals: GtOsSystemInfo current physicalMemory
		within: 0.2.

]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> fixedRequiredSize [
	<gtExample>
	| calculator algorithm calculatedCount checkCount coreCount |

	coreCount := 128.
	algorithm := GtRrWorkerCountResourceAlgorithm new.
	algorithm
		availableMemoryModel: (GtRrWorkerCountFixedAvailableMemoryModel new availableMemory: 20 * (1024 ** 3));
		coreCount: coreCount;
		requiredMemoryModel: GtRrWorkerCountImageMemoryModel new.
	calculator := GtRrWorkerCountCalculator new.
	calculator
		algorithm: algorithm;
		minWorkers: 1;
		maxWorkers: SmallInteger maxVal;
		memorySizeMultiplier: 1.
	calculatedCount := calculator workerCount.
	checkCount := ((20 * (1024 ** 3)) / (FileLocator image size * 2)) truncated.
	self assert: calculatedCount equals: (checkCount min: coreCount).
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> freeMemoryVmSize [
	<gtExample>
	| calculator calculatedCount algorithm |

	algorithm := GtRrWorkerCountResourceAlgorithm new.
	algorithm
		availableMemoryModel: (GtRrWorkerCountFixedAvailableMemoryModel new availableMemory: 20 * (1024 ** 3));
		coreCount: 4;
		requiredMemoryModel: (GtRrWorkerCountFixedSizeRequiredMemoryModel new requiredMemory: 6 * (1024 ** 3)).
	calculator := GtRrWorkerCountCalculator new.
	calculator
		algorithm: algorithm;
		minWorkers: 1;
		maxWorkers: SmallInteger maxVal;
		memorySizeMultiplier: 1.
	calculatedCount := calculator workerCount.
	self assert: calculatedCount equals: 3.
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> maxWorkers [
	<gtExample>
	| calculator|

	calculator := GtRrWorkerCountCalculator new.
	calculator
		algorithm: (GtRrWorkerCountFixedCountAlgorithm new workerCount: 100);
		minWorkers: 1;
		maxWorkers: 5.
	self assert: calculator workerCount equals: 5.
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> minWorkers [
	<gtExample>
	| calculator|

	calculator := GtRrWorkerCountCalculator new.
	calculator
		algorithm: (GtRrWorkerCountFixedCountAlgorithm new workerCount: 1);
		minWorkers: 10;
		maxWorkers: SmallInteger maxVal.
	self assert: calculator workerCount equals: 10.
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> modelDefaults [
	<gtExample>
	| calculator |

	self assert: GtRrWorkerCountFreeMemoryModel new availableMemory
		equals: GtOsSystemInfo current freeMemory
		within: 0.2.
	self assert: GtRrWorkerCountPhysicalMemoryModel new availableMemory
		equals: GtOsSystemInfo current physicalMemory
		within: 0.2.

	self assert: (GtRrWorkerCountCurrentMemoryModel new 
			workerCountCalculator: (GtRrWorkerCountCalculator new
				memorySizeMultiplier: 1.95);
			requiredMemory)
		equals: SmalltalkImage current vm memorySize * 1.95
		within: 0.2.
	self assert: GtRrWorkerCountImageMemoryModel new requiredMemory
		equals: Smalltalk imageFile size * 2.

	calculator := GtRrWorkerCountCalculator new.
	self assert: calculator algorithm identicalTo: GtRrWorkerCountCalculator defaultAlgorithm.
	self assert: calculator minWorkers equals: GtRrWorkerCountCalculator defaultMinWorkers.
	self assert: calculator maxWorkers equals: GtRrWorkerCountCalculator defaultMaxWorkers.
	self assert: calculator memorySizeMultiplier equals: GtRrWorkerCountCalculator defaultMemorySizeMultiplier. 
]

{ #category : #examples }
GtRrWorkerCountCalculatorExamples >> requiredMemory [
	"Check the values returned by the available memory models"
	<gtExample>
	| calculator fixedRequiredModel currentRequiredModel imageRequiredModel fixedRequired currentRequired imageRequired oldPriority |

	calculator := GtRrWorkerCountCalculator new
		memorySizeMultiplier: 1.95.
	calculator algorithm: GtRrWorkerCountResourceAlgorithm new.
	fixedRequiredModel := GtRrWorkerCountFixedSizeRequiredMemoryModel new
		requiredMemory: 123456.
	currentRequiredModel := GtRrWorkerCountCurrentMemoryModel new.
	imageRequiredModel := GtRrWorkerCountImageMemoryModel new
		additionalOldSpace: 123456.
	"Ensure there is free memory so old space doesn't change significantly during the run"
	Smalltalk growMemoryByAtLeast: (Smalltalk vm parameterAt: 2) * 2.
	oldPriority := Processor activeProcess priority.

	[ Processor activeProcess priority: Processor lowIOPriority.
	calculator algorithm requiredMemoryModel: fixedRequiredModel.
	fixedRequired := calculator algorithm requiredMemoryModel requiredMemory.
	calculator algorithm requiredMemoryModel: currentRequiredModel.
	currentRequired := calculator algorithm requiredMemoryModel requiredMemory.
	calculator algorithm requiredMemoryModel: imageRequiredModel.
	imageRequired := calculator algorithm requiredMemoryModel requiredMemory. ]
		ensure: [ Processor activeProcess priority: oldPriority ].

	self assert: fixedRequired equals: 123456.
	self assert: currentRequired
		equals: Smalltalk vm memorySize * 1.95
		within: 0.2.
	self assert: imageRequired
		equals: Smalltalk imageFile size + 123456.
]
