Class {
	#name : #GtRrRunnerMachineExamplesReport,
	#superclass : #Object,
	#instVars : [
		'ipAddress',
		'workersReport'
	],
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> cummulativeTasksDuration [
	^ self workersReport cummulativeTasksDuration
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> description [
	^ self ipAddress
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers Stats';
		priority: 10;
		object: [ self workersReport ];
		view: #gtViewWorkersFor:
]

{ #category : #'gt - extensions' }
GtRrRunnerMachineExamplesReport >> gtViewWorkersTimingFor: aView [
	<gtView>
	
	^ aView forward 
		title: 'Workers Timing';
		priority: 20;
		object: [ self workersReport ];
		view: #gtViewWorkersTimingFor:
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
GtRrRunnerMachineExamplesReport >> numberOfExamples [
	^ self workersReport numberOfExamples
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
GtRrRunnerMachineExamplesReport >> tasksEndTime [
	^ self tasksLastEndTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksFirstHandoveTime [
	^ self workersReport tasksFirstHandoveTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastEndTime [
	^ self workersReport tasksLastEndTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastResultReceivedTime [
	^ self workersReport tasksLastResultReceivedTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksLastStartTime [
	^ self workersReport tasksLastStartTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksStartInterval [
	^ self workersReport tasksStartInterval
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> tasksStartTime [
	^ self workersReport tasksStartTime
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport [

	^ workersReport
]

{ #category : #accessing }
GtRrRunnerMachineExamplesReport >> workersReport: anObject [

	workersReport := anObject
]
