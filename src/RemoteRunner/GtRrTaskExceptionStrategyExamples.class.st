"
Demonstrate behaviour of the various exception handling strategies used by the RemoteRunner worker.
"
Class {
	#name : #GtRrTaskExceptionStrategyExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> debuggingStrategyHandleError [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExampleValueTask new
		setError;
		value: #error.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		worker: worker.
	self
		should: [ strategy
			runTask: taskContext
			inContext: executionContext ]
		raise: Error 
		description: 'Error expected'.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> debuggingStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrScriptTask script: 'self halt'.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		worker: worker.
	self
		should: [ strategy
			runTask: taskContext
			inContext: executionContext ]
		raise: Halt
		description: 'Halt expected'.
	self assert: worker messages isEmpty.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> headlessStrategyHandleError [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExampleValueTask new
		setError;
		value: #error.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		worker: worker.
	self
		shouldnt: [ strategy
			runTask: taskContext
			inContext: executionContext ]
		raise: Error 
		description: 'Error expected'.
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> headlessStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrScriptTask script: 'self halt'.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		worker: worker.
	self
		shouldnt: [ strategy
			runTask: taskContext
			inContext: executionContext ]
		raise: Halt
		description: 'Halt expected'.
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]
