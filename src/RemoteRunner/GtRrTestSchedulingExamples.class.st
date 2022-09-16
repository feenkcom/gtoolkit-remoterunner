Class {
	#name : #GtRrTestSchedulingExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrTestSchedulingExamples >> emptyTimes [
	"Answer an empty {{gtClass:GtRrTestSchedulingTimes}} object, confirming that it falls back to the the unknownDurationValue.
	This example assumes {{gtClass:GtRrSampleExample}} exists."
	<gtExample>
	| testSchedulingTimes |

	testSchedulingTimes := GtRrTestSchedulingTimes new.
	self assert: testSchedulingTimes times isEmpty.
	self assert: testSchedulingTimes unknownDurationValue value 
		equals: GtRrTestScheduler defaultTaskDuration.

	^ testSchedulingTimes.
]

{ #category : #accessing }
GtRrTestSchedulingExamples >> timesUpdatedFromJob [
	"Demonstrate updating the persistent times from a {{gtClass:GtRrTasksJob}}"
	<gtExample>
	<noTest>
	| persistentTimes task job now initialTime newTime |

	persistentTimes := self emptyTimes.
	initialTime := persistentTimes timeForClassName: #GtRrSampleExample selector: #passExample.
	self assert: initialTime equals: GtRrTestScheduler defaultTaskDuration.
	now := DateAndTime now.
	newTime := now + initialTime + 3 seconds.
	task := GtRrExplicitExampleTask new.
	task result: { (PharoLinkTestCasePass new
		initializeTestCaseClassName: #GtRrSampleExample selector: #passExample)
				testCaseStartTimestamp: now;
				testCaseEndTimestamp: newTime }.
	job := GtRrChecksJob new.
	job addResult: task.
	persistentTimes updateFromJob: job.
	self assert: (persistentTimes timeForClassName: #GtRrSampleExample selector: #passExample)
		equals: newTime.
]
