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
	<return: #GtRrTaskRetryExamples>
	| task tasks |
	task := GtRrExplicitExampleTask
			examples: {#GtRrSampleExample -> #passExample.
					#GtRrSampleExample -> #failExample.
					#GtRrSampleExample -> #errorExample}.
	task retryStrategy: GtRrTaskTestRetry new.
	task
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).	"Default is 2 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each | self assert: each retryStrategy retryCount equals: 1 ].	"Each task will be retried once more"
	tasks
		do: [ :each | 
			task := each.
			task
				executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
			tasks := task retryTasks.
			self assert: tasks size equals: 1.
			task := tasks first.
			self assert: task isNotStarted ].	"Next failure attempt should not retry"
	tasks
		do: [ :each | 
			each
				executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
			tasks := each retryTasks.
			self assert: tasks isEmpty ]
]

{ #category : #examples }
GtRrTaskRetryExamples >> fixedRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskFixedRetry}}"

	<gtExample>
	<return: #GtRrTaskRetryExamples>
	| task tasks |
	task := GtRrExampleValueTask new setError.
	task retryStrategy: GtRrTaskFixedRetry new.	"Default is 2 retries"
	2
		timesRepeat: [ self runCheckTask: task.
			self assert: task isFinished.
			tasks := task retryTasks.
			self assert: tasks size equals: 1.
			task := tasks first.
			self assert: task isNotStarted ].	"Next attempt should not retry"
	tasks := task retryTasks.
	self assert: tasks isEmpty
]

{ #category : #examples }
GtRrTaskRetryExamples >> neverRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskNeverRetry}}"

	<gtExample>
	<return: #GtRrTaskRetryExamples>
	| task |
	task := GtRrScriptTask script: '4+3'.	"Never retry is the default behaviour"
	self assert: task retryStrategy identicalTo: GtRrTaskNeverRetry uniqueInstance.
	self assert: task retryTasks isEmpty
]

{ #category : #'private - helpers' }
GtRrTaskRetryExamples >> runCheckTask: aTask [
	"Run the supplied check task with exception handling"
	| executionContext taskContext |

	taskContext := GtRrWorkerTaskContext new
		task: aTask;
		exceptionHandlingStrategy: GtRrTaskStandaloneExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext.
	executionContext runTask.
]

{ #category : #examples }
GtRrTaskRetryExamples >> testRetry [
	"Demonstrate the behaviour of {{gtClass:GtRrTaskTestRetry}}"

	<gtExample>
	<return: #GtRrTaskRetryExamples>
	| task tasks |
	task := GtRrExplicitSUnitTask
			sunitTestNames: {#GtRrSampleTest -> #testPass.
					#GtRrSampleTest -> #testFail.
					#GtRrSampleTest -> #testError}.
	task retryStrategy: GtRrTaskTestRetry new.
	task
		executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).	"Default is 2 retries, first retry splits the tests out"
	tasks := task retryTasks.
	self assert: tasks size equals: 3.
	tasks do: [ :each | self assert: each retryStrategy retryCount equals: 1 ].	"Each task will be retried once more"
	tasks
		do: [ :each | 
			task := each.
			task
				executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
			tasks := task retryTasks.
			self assert: tasks size equals: 1.
			task := tasks first.
			self assert: task isNotStarted ].	"Third attempt should not retry"
	tasks
		do: [ :each | 
			each
				executionData: (GtRrTaskExecutionData new errorDetails: GtRrErrorDetails new).
			tasks := each retryTasks.
			self assert: tasks isEmpty ]
]
