Class {
	#name : #GtRrTestsJobExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTestsJobExamples >> scheduleTestsOneAtATime [
	"Demonstrate scheduling tests one at a time"
	<gtExample>
	| remoteRunner job context taskContexts |

	remoteRunner := GtRemoteRunner new.

	job := GtRrTestsJob new 
		classNames: #(GtRrSampleTest);
		platforms: #(linux).
	context := GtRrJobContext new
		remoteRunner: remoteRunner;
		job: job.
	self assert: job taskAllocator class equals: GtRrOneAtATimeTestsTaskAllocator.

	taskContexts := context taskContexts.
	self assert: taskContexts size equals: 4.
]
