Class {
	#name : #GtRrSerialisationExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrSerialisationExamples >> gtRrClassExampleTask [
	"Demonstrate (de)serialising a GtRrClassExampleTask and its result"

	<gtExample>
	<return: #Array>
	| task serializedTask deserializedTask result serializedResult deserializedResult example |
	LeJsonV4 cleanUp.
	task := GtRrClassExampleTask exampleClassName: #GtRrWorkerExamples.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance
			deserialize: serializedTask readStream.
	self
		assert: deserializedTask class = GtRrClassExampleTask
		description: 'deserializedTask class incorrect: ' , deserializedTask class name.
	self
		assert: deserializedTask exampleClassName = 'GtRrWorkerExamples'
		description: 'deserializedTask exampleClassName incorrect: '
				, deserializedTask exampleClassName printString.

	result := task run.
	serializedResult := LeJsonV4 uniqueInstance serialize: result.
	deserializedResult := LeJsonV4 uniqueInstance
			deserialize: serializedResult readStream.
	self
		assert: (deserializedResult
				allSatisfy: [ :each | each isKindOf: PharoLinkTestCaseEndAnnouncement ])
		description: [ 'deserializedResult class incorrect: '
				, (deserializedResult collect: [ :each | each class name ]) printString ].
	self
		assert: (deserializedResult
				allSatisfy: [ :each | each testCaseClassName = #GtRrWorkerExamples ])
		description: [ 'deserializedResult exampleClass incorrect: '
				, (deserializedResult collect: [ :each | each testCaseClassName ] as: Set)
						printString ].

	example := deserializedResult
			detect: [ :exampleResult | exampleResult testCaseSelector = #commandLineWithAttributes ].
	self
		assert: example isSuccess
		description: 'deserializedResult commandLineWithAttributes example isSuccess failed'.

	example := deserializedResult
			detect: [ :anExample | anExample testCaseSelector = #commandLineWithoutAttributes ].
	self
		assert: example isSuccess
		description: 'deserializedResult commandLineWithoutAttributes example isSuccess failed'.

	example := deserializedResult
			detect: [ :anExample | anExample testCaseSelector = #workerControlChannelCommandTimeout ].
	self
		assert: (example method hasPragmaNamed: #noTest)
		description: 'deserializedResult workerControlChannelCommandTimeout example hasNoTestPragma failed'.
	self
		assert: example isSkipped
		description: 'deserializedResult workerControlChannelCommandTimeout example isSkipped failed'.

	^ result
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrClassSUnitTask [
	"Demonstrate (de)serialising a GtRrPackageExampleTask"

	<gtExample>
	<return: #GtRrClassSUnitTask>
	| task serializedTask deserializedTask |
	LeJsonV4 cleanUp.
	task := GtRrClassSUnitTask sunitClassName: #GtRrSampleTest.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance
			deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrClassSUnitTask.
	self assert: deserializedTask sunitClassName equals: 'GtRrSampleTest'.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrPackageExampleTask [
	"Demonstrate (de)serialising a GtRrPackageExampleTask"

	<gtExample>
	<return: #GtRrPackageExampleTask>
	| task serializedTask deserializedTask |
	LeJsonV4 cleanUp.
	task := GtRrPackageExampleTask examplePackageName: #RemoteRunner.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance
			deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrPackageExampleTask.
	self assert: deserializedTask examplePackageName equals: 'RemoteRunner'.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> gtRrPackageSUnitTask [
	"Demonstrate (de)serialising a GtRrPackageExampleTask"

	<gtExample>
	<return: #GtRrPackageSUnitTask>
	| task serializedTask deserializedTask |
	LeJsonV4 cleanUp.
	task := GtRrPackageSUnitTask sunitPackageName: #PharoLink.

	serializedTask := LeJsonV4 uniqueInstance serialize: task.
	deserializedTask := LeJsonV4 uniqueInstance
			deserialize: serializedTask readStream.
	self assert: deserializedTask class equals: GtRrPackageSUnitTask.
	self assert: deserializedTask sunitPackageName equals: 'PharoLink'.

	^ task
]

{ #category : #examples }
GtRrSerialisationExamples >> nilSerialisation [
	"Instance variables with nil value should not be sent across the wire."

	<gtExample>
	<return: #GtRrTasksJob>
	| job serializedJob |
	LeJsonV4 cleanUp.
	job := (GtRrScriptTask script: '1+1') asJob.

	serializedJob := LeJsonV4 uniqueInstance serializePretty: job.
	self
		assert: (serializedJob indexOfSubCollection: 'exceptionHandlingStrategy')
		equals: 0.

	^ job
]

{ #category : #examples }
GtRrSerialisationExamples >> testCaseResultCheckName [
	"Demonstrate (de)serialising a test case result as a worker sends it back (LeJsonV4):
	the class name and the selector stay Symbols, so the result has the check name of the local check"

	<gtExample>
	<return: #PharoLinkTestCasePass>
	| result deserialized results |
	result := PharoLinkTestCasePass
			className: #GtRrWorkerExamples
			selector: #commandLineWithAttributes
			startTimestamp: DateAndTime now.
	deserialized := LeJsonV4 uniqueInstance
			deserialize: (LeJsonV4 uniqueInstance serialize: result) readStream.
	self assert: deserialized class equals: PharoLinkTestCasePass.
	self assert: deserialized testCaseClassName equals: #GtRrWorkerExamples.
	self assert: deserialized testCaseSelector equals: #commandLineWithAttributes.
	self assert: deserialized checkName equals: #GtRrWorkerExamples -> #commandLineWithAttributes.
	self assert: deserialized equals: result.
	results := Dictionary new.
	results at: #GtRrWorkerExamples -> #commandLineWithAttributes put: nil.
	self assert: (results includesKey: deserialized checkName).
	^ deserialized
]

{ #category : #examples }
GtRrSerialisationExamples >> workerOperationShutdownAnnouncement [
	"Demonstrate (de)serialising a GtRrWorkerOperationShutdownAnnouncement as the announcement queue
	sends it to a listener in another image (MessagePack, through PharoLink)"

	<gtExample>
	<return: #GtRrWorkerOperationShutdownAnnouncement>
	| announcement data deserialized |
	announcement := GtRrWorkerOperationShutdownAnnouncement new
			reason: 'Connection Closed';
			yourself.
	data := MpDecoder decode: (MpEncoder encode: announcement serializeForRemoteDelivery).
	deserialized := GtRemoteRunnerAnnouncement fromSerializedData: data.
	self assert: deserialized class equals: GtRrWorkerOperationShutdownAnnouncement.
	self assert: deserialized reason equals: 'Connection Closed'.
	self assert: deserialized processId equals: announcement processId.
	^ deserialized
]
