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
GtRrWorkerCountCalculatorExamples >> fixedRequiredSize [
	<gtExample>
	| calculator algorithm calculatedCount |

	algorithm := GtRrWorkerCountResourceAlgorithm new.
	algorithm
		availableMemoryModel: (GtRrWorkerCountAvailableMemoryModel new availableMemory: 20 * (1024 ** 3));
		requiredMemoryModel: (GtRrWorkerCountFixedSizeMemoryModel new requiredMemory: 6 * (1024 ** 3)).
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
GtRrWorkerCountCalculatorExamples >> freeMemoryVmSize [
	<gtExample>
	| calculator calculatedCount checkCount systemInfo|

	calculator := GtRrWorkerCountCalculator new.
	calculator
		minWorkers: 1;
		maxWorkers: SmallInteger maxVal;
		memorySizeMultiplier: 1.
	calculatedCount := calculator workerCount.
	systemInfo := GtOsSystemInfo current.
	checkCount := (systemInfo freeMemory / Smalltalk vm memorySize) truncated min: GtOsSystemInfo current numberOfCores.
	self assert: calculatedCount equals: checkCount.
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

	self assert: GtRrWorkerCountCurrentMemoryModel new requiredMemory
		equals: SmalltalkImage current vm memorySize
		within: 0.2.
	self assert: GtRrWorkerCountImageMemoryModel new requiredMemory
		equals: Smalltalk imageFile size.

	calculator := GtRrWorkerCountCalculator new.
	self assert: calculator algorithm identicalTo: GtRrWorkerCountCalculator defaultAlgorithm.
	self assert: calculator minWorkers equals: GtRrWorkerCountCalculator defaultMinWorkers.
	self assert: calculator maxWorkers equals: GtRrWorkerCountCalculator defaultMaxWorkers.
	self assert: calculator memorySizeMultiplier equals: GtRrWorkerCountCalculator defaultMemorySizeMultiplier.
]
