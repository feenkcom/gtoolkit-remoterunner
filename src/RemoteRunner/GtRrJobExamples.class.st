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
	| job remoteRunner jobContext platformContexts platform1 platform2 p1t1 p2t1 |

	job := GtRrTestsJob new
		classNames: #(GtRrSampleTest);
		platforms: #(plat1 plat2).
	remoteRunner := GtRemoteRunner new.
	jobContext := GtRrJobContext new
		remoteRunner: remoteRunner;
		job: job.

	jobContext getTasks.
	jobContext createPlatformContexts.
	platformContexts := jobContext platformContexts.
	self assert: platformContexts size equals: 2.
	platform1 := jobContext atPlatform: #plat1.
	self assert: platform1 pendingTasks size equals: 4.
	platform2 := jobContext atPlatform: #plat2.
	self assert: platform2 pendingTasks size equals: 4.
	p1t1 := platform1 nextTaskOrNil.
	p2t1 := platform2 nextTaskOrNil.
	self assert: p1t1 ~~ p2t1.
	self assert: p1t1 taskId equals: p2t1 taskId.
	self assert: p1t1 task tests equals: p2t1 task tests.

	^ jobContext
]

{ #category : #examples }
GtRrJobExamples >> createSinglePlatformContexts [ 
	"Demonstrate the creation of platformContexts from a job"
	<gtExample>
	| job remoteRunner jobContext platformContexts currentPlatform |

	job := GtRrTestsJob new
		classNames: #(GtRrSampleTest).
	remoteRunner := GtRemoteRunner new.
	jobContext := GtRrJobContext new
		remoteRunner: remoteRunner;
		job: job.

	jobContext getTasks.
	jobContext createPlatformContexts.
	platformContexts := jobContext platformContexts.
	self assert: platformContexts size equals: 1.
	currentPlatform := jobContext atPlatform: OSPlatform current name.
	self assert: currentPlatform pendingTasks size equals: 4.
	^ jobContext
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
