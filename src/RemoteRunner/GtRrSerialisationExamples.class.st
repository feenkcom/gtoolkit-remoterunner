Class {
	#name : #GtRrSerialisationExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSerialisationExamples >> jobWithTestNames [
	<gtExample>
	"Demonstrate (de)serialising a GtRrTestsJob with a collection of test names"
	| job serialisedJob deserialisedJob |

	job := GtRrJob testTestNames: {#GtRrSampleTest -> #testPass}.

	serialisedJob := LeJsonV4 uniqueInstance serialize: job.
	deserialisedJob := LeJsonV4 uniqueInstance deserialize: serialisedJob readStream.
	self assert: deserialisedJob class equals: GtRrTestsJob.
	self assert: deserialisedJob testNames isArray.
	self assert: deserialisedJob testNames size equals: 1.
	self assert: deserialisedJob testNames first equals: #GtRrSampleTest -> #testPass.
]

{ #category : #examples }
GtRrSerialisationExamples >> testsJobWithClassAtATimeAllocator [
	<gtExample>
	"Demonstrate (de)serialising a GtRrTestsJob with a GtRrClassAtATimeTestsAllocator"
	| job tasks serialisedTask deserialisedTask tests |

	job := (GtRrJob testPackageNames: #(#PharoLink	))
		taskAllocator: GtRrClassAtATimeTestsTaskAllocator new;
		yourself.
	tasks := job tasks.

	tasks do: [ :task |
		serialisedTask := LeJsonV4 uniqueInstance serialize: task.
		deserialisedTask := LeJsonV4 uniqueInstance deserialize: serialisedTask readStream.
		self assert: deserialisedTask constraint class = GtRrTrueConstraint.
		tests := deserialisedTask tests.
		self assert: tests size equals: 1 ].
]

{ #category : #examples }
GtRrSerialisationExamples >> testsJobWithOneAtATimeAllocator [
	<gtExample>
	"Demonstrate (de)serialising a GtRrTestsJob with a GtRrOneAtATimeTestsAllocator"
	| job tasks serialisedTask deserialisedTask tests |

	job := (GtRrJob testPackageNames: #(#PharoLink	))
		yourself.
	tasks := job tasks.

	tasks do: [ :task |
		serialisedTask := LeJsonV4 uniqueInstance serialize: task.
		deserialisedTask := LeJsonV4 uniqueInstance deserialize: serialisedTask readStream.
		self assert: deserialisedTask constraint class = GtRrTrueConstraint.
		tests := deserialisedTask tests.
		self assert: tests size equals: 1.
		self assert: tests anyOne size equals: 1 ].
]
