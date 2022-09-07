Class {
	#name : #GtRrRunnerMachineExamplesReport,
	#superclass : #Object,
	#instVars : [
		'ipAddress',
		'workersReport'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress [

	^ ipAddress
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress: anIpAddressString [

	ipAddress := anIpAddressString
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport [

	^ workersReport
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport: anObject [

	workersReport := anObject
]
