"
GtRrSampleExample contains a few examples that are used for testing example execution.  All examples that are expected to fail have `noTest` set, which is then ignored when running the example.
"
Class {
	#name : #GtRrSampleExample,
	#superclass : #Object,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
GtRrSampleExample >> errorExample [
	<gtExample>
	<noTest>

	self error: 'an error'
]

{ #category : #accessing }
GtRrSampleExample >> failExample [
	<gtExample>
	<noTest>

	self assert: false.

]

{ #category : #accessing }
GtRrSampleExample >> haltExample [
	<gtExample>
	<noTest>
	<gtIgnoreConstraint: #GtSendersOfHaltSelectorsInGtPackagesConstraint>

	self halt.

]

{ #category : #accessing }
GtRrSampleExample >> passExample [
	<gtExample>
	"<noTest>"

	self assert: true.

]
