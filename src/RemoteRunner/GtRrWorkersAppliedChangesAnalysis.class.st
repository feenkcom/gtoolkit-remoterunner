Class {
	#name : #GtRrWorkersAppliedChangesAnalysis,
	#superclass : #Object,
	#instVars : [
		'workersAnalyses'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #'instance creation' }
GtRrWorkersAppliedChangesAnalysis class >> forAllWorkerLogFiles [
	| fileReferences |
	fileReferences := 'workerLogs' asFileReference 
		childrenMatching: 'gtrrworker-*'.
	
	^self forFileReferences: fileReferences
]

{ #category : #accessing }
GtRrWorkersAppliedChangesAnalysis class >> forFileReferences: aCollection [
	| logFiles |
	logFiles  := aCollection collect: [ :aWorkerFile |
		LwGtRrLogFile for: aWorkerFile ]. 
	^self forWorkerLogFiles: logFiles
]

{ #category : #'instance creation' }
GtRrWorkersAppliedChangesAnalysis class >> forWorkerConnections: aCollection [
	^self new 
		initializeForWorkerConnections: aCollection
]

{ #category : #'instance creation' }
GtRrWorkersAppliedChangesAnalysis class >> forWorkerLogFiles: aCollection [
	^self new 
		initializeForWorkerLogFiles: aCollection
]

{ #category : #views }
GtRrWorkersAppliedChangesAnalysis >> gtWorkersAnalysesFor: aView [
	<gtView>
	workersAnalyses ifNil: [^aView empty].
	^(aView columnedList)
		title: 'Workers';
		items: [workersAnalyses];
		column: 'Worker'
			text: [:each | each workerLabel ];
		column: 'Total Changes Count' text: [:each | each totalNumberOfChanges];
		column: 'Initially Replayed' text: [:each | each numberOfInitiallyReplayedChanges];
		column: 'Code Sync' text: [:each | each numberOfCodeSyncChanges];
		column: 'Total Duration' text: [:each | each totalDuration ];
		column: 'Changes Hash' text: [:each | each changesHash base64Encoded ]
		
]

{ #category : #initialization }
GtRrWorkersAppliedChangesAnalysis >> initializeForWorkerConnections: aCollection [
	| logFiles |
	logFiles := aCollection collect: [ :each | 
		'workerLogs' asFileReference / ('gtrrworker-{1}.log' format:  {each pid asString}) ].
		
	self initializeForWorkerLogFiles: (logFiles collect: [ :aWorkerFile |
		LwGtRrLogFile for: aWorkerFile ])
]

{ #category : #initialization }
GtRrWorkersAppliedChangesAnalysis >> initializeForWorkerLogFiles: aCollection [
	workersAnalyses := aCollection collect: [ :aWorkerLogFile |
		GtRrWorkerAppliedChangesAnalysis 
			fromWorkerLogFile: aWorkerLogFile ]
]
