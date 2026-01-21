Class {
	#name : #GtRrCheckSchedulingExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : 'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrCheckSchedulingExamples >> emptyTimes [
	"Answer an empty {{gtClass:GtRrTestSchedulingTimes}} object, confirming that it falls back to the the unknownDurationValue.
	This example assumes {{gtClass:GtRrSampleExample}} exists."

	<gtExample>
	<return: #GtRrCheckSchedulingTimes>
	| testSchedulingTimes |
	testSchedulingTimes := GtRrCheckSchedulingTimes new.
	testSchedulingTimes timeStrategy: GtRrCheckSchedulingTimeLatestStrategy new.
	self assert: testSchedulingTimes times isEmpty.
	self
		assert: testSchedulingTimes unknownDuration defaultValue
		equals: GtRrCheckScheduler defaultTaskDuration.

	^ testSchedulingTimes
]

{ #category : #examples }
GtRrCheckSchedulingExamples >> scheduleSampleExamples [
	<gtExample>
	<return: #OrderedCollection>
	| schedulingTimes scheduler tasks |
	schedulingTimes := self emptyTimes.
	schedulingTimes
		atClassName: #GtRrSampleExample
			selector: #passExample
			add: 20 seconds
			endTime: DateAndTime now;
		atClassName: #GtRrSampleExample
			selector: #failExample
			add: 1 second
			endTime: DateAndTime now;
		atClassName: #GtRrSampleExample
			selector: #errorExample
			add: 2 seconds
			endTime: DateAndTime now.

	scheduler := GtRrCheckScheduler new schedulingTimes: schedulingTimes.

	tasks := scheduler
			allocateTasks: {GtRrClassExampleTask exampleClassName: #GtRrSampleExample}.

	self assert: tasks size equals: 4.
	tasks do: [ :task | self assert: task checkNames size equals: 1 ].

	^ tasks
]

{ #category : #examples }
GtRrCheckSchedulingExamples >> timesUpdatedFromExampleJob [
	"Demonstrate updating the persistent times from a {{gtClass:GtRrTasksJob}}"

	<gtExample>
	<return: #GtRrCheckSchedulingExamples>
	| persistentTimes task job initialTime newTime testCaseAnnouncement |
	persistentTimes := self emptyTimes.
	initialTime := persistentTimes
			timeForClassName: #GtRrSampleExample
			selector: #passExample.
	self assert: initialTime equals: GtRrCheckScheduler defaultTaskDuration.

	task := GtRrExplicitExampleTask
			exampleNames: {#GtRrSampleExample -> #passExample}.
	job := GtRrChecksJob tasks: {task}.
	persistentTimes onJobStarted: (GtRrJobStartedAnnouncement job: job).
	job runInImage.
	testCaseAnnouncement := job results first result first.
	newTime := testCaseAnnouncement duration.
	self deny: newTime equals: initialTime.
	self
		assert: (persistentTimes timeForClassName: #GtRrSampleExample selector: #passExample)
		equals: newTime
]

{ #category : #examples }
GtRrCheckSchedulingExamples >> timesUpdatedFromSUnitJob [
	"Demonstrate updating the persistent times from a {{gtClass:GtRrTasksJob}}"

	<gtExample>
	<return: #GtRrCheckSchedulingExamples>
	| persistentTimes task job initialTime newTime testCaseAnnouncement |
	persistentTimes := self emptyTimes.
	initialTime := persistentTimes
			timeForClassName: #GtRrSampleTest
			selector: #testPass.
	self assert: initialTime equals: GtRrCheckScheduler defaultTaskDuration.

	task := GtRrExplicitSUnitTask sunitTestNames: {#GtRrSampleTest -> #testPass}.
	job := GtRrChecksJob tasks: {task}.
	persistentTimes onJobStarted: (GtRrJobStartedAnnouncement job: job).
	job runInImage.
	testCaseAnnouncement := job results first result first.
	newTime := testCaseAnnouncement duration.
	self deny: newTime equals: initialTime.
	self
		assert: (persistentTimes timeForClassName: #GtRrSampleTest selector: #testPass)
		equals: newTime
]
