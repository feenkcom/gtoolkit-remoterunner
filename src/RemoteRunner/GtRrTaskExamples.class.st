Class {
	#name : #GtRrTaskExamples,
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
GtRrTaskExamples >> compoundTask [
	"Demonstrate creating nested tasks and analysing the results"

	<gtExample>
	<return: #GtRrCompoundTask>
	| tasks subTask compoundTask visitor results |
	tasks := (1 to: 5) collect: [ :i | GtRrScriptTask script: i printString ].
	subTask := GtRrCompoundTask tasks: (tasks copyFrom: 1 to: 3).
	compoundTask := GtRrCompoundTask
			tasks: {subTask.
					tasks at: 4.
					tasks at: 5}.
	compoundTask runInImage.
	results := OrderedCollection new.
	visitor := GtRrAllTasksVisitor visitBlock: [ :task | results add: task result ].
	visitor visitNode: compoundTask.
	self assert: results asArray equals: #(1 2 3 4 5).
	^ compoundTask
]

{ #category : #examples }
GtRrTaskExamples >> pharoDebugLogInspector [
	"Answer a GtPharoDebugLogInspector for a task with errors"
	<gtExample>

	^ (GtPharoDebugLogInspector new string: 
		self taskWithErrorTrace executionData errorDetails trace) 
			parseLogEntries first.
]

{ #category : #examples }
GtRrTaskExamples >> runInImageTask: aGrRrTask [
	"Run the supplied task and answer it"
	<gtExample>
	| runner semaphore |

	runner := GtRemoteRunner new.
	semaphore := Semaphore new.
	runner managerStartupAndShutdown: GtRrManualManagerStartupAndShutdown new.
	runner start.
	runner managerStartupAndShutdown startInImageWorker.
	runner when: GtRrJobCompletedAnnouncement
		do: [ :ann | semaphore signal ]
		for: self.
	runner submitJob: aGrRrTask asJob.
	(semaphore waitTimeoutSeconds: 30) ifTrue:
		[ self error: 'Job failed to complete in time' ].
	runner stop.

	^ aGrRrTask.
]

{ #category : #private }
GtRrTaskExamples >> stopRunner [

	worker ifNotNil: [ worker stop ].
	worker := nil.
	remoteRunner ifNotNil: [ remoteRunner stop ].
	remoteRunner := nil.
]

{ #category : #examples }
GtRrTaskExamples >> sunitTask [
	"Demonstrate running an SUnit test in a task"

	<gtExample>
	<return: #GtRrClassSUnitTask>
	| task job semaphore |
		
	remoteRunner := GtRemoteRunner new
			port: #none;
			start.
	worker := remoteRunner managerStartupAndShutdown startInImageWorker.
	worker exceptionHandlingStrategy: GtRrTaskHeadlessExceptionStrategy new.
	semaphore := Semaphore new.
	remoteRunner 
		when: GtRrJobCompletedAnnouncement 
		do: [ :ann | semaphore signal ]
		for: self.
	task := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.
	job := remoteRunner submitJob: task asJob.
	self
		waitOn: semaphore
		for: 30
		description: 'Job didn''t complete in time'.
	self assert: task executionData resourceReport isNotNil.
	task result do: [ :each | self assert: each resourceReport isNotNil ].
	^ task
]

{ #category : #examples }
GtRrTaskExamples >> taskResourceReport [
	"Confirm that tasks collect GC data on the execution"

	<gtExample>
	<return: #GtRrScriptTask>
	| task job semaphore |
	remoteRunner := GtRemoteRunner new.
	worker := GtRrInImageWorker new
			remoteRunner: remoteRunner;
			start.
	semaphore := Semaphore new.
	remoteRunner 
		when: GtRrJobCompletedAnnouncement 
		do: [ :ann | semaphore signal ]
		for: self.
	task := GtRrScriptTask
			script: '| times |
times := OrderedCollection new.
times add: GtVirtualMachine instance totalGCTimeMicroseconds.
[ times add: GtVirtualMachine instance totalGCTimeMicroseconds.
times last = times first ] whileTrue.
{ times first. times last. times size. }'.
	job := remoteRunner submitJob: task asJob.
	self
		waitOn: semaphore
		for: 10
		description: 'Job didn''t complete in time'.
	self assert: task executionData resourceReport isNotNil.
	^ task
]

{ #category : #examples }
GtRrTaskExamples >> taskTimeout [
	"Demonstrate the use of task timeouts"

	<gtExample>
	<return: #GtRrTaskExamples>
	| runner job task jobContext taskContext |
	runner := GtRemoteRunner new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new tasks: {task}.
	jobContext := GtRrJobContext new
			job: job;
			remoteRunner: runner.
	taskContext := GtRrTaskContext new
			jobContext: jobContext;
			task: task.

	self assert: taskContext taskTimeout equals: runner defaultTaskTimeout.

	runner taskTimeout: runner defaultTaskTimeout + 1 minute.
	self assert: taskContext taskTimeout equals: runner taskTimeout.

	job taskTimeout: runner taskTimeout + 1 minute.
	self assert: taskContext taskTimeout equals: job taskTimeout.

	task taskTimeout: job taskTimeout + 1 minute.
	self assert: taskContext taskTimeout equals: task taskTimeout
]

{ #category : #examples }
GtRrTaskExamples >> taskWithCustomMemoryLogger [
	"Answer the MemoryLogger collected as part of a task prePostAction"
	<gtExample>
	| task logger |

	task := self taskWithPrePostAction.
	self runInImageTask: task.

	logger := STON fromString: (task executionData additionalData at: #logger).
	self assert: logger recordings size equals: 1.
	^ logger.
]

{ #category : #examples }
GtRrTaskExamples >> taskWithErrorTrace [
	"Answer a task that raised an error during execution"
	<gtExample>
	| errorMessage task |

	errorMessage := 'error during task execution'.
	task := GtRrScriptTask script: 'self error: ', errorMessage printString.
	self runInImageTask: task.

	self assert: task result isNil
		description: 'Task has unexpected result'.
	self assert: task executionData errorDetails errorMessage
		equals: errorMessage.
	^ task.
]

{ #category : #examples }
GtRrTaskExamples >> taskWithPrePostAction [
	"Answer a task that has a pre- and post- action set"
	<gtExample>
	| task |

	task := GtRrScriptTask script: 'MethodStackSignal emit'.
	task prePostTaskActions: #(GtRrMemoryLoggerPrePostTaskAction).
	^ task.
]
