Class {
	#name : #GtRrTaskRetryExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskRetryExamples >> exampleRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskTestRetry}} on a Gt Example class"
	<gtExample>
	| task tasks |

	task := GtRrExplicitExampleTask examples:
		{ #GtRrSampleExample -> #testPass.
		#GtRrSampleExample -> #testFail.
		#GtRrSampleExample -> #testError. }.
	task retryStrategy: GtRrTaskTestRetry new.

	"Default is 2 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each |
		self assert: each retryStrategy retryCount equals: 1 ].

	"Each task will be retried once more"
	tasks do: [ :each |
		task := each.
		tasks := task retryTasks.
		self assert: tasks size equals: 1.
		task := tasks first.
		self assert: task isNotStarted ].

	"Next failure attempt should not retry"
	tasks do: [ :each |
		tasks := each retryTasks.
		self assert: tasks isEmpty ].
]

{ #category : #examples }
GtRrTaskRetryExamples >> fixedRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskFixedRetry}}"
	<gtExample>
	| task tasks |

	task := GtRrExampleValueTask new.
	task retryStrategy: GtRrTaskFixedRetry new.
	"Default is 2 retries"
	2 timesRepeat: 
		[ task runInImage.
		self assert: task isFinished.
		tasks := task retryTasks.
		self assert: tasks size equals: 1.
		task := tasks first.
		self assert: task isNotStarted ].
	"Next attempt should not retry"
	tasks := task retryTasks.
	self assert: tasks isEmpty.
]

{ #category : #examples }
GtRrTaskRetryExamples >> neverRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskNeverRetry}}"
	<gtExample>
	| task |

	task := GtRrScriptTask script: '4+3'.
	"Never retry is the default behaviour"
	self assert: task retryStrategy identicalTo: GtRrTaskNeverRetry uniqueInstance.
	self assert: task retryTasks isEmpty.
]

{ #category : #examples }
GtRrTaskRetryExamples >> testRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskTestRetry}}"
	<gtExample>
	| task tasks |

	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testPass.
		#GtRrSampleTest -> #testFail.
		#GtRrSampleTest -> #testError. }.
	task retryStrategy: GtRrTaskTestRetry new.

	"Default is 2 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each |
		self assert: each retryStrategy retryCount equals: 1 ].

	"Each task will be retried once more"
	tasks do: [ :each |
		task := each.
		tasks := task retryTasks.
		self assert: tasks size equals: 1.
		task := tasks first.
		self assert: task isNotStarted ].

	"Third attempt should not retry"
	tasks do: [ :each |
		tasks := each retryTasks.
		self assert: tasks isEmpty ].
]
