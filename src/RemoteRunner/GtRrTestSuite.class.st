"
Signal the start and end of each test execution.

GtRrTestSuite currently must not add any instance variables as {{gtClass:GtRrClassSUnitTask}} uses {{gtMethod:Behavior>>adoptInstance:}} to create the instance.
"
Class {
	#name : #GtRrTestSuite,
	#superclass : #TestSuite,
	#category : 'RemoteRunner-Tests'
}

{ #category : #composing }
GtRrTestSuite >> , aTestSuite [

		^ self class new
			addTests: self tests;
			addTests: aTestSuite tests;
			yourself
]

{ #category : #running }
GtRrTestSuite >> runUnmanaged: aResult [
	self setUp.
	[ self tests
		do: [ :each |
			GtRrWorkerCheckStartingSignal new
				testResult: each;
				emit.
			each run: aResult.
			GtRrWorkerCheckCompletedSignal new
				testResult: each;
				emit.
			self announceTest: each.
			self changed: each ] ]
		ensure: [ self tearDown ]
]
