Class {
	#name : #GtRrAllTestsJob,
	#superclass : #GtRrTestsJob,
	#instVars : [
		'maxClasses',
		'excludedTests'
	],
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrAllTestsJob class >> leJsonV4Name [

	^ #gtRrAllTestsJob
]

{ #category : #accessing }
GtRrAllTestsJob >> allItems [
	| subclasses subclass excluded |

	subclasses := TestCase allSubclasses select: [ :cls | cls isAbstract not ].
	excluded := self excludedTests asSet.

	^ Array streamContents: [ :stream |
		1 to: (maxClasses min: subclasses size) do: [ :i |
			subclass := subclasses at: i.
			subclass allTestSelectors do: [ :selector |
				(excluded includes: selector) ifFalse:
					[ stream nextPut: subclass name -> selector ] ] ] ].
]

{ #category : #private }
GtRrAllTestsJob >> defaultExcludedTests [

	^ #()
]

{ #category : #private }
GtRrAllTestsJob >> defaultTaskAllocator [
	"Answer the object that will allocate job items to job tasks"

	^ GtRrClassAtATimeTestsTaskAllocator new
]

{ #category : #accessing }
GtRrAllTestsJob >> excludedTests [
	<return: #Collection of: #Symbol>

	^ excludedTests ifNil: [ excludedTests := self defaultExcludedTests ]
]

{ #category : #accessing }
GtRrAllTestsJob >> excludedTests: anObject [

	excludedTests := anObject
]

{ #category : #initialization }
GtRrAllTestsJob >> initialize [

	super initialize.
	maxClasses := SmallInteger maxVal.

]

{ #category : #accessing }
GtRrAllTestsJob >> maxClasses [

	^ maxClasses
]

{ #category : #accessing }
GtRrAllTestsJob >> maxClasses: anObject [

	maxClasses := anObject
]
