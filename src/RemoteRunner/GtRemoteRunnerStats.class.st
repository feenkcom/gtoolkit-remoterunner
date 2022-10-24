Class {
	#name : #GtRemoteRunnerStats,
	#superclass : #Object,
	#instVars : [
		'totalJobCount',
		'totalTaskCount'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #actions }
GtRemoteRunnerStats >> incrementJobCount [

	totalJobCount := totalJobCount + 1.
]

{ #category : #actions }
GtRemoteRunnerStats >> incrementTaskCount [

	totalTaskCount := totalTaskCount + 1.
]

{ #category : #initialization }
GtRemoteRunnerStats >> initialize [

	super initialize.
	totalJobCount := 0.
	totalTaskCount := 0.
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalJobCount [

	^ totalJobCount
]

{ #category : #accessing }
GtRemoteRunnerStats >> totalTaskCount [

	^ totalTaskCount
]
