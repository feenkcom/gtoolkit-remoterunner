Class {
	#name : #GtRrSplitTestExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrSplitTestExamples >> splitClassExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrClassExampleTask}}"
	<gtExample>
	| compoundTask splitTasks taskNames |

	compoundTask := GtRrClassExampleTask exampleClassName: #GtRrSampleExample.
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask group examples
		collect: [ :example | example methodClass name -> example selector ]
		as: Set.

	self assert: splitTasks size equals: 3.
	splitTasks do: [ :splitTask |
		self assert: splitTask constraint identicalTo: compoundTask constraint.
		self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
		self assert: (taskNames includes: splitTask examples first).
		taskNames remove: splitTask examples first ].
	self assert: taskNames isEmpty.

]

{ #category : #accessing }
GtRrSplitTestExamples >> splitExplicitExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrExplicitExampleTask}}"
	<gtExample>
	| compoundTask splitTasks compoundExampleNames |

	compoundTask := GtRrExplicitExampleTask examples:
		{ #GtRrSampleExample -> #passExample }.
	splitTasks := compoundTask splitTests.

	self assert: splitTasks size equals: 1.
	self assert: splitTasks first identicalTo: compoundTask.


	compoundExampleNames := { #GtRrSampleExample -> #passExample.
		#GtRrSampleExample -> #failExample.
		#GtRrSampleExample -> #errorExample. }.
	compoundTask := GtRrExplicitExampleTask examples: compoundExampleNames.
	splitTasks := compoundTask splitTests.

	self assert: splitTasks size equals: 3.
	self assert: (splitTasks flatCollect: #examples) equals: compoundExampleNames.

]

{ #category : #accessing }
GtRrSplitTestExamples >> splitExplicitTests [
	"Demonstrate splitting tests out of a {{gtClass::GtRrExplicitSUnitTask}}"
	<gtExample>
	| compoundTask splitTasks compoundExampleNames |

	compoundTask := GtRrExplicitSUnitTask examples:
		{ #GtRrSampleTest -> #testPass }.
	splitTasks := compoundTask splitTests.

	self assert: splitTasks size equals: 1.
	self assert: splitTasks first identicalTo: compoundTask.


	compoundExampleNames := { #GtRrSampleExample -> #passExample.
		#GtRrSampleExample -> #failExample.
		#GtRrSampleExample -> #errorExample. }.
	compoundTask := GtRrExplicitExampleTask examples: compoundExampleNames.
	splitTasks := compoundTask splitTests.

	self assert: splitTasks size equals: 3.
	self assert: (splitTasks flatCollect: #examples) equals: compoundExampleNames.

]

{ #category : #accessing }
GtRrSplitTestExamples >> splitPackageExamples [
	"Demonstrate splitting examples out of a {{gtClass::GtRrPackageExampleTask}}"
	<gtExample>
	| compoundTask splitTasks taskNames |

	compoundTask := GtRrPackageExampleTask examplePackageName: 'RemoteRunner'.
	splitTasks := compoundTask splitTests.

	taskNames := compoundTask group examples
		collect: [ :example | example methodClass name -> example selector ]
		as: Set.

	splitTasks do: [ :splitTask |
		self assert: splitTask constraint identicalTo: compoundTask constraint.
		self assert: splitTask taskTimeout identicalTo: compoundTask taskTimeout.
		self assert: (taskNames includes: splitTask examples first).
		taskNames remove: splitTask examples first ].
	self assert: taskNames isEmpty.

]
