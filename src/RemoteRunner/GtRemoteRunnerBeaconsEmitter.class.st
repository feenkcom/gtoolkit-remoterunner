Class {
	#name : #GtRemoteRunnerBeaconsEmitter,
	#superclass : #GtBeaconSignalsEmitter,
	#category : 'RemoteRunner-Signals'
}

{ #category : #logging }
GtRemoteRunnerBeaconsEmitter >> emitJobShutdownEndFor: aJobContext [
	self whenEnabled: [
		GtRrJobShutdownSignal
			emitEndForJobContext: aJobContext  ]
]

{ #category : #logging }
GtRemoteRunnerBeaconsEmitter >> emitJobShutdownStartFor: aJobContext [
	self whenEnabled: [
		GtRrJobShutdownSignal
			emitStartForJobContext: aJobContext  ]
]

{ #category : #logging }
GtRemoteRunnerBeaconsEmitter >> emitJobStartupEndFor: aJobContext [
	self whenEnabled: [
		GtRrJobStartupSignal
			emitEndForJobContext: aJobContext  ]
]

{ #category : #logging }
GtRemoteRunnerBeaconsEmitter >> emitJobStartupStartFor: aJobContext [
	self whenEnabled: [
		GtRrJobStartupSignal
			emitStartForJobContext: aJobContext  ]
]
