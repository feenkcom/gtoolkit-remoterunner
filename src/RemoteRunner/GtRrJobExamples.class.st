Class {
	#name : #GtRrJobExamples,
	#superclass : #Object,
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
GtRrJobExamples >> testJobClassNames [
	"Confirm that GtRrTestsJob>>classNames: works as expected"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		classNames: #(GtRrSampleTest).

	self confirmAllTests: job allTests.

]

{ #category : #examples }
GtRrJobExamples >> testJobPackageNames [
	"Confirm that packageNames are included in allTests correctly"
	<gtExample>
	| job |

	job := GtRrTestsJob new
		packageNames: #(RemoteRunner).

	self confirmAllTests: job allTests.

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

	self confirmAllTests: job allTests.

]
