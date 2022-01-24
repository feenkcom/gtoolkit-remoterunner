Class {
	#name : #GtRrTestsJobExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrTestsJobExamples >> scheduleTestsOneAtATime [

	"Demonstrate scheduling tests one at a time"

	<gtExample>
	| remoteRunner job |
	remoteRunner := GtRrScheduler new.
	job := GtRrTestsJob new
		       classNames: #( GtRrSampleTest );
		       constraint: #( linux );
		       scheduler: remoteRunner.
	self
		assert: job taskAllocator class
		equals: GtRrOneAtATimeTestsTaskAllocator.
	job getTasks.
	self assert: job tasks size equals: 4
]
