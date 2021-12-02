Class {
	#name : #GtRrSchedulerExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSchedulerExamples >> scheduleTestsOneAtATime [
	"Demonstrate scheduling tests one at a time"
	<gtExample>
	| remoteRunner job context |

	remoteRunner := GtRemoteRunner new.
	remoteRunner taskScheduler: GtRrOneAtATimeTaskScheduler new.

	job := GtRrTestsJob new 
		classNames: #(GtRrSampleTest);
		platforms: #(linux).
	context := GtRrJobContext new
		remoteRunner: remoteRunner;
		job: job.

	remoteRunner taskScheduler schedule: context.

	self assert: context tasks size equals: 4.
]
