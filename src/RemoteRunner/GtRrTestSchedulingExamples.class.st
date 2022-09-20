Class {
	#name : #GtRrTestSchedulingExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrTestSchedulingExamples >> emptyTimes [
	"Answer an empty {{gtClass:GtRrTestSchedulingTimes}} object, confirming that it falls back to the the unknownDurationValue.
	This example assumes {{gtClass:GtRrSampleExample}} exists."
	<gtExample>
	| testSchedulingTimes |

	testSchedulingTimes := GtRrCheckSchedulingTimes new.
	testSchedulingTimes timeStrategy: GtRrTestSchedulingTimeLatestStrategy new.
	self assert: testSchedulingTimes times isEmpty.
	self assert: testSchedulingTimes unknownDurationValue value 
		equals: GtRrTestScheduler defaultTaskDuration.

	^ testSchedulingTimes.
]

{ #category : #accessing }
GtRrTestSchedulingExamples >> timesUpdatedFromExampleJob [
	"Demonstrate updating the persistent times from a {{gtClass:GtRrTasksJob}}"
	<gtExample>
	<noTest>
	| persistentTimes task job initialTime newTime testCaseAnnouncement |

	persistentTimes := self emptyTimes.
	initialTime := persistentTimes timeForClassName: #GtRrSampleExample selector: #passExample.
	self assert: initialTime equals: GtRrTestScheduler defaultTaskDuration.

	task := GtRrExplicitExampleTask exampleNames: { #GtRrSampleExample -> #passExample }.
	job := GtRrChecksJob tasks: { task }.
	persistentTimes onJobStarted: (GtRrJobStartedAnnouncement job: job).
	job runInImage.
	testCaseAnnouncement := job results first result first.
	newTime := testCaseAnnouncement duration.
	self deny: newTime equals: initialTime.
	self assert: (persistentTimes timeForClassName: #GtRrSampleExample selector: #passExample)
		equals: newTime.
]

{ #category : #accessing }
GtRrTestSchedulingExamples >> timesUpdatedFromSUnitJob [
	"Demonstrate updating the persistent times from a {{gtClass:GtRrTasksJob}}"
	<gtExample>
	| persistentTimes task job initialTime newTime testCaseAnnouncement |

	persistentTimes := self emptyTimes.
	initialTime := persistentTimes timeForClassName: #GtRrSampleTest selector: #testPass.
	self assert: initialTime equals: GtRrTestScheduler defaultTaskDuration.

	task := GtRrExplicitSUnitTask sunitTestNames: { #GtRrSampleTest -> #testPass }.
	job := GtRrChecksJob tasks: { task }.
	persistentTimes onJobStarted: (GtRrJobStartedAnnouncement job: job).
	job runInImage.
	testCaseAnnouncement := job results first result first.
	newTime := testCaseAnnouncement duration.
	self deny: newTime equals: initialTime.
	self assert: (persistentTimes timeForClassName: #GtRrSampleTest selector: #testPass)
		equals: newTime.
]
