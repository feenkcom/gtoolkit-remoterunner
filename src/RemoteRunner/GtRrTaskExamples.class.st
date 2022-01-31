Class {
	#name : #GtRrTaskExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskExamples >> taskTimeout [
	"Demonstrate the use of task timeouts"
	<gtExample>
	| runner job task jobContext taskContext |

	runner := GtRemoteRunner new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new tasks: { task }.
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
	self assert: taskContext taskTimeout equals: task taskTimeout.
]
