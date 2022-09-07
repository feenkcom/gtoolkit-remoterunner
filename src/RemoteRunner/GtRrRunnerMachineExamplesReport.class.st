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
GtRrRunnerMachineExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers';
		object: [ self workersReport ];
		view: #gtViewWorkersFor:
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress [

	^ ipAddress
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> ipAddress: anIpAddressString [

	ipAddress := anIpAddressString
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> numberOfWorkers [
	^ self workersReport workers size
]

{ #category : #printing }
GtRrRunnerMachineExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [ 
		aStream 
			<< self ipAddress;
			<< ', ';
			print: self numberOfWorkers;
			<< ' workers'].
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport [

	^ workersReport
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport: anObject [

	workersReport := anObject
]
