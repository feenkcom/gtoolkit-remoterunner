Class {
	#name : #GtDtsTestsJob,
	#superclass : #GtDtsJob,
	#category : #'RemoteRunner-DistributedTesting'
}

{ #category : #accessing }
GtDtsTestsJob >> allTests [
	| allTests |

	allTests := OrderedCollection new.
	allTests addAll: testNames.
	classNames do: [ :className |
		className asClass testSelectors do: [ :selector |
			allTests add: className -> selector ] ].
	packageNames do: [ :packageName |
		packageName asPackage testSuite tests do: [ :test |
			allTests add: test class name -> test selector ] ].
	^ allTests
]
