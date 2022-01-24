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
GtRrJobExamples >> createMultiplePlatformContexts [

	"Demonstrate the creation of multiple platformContexts from a job"

	<gtExample>
	| job remoteRunner platformContexts platform1 platform2 p1t1 p2t1 |
	remoteRunner := GtRrScheduler new.
	job := GtRrTestsJob new
		       classNames: #( GtRrSampleTest );
		       constraint: #( plat1 plat2 );
		       scheduler: remoteRunner;
		       yourself.

	job getTasks.
	job createPlatformContexts.
	platformContexts := job platformContexts.
	self assert: platformContexts size equals: 2.
	platform1 := job atPlatform: #plat1.
	self assert: platform1 pendingTasks size equals: 4.
	platform2 := job atPlatform: #plat2.
	self assert: platform2 pendingTasks size equals: 4.
	p1t1 := platform1 nextTaskOrNil.
	p2t1 := platform2 nextTaskOrNil.
	self assert: p1t1 ~~ p2t1.
	self assert: p1t1 id equals: p2t1 id.
	self assert: p1t1 task tests equals: p2t1 task tests.

	^ job
]

{ #category : #examples }
GtRrJobExamples >> createSinglePlatformContexts [

	"Demonstrate the creation of platformContexts from a job"

	<gtExample>
	| job remoteRunner platformContexts currentPlatform |
	remoteRunner := GtRrScheduler new.
	job := GtRrTestsJob new
		       classNames: #( GtRrSampleTest );
		       scheduler: remoteRunner;
		       yourself.

	job getTasks.
	job createPlatformContexts.
	platformContexts := job platformContexts.
	self assert: platformContexts size equals: 1.
	currentPlatform := job atPlatform: OSPlatform current name.
	self assert: currentPlatform pendingTasks size equals: 4.
	^ job
]

{ #category : #examples }
GtRrJobExamples >> testJobClassNames [
	"Confirm that GtRrTestsJob>>classNames: works as expected"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		classNames: #(GtRrSampleTest).

	self confirmAllTests: job allItems.

]

{ #category : #examples }
GtRrJobExamples >> testJobPackageNames [
	"Confirm that packageNames are included in allTests correctly"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		packageNames: #(RemoteRunner).

	self confirmAllTests: job allItems.

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

]

{ #category : #examples }
GtRrJobExamples >> timeout [

	"Demonstrate setting job timeouts"

	<gtExample>
	| runner job task |
	runner := GtRrScheduler new.
	task := GtRrExampleValueTask new.
	job := GtRrTasksJob new
		       tasks: { task };
		       scheduler: runner;
		       yourself.

	self assert: task timeout equals: 3 minutes.
	self assert: job timeout equals: 1 hour.

	runner timeout: runner timeout + 1 minute.
	self assert: task timeout equals: runner timeout.
	self assert: job timeout equals: runner timeout.

	job timeout: runner timeout + 1 minute.
	self assert: task timeout equals: job timeout.
	self assert: job timeout equals: job timeout
]
