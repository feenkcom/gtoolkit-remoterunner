Class {
	#name : #GtRrTestsJob,
	#superclass : #GtRrAbstractTestsJob,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrTestsJob >> allItems [
	| allTests |

	allTests := OrderedCollection new.
	allTests addAll: testNames.
	classNames do: [ :className |
		className asClass testSelectors do: [ :selector |
			allTests add: className -> selector ] ].
	packageNames do: [ :packageName |
		packageName asPackage classes 
			select: [ :cls | cls isTestCase and: [ cls isAbstract not ] ]
			thenDo: [ :cls | cls testSelectors do: [ :selector |
				allTests add: cls name -> selector ] ] ].

	^ allTests
]

{ #category : #private }
GtRrTestsJob >> taskAllocator [
	"Answer the object that will allocate job items to job tasks"

	^ GtRrOneAtATimeTestsTaskAllocator new
]
