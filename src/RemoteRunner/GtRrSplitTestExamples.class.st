Class {
	#name : #GtRrSplitTestExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSplitTestExamples >> splitClassExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrClassExampleTask}}"
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks taskNames taskContext |

	compoundTask := GtRrClassExampleTask exampleClassName: #GtRrSampleExample.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks isEmpty.

	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskNames := compoundTask group examples
			collect: [ :example | example methodClass name -> example selector ]
			as: Set.	"Tasks without errors don't split"
	"The presence of error details is enough to trigger the split"
	compoundTask executionData: (GtRrTaskExecutionData new 
		errorDetails: GtRrErrorDetails new).
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 4.

	splitTasks
		do: [ :splitTask | 
			self assert: splitTask constraint identicalTo: compoundTask constraint.
			self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
			self assert: (taskNames includes: splitTask examples first).
			taskNames remove: splitTask examples first ].
	self assert: taskNames isEmpty
]

{ #category : #examples }
GtRrSplitTestExamples >> splitClassTests [
	"Demonstrate splitting tests out of a {{gtClass::GtRrClassSUnitTask}}"
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks taskNames taskContext |

	compoundTask := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 0.

	"The presence of error details is enough to trigger the split"
	compoundTask := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.
	taskContext := GtRrTaskContext new task: compoundTask.
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskNames := compoundTask allExamples
			collect: [ :testCase | testCase class name -> testCase selector ]
			as: Set.	"Tasks without errors don't split"
	compoundTask executionData: (GtRrTaskExecutionData new 
		errorDetails: GtRrErrorDetails new).
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 4.

	splitTasks
		do: [ :splitTask | 
			self assert: splitTask constraint identicalTo: compoundTask constraint.
			self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
			self assert: splitTask sunitTestNames size equals: 1.
			self assert: (taskNames includes: splitTask sunitTestNames first).
			taskNames remove: splitTask sunitTestNames first ].
	self assert: taskNames isEmpty
]

{ #category : #examples }
GtRrSplitTestExamples >> splitExplicitExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrExplicitExampleTask}}"
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks compoundExampleNames taskContext |

	compoundTask := GtRrExplicitExampleTask
			examples: {#GtRrSampleExample -> #passExample}.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 0.	"The presence of error details is enough to trigger the split"

	compoundTask := GtRrExplicitExampleTask
			examples: {#GtRrSampleExample -> #passExample}.
	compoundTask executionData: (GtRrTaskExecutionData new 
		errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 1.

	compoundExampleNames := {#GtRrSampleExample -> #passExample.
			#GtRrSampleExample -> #failExample.
			#GtRrSampleExample -> #errorExample}.
	compoundTask := GtRrExplicitExampleTask examples: compoundExampleNames.
	compoundTask executionData: (GtRrTaskExecutionData new 
		errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 3.
	self assert: (splitTasks flatCollect: #examples) equals: compoundExampleNames
]

{ #category : #examples }
GtRrSplitTestExamples >> splitExplicitTests [
	"Demonstrate splitting tests out of a {{gtClass::GtRrExplicitSUnitTask}}."
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks compoundTestNames taskContext |

	compoundTask := GtRrExplicitSUnitTask
			sunitTestNames: {#GtRrSampleTest -> #testPass}.
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 0.

	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: 1.

	compoundTestNames := {#GtRrSampleExample -> #passExample.
			#GtRrSampleExample -> #failExample.
			#GtRrSampleExample -> #errorExample}.
	compoundTask := GtRrExplicitSUnitTask sunitTestNames: compoundTestNames.
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.

	self assert: splitTasks size equals: 3.
	self
		assert: (splitTasks flatCollect: #sunitTestNames)
		equals: compoundTestNames
]

{ #category : #examples }
GtRrSplitTestExamples >> splitPackageExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrPackageExampleTask}}"
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks taskNames taskContext |

	compoundTask := GtRrPackageExampleTask examplePackageName: 'RemoteRunner'.
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	self assert: splitTasks size equals: compoundTask allExamples size.

	taskNames := compoundTask group examples
			collect: [ :example | example methodClass name -> example selector ]
			as: Set.
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	splitTasks do: [ :splitTask | 
		self assert: splitTask constraint identicalTo: compoundTask constraint.
		self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
		self assert: (taskNames includes: splitTask examples first).
		taskNames remove: splitTask examples first ].
	self assert: taskNames isEmpty
]

{ #category : #examples }
GtRrSplitTestExamples >> splitPackageTests [
	"Demonstrate splitting examples out of a {{gtClass::GtRrPackageSUnitTask}}"
	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks taskNames taskContext |

	compoundTask := GtRrPackageSUnitTask sunitPackageName: 'RemoteRunner'.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.

	taskNames := compoundTask allExamples
			collect: [ :test | test class name -> test selector ]
			as: Set.
	compoundTask retryStrategy: GtRrTaskTestRetry new.
	taskContext := GtRrTaskContext new task: compoundTask.
	splitTasks := taskContext retryTasks.
	splitTasks do: [ :splitTask | 
		self assert: splitTask constraint identicalTo: compoundTask constraint.
		self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
		self assert: splitTask sunitTestNames size equals: 1.
		self assert: (taskNames includes: splitTask sunitTestNames first).
		taskNames remove: splitTask sunitTestNames first ].
	self assert: taskNames isEmpty
]
