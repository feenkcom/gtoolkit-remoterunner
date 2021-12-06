Class {
	#name : #GtRrTestsJobExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTestsJobExamples >> scheduleTestsOneAtATime [
	"Demonstrate scheduling tests one at a time"
	<gtExample>
	| remoteRunner job context |

	remoteRunner := GtRemoteRunner new.

	job := GtRrTestsJob new 
		classNames: #(GtRrSampleTest);
		platforms: #(linux).
	context := GtRrJobContext new
		remoteRunner: remoteRunner;
		job: job.
	self assert: job taskAllocator class equals: GtRrOneAtATimeTestsTaskAllocator.

	context getTasks.
	self assert: context tasks size equals: 4.
]
