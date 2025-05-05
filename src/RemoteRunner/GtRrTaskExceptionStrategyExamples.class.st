"
Demonstrate behaviour of the various exception handling strategies used by the RemoteRunner worker.
"
Class {
	#name : #GtRrTaskExceptionStrategyExamples,
	#superclass : #Object,
	#traits : 'TAssertable + TGtRrExampleHelp',
	#classTraits : 'TAssertable classTrait + TGtRrExampleHelp classTrait',
	#instVars : [
		'remoteRunner',
		'worker'
	],
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> debuggerStrategyHandleError [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExampleValueTask new
			setError;
			value: #error.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		should: [ executionContext runTask ]
		raise: Error
		description: 'Error expected'.
	Processor yield.
	self assert: worker messages first selector equals: #taskFailed:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> debuggerStrategyHandleHalt [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrScriptTask script: 'self halt'.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		should: [ executionContext runTask ]
		raise: Halt
		description: 'Halt expected'.
	self assert: worker messages isEmpty
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> gtExampleDebuggerStrategyHandleError [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitExampleTask examples: {#GtRrSampleExample -> #errorExample}.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Error
		description: 'Error signalled'.	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector equals: #taskDone:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> gtExampleDebuggerStrategyHandleHalt [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitExampleTask examples: {#GtRrSampleExample -> #haltExample}.
	task setIgnoreNoTest.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		should: [ executionContext runTask ]
		raise: Halt
		description: 'Halt expected'.
	self assert: worker messages isEmpty
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> headlessStrategyHandleError [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExampleValueTask new
			setError;
			value: #error.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Error
		description: 'Error expected'.
	self assert: worker messages first selector equals: #taskFailed:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> headlessStrategyHandleHalt [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrScriptTask script: 'self halt'.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Halt
		description: 'Halt signalled'.
	self assert: worker messages first selector equals: #taskFailed:with:
]

{ #category : #private }
GtRrTaskExceptionStrategyExamples >> stopRunner [

	worker ifNotNil: [ worker stop ].
	worker := nil.
	remoteRunner ifNotNil: [ remoteRunner stop ].
	remoteRunner := nil.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitDebuggerStrategyHandleError [
	<gtExample>
	<return: #TestFailure>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames: {#GtRrSampleTest -> #testError}.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			worker: worker.
	self
		shouldnt: [ strategy runTask: taskContext inContext: executionContext ]
		raise: Error
		description: 'Error signalled'.	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector equals: #taskDone:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitDebuggerStrategyHandleHalt [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames: {#GtRrSampleTest -> #testHalt}.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	EpMonitor
		disableDuring: [ GtRrSampleTest
				compile: 'testHalt
	self halt. '
				classified: #test.
			self
				should: [ executionContext runTask ]
				raise: Halt
				description: 'Halt expected'.
			GtRrSampleTest removeSelector: #testHalt ].
	Processor yield.
	self assert: worker messages first selector equals: #taskFailed:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitHeadlessStrategyHandleError [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames: {#GtRrSampleTest -> #testError}.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Error
		description: 'Error signalled'.	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector equals: #taskDone:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitHeadlessStrategyHandleHalt [
	<gtExample>
	<return: #GtRrTaskExceptionStrategyExamples>
	| strategy task taskContext executionContext worker |
	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames: {#GtRrSampleTest -> #testHalt}.
	taskContext := GtRrTaskContext new task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
			taskContext: taskContext;
			exceptionHandlingStrategy: strategy;
			worker: worker.
	EpMonitor
		disableDuring: [ GtRrSampleTest
				compile: 'testHalt
	self halt. '
				classified: #test.
			self
				shouldnt: [ executionContext runTask ]
				raise: Halt
				description: 'Halt signalled'.
			GtRrSampleTest removeSelector: #testHalt ].	"The SUnit test execption handling doesn't catch halts,
	it is caught by the task exeception handling, so the task fails."
	self assert: worker messages first selector equals: #taskFailed:with:
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> taskWithDebuggerExceptionHandling [
	"Demonstrate running an SUnit test in a task"

	<gtExample>
	<after: #stopRunner>
	<return: #GtRrScriptTask>
	| task job semaphore |
	remoteRunner := GtRemoteRunner new
			port: #none;
			start.
	worker := remoteRunner managerStartupAndShutdown startInImageWorker.
	semaphore := Semaphore new.
	remoteRunner when: GtRrJobCompletedAnnouncement do: [ :ann | semaphore signal ].
	task := GtRrScriptTask
			script: '[ 1 / 0 ]
	on: UnhandledException
	do: [ :ex | #handled ]'.
	job := task asJob.
	job exceptionHandlingStrategy: GtRrTaskDebuggerExceptionStrategy new.
	remoteRunner submitJob: job.
	self
		waitOn: semaphore
		for: 30
		description: 'Job didn''t complete in time'.
	self deny: job hasErrors.
	self assert: task result equals: #handled.
	remoteRunner stop.
	^ task
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> taskWithHeadlessExceptionHandling [
	"Demonstrate running an SUnit test in a task"

	<gtExample>
	<after: #stopRunner>
	<return: #GtRrScriptTask>
	| task job semaphore |
	remoteRunner := GtRemoteRunner new
			port: #none;
			start.
	worker := remoteRunner managerStartupAndShutdown startInImageWorker.
	worker exceptionHandlingStrategy: GtRrTaskHeadlessExceptionStrategy new.
	semaphore := Semaphore new.
	remoteRunner when: GtRrJobCompletedAnnouncement do: [ :ann | semaphore signal ].
	task := GtRrScriptTask
			script: '[ 1 / 0 ]
	on: UnhandledException
	do: [ :ex | #handled ]'.
	job := remoteRunner submitJob: task asJob.
	self
		waitOn: semaphore
		for: 30
		description: 'Job didn''t complete in time'.
	self assert: job hasErrors.
	self assert: task hasErrors.
	self assert: task result isNil.
	self assert: task errorDetails errorMessage equals: 'ZeroDivide'.
	remoteRunner stop.
	^ task
]
