"
Produce a plot of the number of worker machines connected to the runner over time from a single run contained in the supplied remoteRunner.log file.

Typical usage:

```
GtRrRemoteRunnerWorkerMachineSequenceAnalysis readFromFile: 'remoteRunner.log'.
```

"
Class {
	#name : #GtRrRemoteRunnerWorkerMachineSequenceAnalysis,
	#superclass : #Object,
	#instVars : [
		'signalTypeIndicator',
		'corruptEntries',
		'signals'
	],
	#category : 'RemoteRunner-Analysis'
}

{ #category : #api }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis class >> readFrom: aStream [
	^ self new
		readFrom: aStream
]

{ #category : #api }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis class >> readFromFile: aFileReference [
	^ aFileReference asFileReference readStreamDo: [ :aStream | 
		self new
			readFrom: aStream ]
]

{ #category : #ui }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> graphElement [

	^ (GtRrMachineCountPlot new 
		values: self machineSequence) plot
]

{ #category : #ui }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> gtWorkerPlotFor: aView [
	<gtView>

	^ aView explicit
		title: 'Worker Plot';
		priority: 10;
		stencil: [ self graphElement ]
]

{ #category : #initialization }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> initialize [
	super initialize.
	
	signalTypeIndicator := 'WorkerSignal'
]

{ #category : #accessing }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> machineSequence [
	"Answer a collection of timestamp -> count for the number of worker machines active"
	| added removed started count |

	added := OrderedCollection new.
	removed := OrderedCollection new.
	started := Set new.
	count := 0.
	signals do: [ :signal |
		signal class = GtRrWorkerRegisteredAnnouncement ifTrue:
			[ (started includes: signal remoteAddressString) ifFalse:
				[ started add: signal remoteAddressString.
				count := count + 1.
				added add: signal timestamp -> count ] ] ].
	signals reverseDo: [ :signal |
		signal class = GtRrWorkerUnregisteredAnnouncement ifTrue:
			[ (started includes: signal remoteAddressString) ifTrue:
				[ started remove: signal remoteAddressString.
				removed add: signal timestamp ] ] ].
	^ added, (removed reversed collect: [ :each | 
		count := count - 1.
		each -> count ])
]

{ #category : #api }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> processSignals: aCollectionOfSignals [
	| eventsGrouper |
	eventsGrouper := self createDefaultEventsGrouper  .
	eventsGrouper processEventSignalsFor: aCollectionOfSignals.
	^ eventsGrouper
]

{ #category : #api }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> readFrom: aStream [
	| classes |

	signals := OrderedCollection new.
	classes := { ' GtRrWorkerRegisteredAnnouncement |'.
		' GtRrWorkerUnregisteredAnnouncement |'. }.
	corruptEntries := OrderedCollection new.

	aStream contents linesDo: [ :aLine |
		(classes anySatisfy: [ :cls |
			aLine includesSubstring: cls ]) ifTrue: 
				[ | newSignal |
				[ newSignal := self readSignalFromLine: aLine.
				signals add: newSignal ]
					on: Error, SyntaxErrorNotification
					do: [ :ex | corruptEntries add: aLine -> ex freeze ] ] ].
]

{ #category : #accessing }
GtRrRemoteRunnerWorkerMachineSequenceAnalysis >> readSignalFromLine: aLine [
	| timestampString signalClassName parts signalClass signal |

	parts := aLine splitOn: ' | '.
	
	timestampString := parts first copyUpTo: Character space.
	signalClassName := (parts first 
		copyFrom: timestampString size + 1 
		to: parts first size) trimBoth.
	
	signalClass := signalClassName asClass.
	signal := signalClass new.
	signal 
		initializeFromTimestamp: timestampString asDateAndTime 
		andData: parts.
	^ signal
]
