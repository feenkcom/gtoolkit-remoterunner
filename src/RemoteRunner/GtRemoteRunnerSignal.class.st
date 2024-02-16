Class {
	#name : #GtRemoteRunnerSignal,
	#superclass : #BeaconSignal,
	#category : #'RemoteRunner-Signals'
}

{ #category : #initialization }
GtRemoteRunnerSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	timestamp := aDateAndTime.
	processId := aCollection second.
]

{ #category : #testing }
GtRemoteRunnerSignal >> isEndSignalType [
	^ false
]

{ #category : #testing }
GtRemoteRunnerSignal >> isStartSignalType [
	^ false
]

{ #category : #printing }
GtRemoteRunnerSignal >> printOneLineContentsOn: stream [
	stream 
		<< '| ';
		<< self signalTypeLabel;
		<< ' | ';
		<< self processId
]

{ #category : #accessing }
GtRemoteRunnerSignal >> signalTypeLabel [

	^ 'GtRemoteRunnerSignal'
]
