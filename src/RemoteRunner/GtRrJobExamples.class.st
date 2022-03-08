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
GtRrJobExamples >> jobTimeout [
	"Demonstrate setting job timeouts"
	<gtExample>
	| runner job task jobContext taskContext |

	runner := GtRemoteRunner new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new tasks: { task }.
	jobContext := GtRrJobContext new 
		job: job;
		remoteRunner: runner.
	taskContext := GtRrTaskContext new
		jobContext: jobContext;
		task: task.

	self assert: taskContext jobTimeout equals: runner defaultJobTimeout.
	self assert: jobContext jobTimeout equals: runner defaultJobTimeout.

	runner jobTimeout: runner defaultJobTimeout + 1 minute.
	self assert: taskContext jobTimeout equals: runner jobTimeout.
	self assert: jobContext jobTimeout equals: runner jobTimeout.

	job jobTimeout: runner jobTimeout + 1 minute.
	self assert: taskContext jobTimeout equals: job jobTimeout.
	self assert: jobContext jobTimeout equals: job jobTimeout.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobClassNames [

	"Confirm that GtRrTestsJob>>classNames: works as expected"

	<gtExample>
	| job |
	job := GtRrTestsJob new classNames: #( GtRrSampleTest ).

	self confirmAllTests: job allItems.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobPackageNames [
	"Confirm that packageNames are included in allTests correctly"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		packageNames: #(RemoteRunner).

	self confirmAllTests: job allItems.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobTestNames [
	"Confirm that packageNames are included in allTests correctly"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		testNames: {
			#GtRrSampleTest->#testPass.
			#GtRrSampleTest->#testFail.
			#GtRrSampleTest->#testLong.
			#GtRrSampleTest->#testError
			}.

	self confirmAllTests: job allItems.
	^ job
]
