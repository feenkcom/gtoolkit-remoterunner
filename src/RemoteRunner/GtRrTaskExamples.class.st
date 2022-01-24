Class {
	#name : #GtRrTaskExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskExamples >> timeout [

	"Demonstrate the use of task timeouts"

	<gtExample>
	| runner job task |
	runner := GtRrScheduler new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new
		       tasks: { task };
		       scheduler: runner;
		       yourself.
	self assert: task timeout equals: 1 minute.

	runner timeout: runner timeout + 1 minute.
	self assert: task timeout equals: runner timeout.

	job timeout: runner timeout + 1 minute.
	self assert: task timeout equals: job timeout.

	task timeout: job timeout + 1 minute.
	self assert: task timeout equals: task timeout
]
