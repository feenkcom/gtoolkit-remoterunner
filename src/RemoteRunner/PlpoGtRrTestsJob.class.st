Class {
	#name : #PlpoGtRrTestsJob,
	#superclass : #PharoLinkProxyObject,
	#category : #'RemoteRunner-Tests'
}

{ #category : #accessing }
PlpoGtRrTestsJob class >> remoteClassName [

	^ #GtRrTestsJob
]

{ #category : #accessing }
PlpoGtRrTestsJob >> testResults [

	^ (self proxyPerform: #testResults) getSerialized
]
