Class {
	#name : #GtRrTaskExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTaskExamples >> compoundTask [
	"Demonstrate creating nested tasks and analysing the results"
	<gtExample>
	| tasks subTask compoundTask visitor results |

	tasks := (1 to: 5) collect: [ :i |
		GtRrScriptTask script: i printString ].
	subTask := GtRrCompoundTask tasks: (tasks copyFrom: 1 to: 3).
	compoundTask := GtRrCompoundTask tasks: { 
		subTask.
		tasks at: 4.
		tasks at: 5. }.
	compoundTask runInImage.
	results := OrderedCollection new.
	visitor := GtRrAllTasksVisitor visitBlock: [ :task | results add: task result ].
	compoundTask acceptVisitor: visitor.
	self assert: results asArray equals: #(1 2 3 4 5).
	^ compoundTask.
]

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
