Class {
	#name : #GtRrTaskRetryExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrTaskRetryExamples >> exampleRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskTestRetry}} on a Gt Example class"
	<gtExample>
	| task tasks |

	task := GtRrExplicitExampleTask examples:
		{ #GtRrSampleExample -> #testPass.
		#GtRrSampleExample -> #testFail.
		#GtRrSampleExample -> #testError. }.
	task retryStrategy: GtRrTaskTestRetry new.

	"Default is 3 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each |
		self assert: each retryStrategy retryCount equals: 1 ].

	"Each task will be retried twice more"
	tasks do: [ :each |
		task := each.
		2 timesRepeat: 
			[ tasks := task retryTasks.
			self assert: tasks size equals: 1.
			task := tasks first.
			self assert: task isNotStarted ] ].

	"Third attempt should not retry"
	tasks do: [ :each |
		tasks := each retryTasks.
		self assert: tasks isEmpty ].
]

{ #category : #accessing }
GtRrTaskRetryExamples >> fixedRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskFixedRetry}}"
	<gtExample>
	| task tasks |

	task := GtRrExampleValueTask new.
	task retryStrategy: GtRrTaskFixedRetry new.
	"Default is 3 retries"
	3 timesRepeat: 
		[ task runInImage.
		self assert: task isFinished.
		tasks := task retryTasks.
		self assert: tasks size equals: 1.
		task := tasks first.
		self assert: task isNotStarted ].
	"Fourth attempt should not retry"
	tasks := task retryTasks.
	self assert: tasks isEmpty.
]

{ #category : #accessing }
GtRrTaskRetryExamples >> neverRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskNeverRetry}}"
	<gtExample>
	| task |

	task := GtRrScriptTask script: '4+3'.
	"Never retry is the default behaviour"
	self assert: task retryStrategy identicalTo: GtRrTaskNeverRetry uniqueInstance.
	self assert: task retryTasks isEmpty.
]

{ #category : #accessing }
GtRrTaskRetryExamples >> testRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskTestRetry}}"
	<gtExample>
	| task tasks |

	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testPass.
		#GtRrSampleTest -> #testFail.
		#GtRrSampleTest -> #testError. }.
	task retryStrategy: GtRrTaskTestRetry new.

	"Default is 3 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each |
		self assert: each retryStrategy retryCount equals: 1 ].

	"Each task will be retried twice more"
	tasks do: [ :each |
		task := each.
		2 timesRepeat: 
			[ tasks := task retryTasks.
			self assert: tasks size equals: 1.
			task := tasks first.
			self assert: task isNotStarted ] ].

	"Third attempt should not retry"
	tasks do: [ :each |
		tasks := each retryTasks.
		self assert: tasks isEmpty ].
]
