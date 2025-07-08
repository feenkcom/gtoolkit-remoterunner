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
	remoteRunner when: GtRrJobCompletedAnnouncement do: [ :ann | semaphore signal ].
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
	remoteRunner when: GtRrJobCompletedAnnouncement do: [ :ann | semaphore signal ].
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
