Class {
	#name : #GtRrJobExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #private }
GtRrJobExamples >> confirmAllTests: allTests [

	self assert: allTests size equals: 4.
	self assert: (allTests collect: #key as: Set) 
		equals: #(GtRrSampleTest) asSet.
	self assert: (allTests collect: #value as: Set)
		equals: #(testPass testFail testLong testError) asSet.

]

{ #category : #examples }
GtRrJobExamples >> defaultJobTimeout [
	"Confirm that by default Jobs have no timeout (isNil)"

	<gtExample>
	<return: #GtRrTasksJob>
	| runner job task jobContext taskContext |
	runner := GtRemoteRunner new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new tasks: {task}.
	jobContext := GtRrJobContext new
			job: job;
			remoteRunner: runner.
	taskContext := GtRrTaskContext new
			jobContext: jobContext;
			task: task.

	self assert: jobContext jobTimeout isNil.
	self assert: jobContext contextTimeoutTime isNil.

	^ job
]

{ #category : #examples }
GtRrJobExamples >> explicitJobTimeout [
	"Demonstrate setting job timeouts"

	<gtExample>
	<return: #GtRrTasksJob>
	| runner job task jobContext taskContext |
	runner := GtRemoteRunner new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new tasks: {task}.
	jobContext := GtRrJobContext new
			job: job;
			remoteRunner: runner.
	taskContext := GtRrTaskContext new
			jobContext: jobContext;
			task: task.

	job jobTimeout: runner defaultTaskTimeout + 1 minute.

	self assert: taskContext jobTimeout equals: job jobTimeout.
	self assert: jobContext jobTimeout equals: job jobTimeout.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobClassNames [
	"Confirm that GtRrTestsJob>>classNames: works as expected"

	<gtExample>
	<return: #GtRrChecksJob>
	| factory job task |
	factory := GtRrChecksFactory new.
	factory addSUnitClass: GtRrSampleTest.
	job := factory job.

	self assert: job tasks size equals: 1.
	task := job tasks first.
	self assert: task sunitClassName equals: #GtRrSampleTest.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobExamplesClassNames [
	"Confirm that GtRrTestsJob>>classNames: works as expected"

	<gtExample>
	<return: #GtRrChecksJob>
	| factory job task |
	factory := GtRrChecksFactory new.
	factory addExampleClass: GtRrSampleExample.
	job := factory job.

	self assert: job tasks size equals: 1.
	task := job tasks first.
	self assert: task exampleClassName equals: #GtRrSampleExample.

	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobPackageNames [
	"Confirm that packageNames supplied to the factory are enumerated in to the appropriate classes"

	<gtExample>
	<return: #GtRrChecksJob>
	| factory job task |
	factory := GtRrChecksFactory new.
	factory addSUnitPackages: {#RemoteRunner asPackage}.
	job := factory job.

	self assert: job tasks size equals: 1.
	task := job tasks first.
	self assert: task sunitClassName equals: #GtRrSampleTest.

	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobTestNames [
	"Confirm that packageNames are included in allTests correctly"

	<gtExample>
	<return: #GtRrChecksJob>
	| factory testNames job task |
	factory := GtRrChecksFactory new.
	testNames := {#GtRrSampleTest -> #testPass.
			#GtRrSampleTest -> #testFail.
			#GtRrSampleTest -> #testLong.
			#GtRrSampleTest -> #testError}.
	factory addSUnitTestNames: testNames.
	job := factory job.

	self assert: job tasks size equals: 1.
	task := job tasks first.
	self assert: task sunitTestNames equals: testNames.

	^ job
]
