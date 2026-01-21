Class {
	#name : #GtRrSampleTest,
	#superclass : #TestCase,
	#category : 'RemoteRunner-Tests'
}

{ #category : #tests }
GtRrSampleTest >> testError [
	<expectedFailure>

	self error: 'an error'
]

{ #category : #tests }
GtRrSampleTest >> testFail [
	<expectedFailure>

	self assert: false.
]

{ #category : #accessing }
GtRrSampleTest >> testLong [
	"A test that is CPU bound for 60 seconds.
	Normally it will fail due to exceeding the time limit.
	It is marked as an expectedFailure as the purpose is to test the test framework."
	<expectedFailure>
	| startTime |

	startTime := DateAndTime now.
	[ (DateAndTime now - startTime) < 60 seconds ] whileTrue.

]

{ #category : #tests }
GtRrSampleTest >> testPass [

	self assert: true.
]
