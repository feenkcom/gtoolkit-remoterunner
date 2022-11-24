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
GtRrTaskExceptionStrategyExamples >> debuggerStrategyHandleError [
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
		exceptionStrategy: strategy;
		worker: worker.
	self
		should: [ executionContext runTask ]
		raise: Error 
		description: 'Error expected'.
	Processor yield.
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> debuggerStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrScriptTask script: 'self halt'.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	self
		should: [ executionContext runTask ]
		raise: Halt
		description: 'Halt expected'.
	self assert: worker messages isEmpty.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> gtExampleDebuggerStrategyHandleError [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitExampleTask examples:
		{ #GtRrSampleExample -> #errorExample }.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Error 
		description: 'Error signalled'.
	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector
		equals: #taskDone:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> gtExampleDebuggerStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitExampleTask examples:
		{ #GtRrSampleExample -> #haltExample }.
	task setIgnoreNoTest.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	self
		should: [ executionContext runTask ]
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
		exceptionStrategy: strategy;
		worker: worker.
	self
		shouldnt: [ executionContext runTask ]
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
		exceptionStrategy: strategy;
		worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Halt
		description: 'Halt signalled'.
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitDebuggerStrategyHandleError [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testError }.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		worker: worker.
	self
		shouldnt: [ strategy
			runTask: taskContext
			inContext: executionContext ]
		raise: Error 
		description: 'Error signalled'.
	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector
		equals: #taskDone:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitDebuggerStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testHalt }.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskDebuggerExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	EpMonitor disableDuring:
		[ GtRrSampleTest compile:
'testHalt
	self halt. '
			classified: #test.
		self
			should: [ executionContext runTask ]
			raise: Halt 
			description: 'Halt expected'.
		GtRrSampleTest removeSelector: #testHalt. ].
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitHeadlessStrategyHandleError [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testError }.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	self
		shouldnt: [ executionContext runTask ]
		raise: Error 
		description: 'Error signalled'.
	"While the test will be marked failed, the task should succeed"
	self assert: worker messages first selector
		equals: #taskDone:with:.
]

{ #category : #examples }
GtRrTaskExceptionStrategyExamples >> sunitHeadlessStrategyHandleHalt [
	<gtExample>
	| strategy task taskContext executionContext worker |

	worker := GtRrExamplesMessageRecorder new.
	task := GtRrExplicitSUnitTask sunitTestNames:
		{ #GtRrSampleTest -> #testHalt }.
	taskContext := GtRrTaskContext new
		task: task.
	strategy := GtRrTaskHeadlessExceptionStrategy new.
	executionContext := GtRrWorkerExecutionContext new
		taskContext: taskContext;
		exceptionStrategy: strategy;
		worker: worker.
	EpMonitor disableDuring:
		[ GtRrSampleTest compile:
'testHalt
	self halt. '
			classified: #test.
		self
			shouldnt: [ executionContext runTask ]
			raise: Halt 
			description: 'Halt signalled'.
		GtRrSampleTest removeSelector: #testHalt. ].
	"The SUnit test execption handling doesn't catch halts,
	it is caught by the task exeception handling, so the task fails."
	self assert: worker messages first selector
		equals: #taskFailed:with:.
]
