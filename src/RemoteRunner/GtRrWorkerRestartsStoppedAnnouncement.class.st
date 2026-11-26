"
I am announced by a {{gtClass:GtRrWorkerManager}} when too many of its workers exited without being stopped by the runner within its failure window (see {{gtMethod:GtRrWorkerManager>>checkFailuresAt:}}).
The worker manager then stops replacing failed workers until {{gtMethod:GtRemoteRunner>>retryWorkerStartup}} is sent, which announces {{gtClass:GtRrWorkerRestartsResumedAnnouncement}}.
I carry plain values: the reason, the failures (exit time -> worker index), the pool size, the number of worker processes still running, and the log and last error line of the last failed worker, see {{gtMethod:GtRrWorkerRestartsStoppedAnnouncement>>description}}.
"
Class {
	#name : #GtRrWorkerRestartsStoppedAnnouncement,
	#superclass : #GtRemoteRunnerAnnouncement,
	#instVars : [
		'reason',
		'failures',
		'poolSize',
		'runningWorkerCount',
		'lastLogFile',
		'lastErrorLine'
	],
	#category : #'RemoteRunner-Announcements'
}

{ #category : #printing }
GtRrWorkerRestartsStoppedAnnouncement >> description [
	"Answer a description of the stopped restarts for the user"

	^ String streamContents: [ :aStream |
		aStream
			<< reason;
			<< ', ';
			print: runningWorkerCount;
			<< ' of ';
			print: poolSize;
			<< ' workers were still running'.
		lastErrorLine ifNotNil: [ 
			aStream
				<< '. Last worker error: ';
				<< lastErrorLine ].
		lastLogFile ifNotNil: [ 
			aStream
				<< '. Last worker log: ';
				<< lastLogFile fullName ] ]
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> failures [
	"Answer the worker failures that stopped the restarts, associations of the exit time and the worker index"

	^ failures
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> failures: aCollection [

	failures := aCollection
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> lastErrorLine [
	"Answer the last error line of the log of the last failed worker, or nil"

	^ lastErrorLine
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> lastErrorLine: aStringOrNil [

	lastErrorLine := aStringOrNil
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> lastLogFile [
	"Answer the stdout / stderr log file of the last failed worker, or nil"

	^ lastLogFile
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> lastLogFile: aFileReference [

	lastLogFile := aFileReference
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> poolSize [

	^ poolSize
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> poolSize: anInteger [

	poolSize := anInteger
]

{ #category : #printing }
GtRrWorkerRestartsStoppedAnnouncement >> printOneLineContentsOn: aStream [

	aStream << self description
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> reason [
	"Answer a description of why the worker restarts were stopped"
	^reason
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> reason: aString [
	reason := aString
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> runningWorkerCount [
	"Answer the number of worker processes that were still running when the restarts were stopped"

	^ runningWorkerCount
]

{ #category : #accessing }
GtRrWorkerRestartsStoppedAnnouncement >> runningWorkerCount: anInteger [

	runningWorkerCount := anInteger
]
