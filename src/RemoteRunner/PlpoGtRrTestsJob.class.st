Class {
	#name : #PlpoGtRrTestsJob,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
PlpoGtRrTestsJob class >> remoteClassName [

	^ #GtRrTestsJob
]

{ #category : #testing }
PlpoGtRrTestsJob >> isFinished [

	^ self proxyPerform: #isFinished
]

{ #category : #accessing }
PlpoGtRrTestsJob >> testResults [

	^ (self proxyPerform: #testResults) getSerialized
]
