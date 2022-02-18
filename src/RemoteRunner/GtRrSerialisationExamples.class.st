Class {
	#name : #GtRrSerialisationExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSerialisationExamples >> gtRrClassExampleTask [
	<gtExample>
	"Demonstrate (de)serialising a GtRrClassExampleTask and its result"
	| task serializedTask deserializedTask result serializedResult deserializedResult |

	LeJsonV4 cleanUp.
	task := GtRrClassExampleTask exampleClassName: #GtRrWorkerExamples.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrClassExampleTask.
	self assert: deserializedTask exampleClassName equals: #GtRrWorkerExamples.

	result := task run.
	serializedResult := LeJsonV4 uniqueInstance serialize: result.
	deserializedResult := LeJsonV4 uniqueInstance deserialize: serializedResult readStream.
	self assert: deserializedResult class equals: GtClassExampleGroup.
	self assert: deserializedResult exampleClass equals: GtRrWorkerExamples.
	self assert: deserializedResult examples first isSuccess.

	^ result.
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrClassSUnitTask [
	<gtExample>
	"Demonstrate (de)serialising a GtRrPackageExampleTask"
	| task serializedTask deserializedTask |

	LeJsonV4 cleanUp.
	task := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrClassSUnitTask.
	self assert: deserializedTask sunitClassName equals: #GtRrSampleTest.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrPackageExampleTask [
	<gtExample>
	"Demonstrate (de)serialising a GtRrPackageExampleTask"
	| task serializedTask deserializedTask |

	LeJsonV4 cleanUp.
	task := GtRrPackageExampleTask examplePackageName: #RemoteRunner.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrPackageExampleTask.
	self assert: deserializedTask examplePackageName equals: #RemoteRunner.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrPackageSUnitTask [
	<gtExample>
	"Demonstrate (de)serialising a GtRrPackageExampleTask"
	| task serializedTask deserializedTask |

	LeJsonV4 cleanUp.
	task := GtRrPackageSUnitTask sunitPackageName: #PharoLink.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrPackageSUnitTask.
	self assert: deserializedTask sunitPackageName equals: #PharoLink.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> jobWithTestNames [
	<gtExample>
	"Demonstrate (de)serialising a GtRrTestsJob with a collection of test names"
	| job serialisedJob deserialisedJob deserialisedTestName |

	job := GtRrJob testTestNames: {#GtRrSampleTest -> #testPass}.

	serialisedJob := LeJsonV4 uniqueInstance serialize: job.
	deserialisedJob := LeJsonV4 uniqueInstance deserialize: serialisedJob readStream.
	self assert: deserialisedJob class equals: GtRrTestsJob.
	self assert: deserialisedJob testNames isArray.
	self assert: deserialisedJob testNames size equals: 1.
	deserialisedTestName := deserialisedJob testNames first.
	self assert: deserialisedTestName equals: #GtRrSampleTest -> #testPass.
	self assert: deserialisedTestName key isSymbol.
	self assert: deserialisedTestName value isSymbol.
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
