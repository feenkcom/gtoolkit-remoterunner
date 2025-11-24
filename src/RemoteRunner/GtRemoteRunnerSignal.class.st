Class {
	#name : #GtRemoteRunnerSignal,
	#superclass : #BeaconSignal,
	#category : 'RemoteRunner-Signals'
}

{ #category : #accessing }
GtRemoteRunnerSignal class >> eventType [
	^ GtBeaconLogEvent
]

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

{ #category : #accessing }
GtRemoteRunnerSignal >> matchingSignalFrom: candidateEvents [
	"Answer the receiver's match from the supplied signals.
	The collection is expected to typically be small and contain the match.
	The default is to match on processId, or if there is only a single candidate, accept that."

	candidateEvents 
		detect:  [ :each | each eventStartedSignal processId = self processId ]
		ifFound: [ :event | ^ event].
	candidateEvents size = 1 ifTrue:
			[ ^ candidateEvents first ].
	^ nil
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
