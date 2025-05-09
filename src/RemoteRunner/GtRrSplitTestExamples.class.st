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
	| compoundTask splitTasks taskNames |
	compoundTask := GtRrClassExampleTask exampleClassName: #GtRrSampleExample.
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask group examples
			collect: [ :example | example methodClass name -> example selector ]
			as: Set.	"Tasks without errors don't split"
	self assert: splitTasks size equals: 0.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.
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
	| compoundTask splitTasks taskNames |
	compoundTask := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask allExamples
			collect: [ :testCase | testCase class name -> testCase selector ]
			as: Set.	"Tasks without errors don't split"
	self assert: splitTasks size equals: 0.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.
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
	| compoundTask splitTasks compoundExampleNames |
	compoundTask := GtRrExplicitExampleTask
			examples: {#GtRrSampleExample -> #passExample}.
	splitTasks := compoundTask splitTests.	"Tasks without errors don't split"
	self assert: splitTasks size equals: 0.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.
	self assert: splitTasks size equals: 1.

	compoundExampleNames := {#GtRrSampleExample -> #passExample.
			#GtRrSampleExample -> #failExample.
			#GtRrSampleExample -> #errorExample}.
	compoundTask := GtRrExplicitExampleTask examples: compoundExampleNames.
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.

	self assert: splitTasks size equals: 3.
	self assert: (splitTasks flatCollect: #examples) equals: compoundExampleNames
]

{ #category : #examples }
GtRrSplitTestExamples >> splitExplicitTests [
	"Demonstrate splitting tests out of a {{gtClass::GtRrExplicitSUnitTask}}.
	WIP"

	<gtExample>
	<return: #GtRrSplitTestExamples>
	| compoundTask splitTasks compoundTestNames |
	compoundTask := GtRrExplicitSUnitTask
			sunitTestNames: {#GtRrSampleTest -> #testPass}.
	splitTasks := compoundTask splitTests.	"Tasks without errors don't split"
	self assert: splitTasks size equals: 0.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.
	self assert: splitTasks size equals: 1.

	compoundTestNames := {#GtRrSampleExample -> #passExample.
			#GtRrSampleExample -> #failExample.
			#GtRrSampleExample -> #errorExample}.
	compoundTask := GtRrExplicitSUnitTask sunitTestNames: compoundTestNames.
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.

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
	| compoundTask splitTasks taskNames |
	compoundTask := GtRrPackageExampleTask examplePackageName: 'RemoteRunner'.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask group examples
			collect: [ :example | example methodClass name -> example selector ]
			as: Set.

	splitTasks
		do: [ :splitTask | 
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
	| compoundTask splitTasks taskNames |
	compoundTask := GtRrPackageSUnitTask sunitPackageName: 'RemoteRunner'.	"The presence of error details is enough to trigger the split"
	compoundTask
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask allExamples
			collect: [ :test | test class name -> test selector ]
			as: Set.

	splitTasks
		do: [ :splitTask | 
			self assert: splitTask constraint identicalTo: compoundTask constraint.
			self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
			self assert: splitTask sunitTestNames size equals: 1.
			self assert: (taskNames includes: splitTask sunitTestNames first).
			taskNames remove: splitTask sunitTestNames first ].
	self assert: taskNames isEmpty
]
