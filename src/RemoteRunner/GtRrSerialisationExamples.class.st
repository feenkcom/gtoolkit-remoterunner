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
	| task serializedTask deserializedTask result serializedResult deserializedResult example |

	LeJsonV4 cleanUp.
	task := GtRrClassExampleTask exampleClassName: #GtRrWorkerExamples.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance deserialize: serializedTask readStream.
	self assert: deserializedTask class = GtRrClassExampleTask
		description: 'deserializedTask class incorrect: ', deserializedTask class name.
	self assert: deserializedTask exampleClassName = #GtRrWorkerExamples
		description: 'deserializedTask exampleClassName incorrect: ', deserializedTask exampleClassName printString.

	result := task run.
	serializedResult := LeJsonV4 uniqueInstance serialize: result.
	deserializedResult := LeJsonV4 uniqueInstance deserialize: serializedResult readStream.
	self assert: deserializedResult class = GtClassExampleGroup
		description: 'deserializedResult class incorrect: ', deserializedResult class name.
	self assert: deserializedResult exampleClass = GtRrWorkerExamples
		description: 'deserializedResult exampleClass incorrect: ', deserializedResult exampleClass printString.
	
	example := deserializedResult examples detect:
		           [ :anExample | anExample selector = #commandLineWithAttributes ].
	self
		assert: example isSuccess
		description:
		'deserializedResult commandLineWithAttributes example isSuccess failed'.

	example := deserializedResult examples detect:
		           [ :anExample | anExample selector = #commandLineWithoutAttributes ].
	self
		assert: example isSuccess
		description:
		'deserializedResult commandLineWithoutAttributes example isSuccess failed'.

	example := deserializedResult examples detect:
		           [ :anExample | anExample selector = #workerControlChannelCommandTimeout ].
	self
		assert: example hasNoTestPragma
		description:
		'deserializedResult workerControlChannelCommandTimeout example hasNoTestPragma failed'.
	self
		assert: example hasResult not
		description:
		'deserializedResult workerControlChannelCommandTimeout example hasResult not failed'.

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
