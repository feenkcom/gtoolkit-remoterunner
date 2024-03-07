Class {
	#name : #GtRrSharedAccessAnalysis,
	#superclass : #Object,
	#instVars : [
		'testsExecution',
		'allEvents'
	],
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrSharedAccessAnalysis class >> latestExecution [

	^ self new testsExecution: LwGtTestsJobExecution latest
]

{ #category : #accessing }
GtRrSharedAccessAnalysis >> allEvents [

	^ allEvents ifNil: [ allEvents := testsExecution remoteRunnerEvents subEvents ]
]

{ #category : #accessing }
GtRrSharedAccessAnalysis >> mutexWaitStats [
	| stats |

	stats := Dictionary new.
	{ GtRrRegisterWorkerSignal. GtRrTaskDoneSignal. GtRrNextTaskSignal. } do: [ :eventClass |
		| events mutexTimes eventTimes combined mutexStats eventStats |
		events := self allEvents select: [ :event | event eventCompletedSignal isKindOf: eventClass ].
		mutexTimes := (events collect: [ :event | event eventCompletedSignal mutexWait ])
			reject: #isNil.
		mutexTimes := mutexTimes collect: #asNumber.
		eventTimes := events collect: #duration.
		mutexStats := { 
				#count -> mutexTimes size.
				#min -> mutexTimes min rounded. 
				#median -> mutexTimes median rounded. 
				#average -> mutexTimes average rounded. 
				#max -> mutexTimes max rounded.
				#sum -> (mutexTimes sum rounded / 1000) asDuration. } asOrderedDictionary.
		eventStats := {
				#count -> eventTimes size.
				#min -> eventTimes min asMilliSeconds. 
				#median -> eventTimes median asMilliSeconds. 
				#average -> eventTimes average asMilliSeconds. 
				#max -> eventTimes max asMilliSeconds.
				#sum -> eventTimes sum. } asOrderedDictionary.
		combined := {
			#mutexStats -> mutexStats.
			#eventStats -> eventStats.
			} asOrderedDictionary.
		stats
			at: eventClass
			put: combined ].
	^ stats
]

{ #category : #accessing }
GtRrSharedAccessAnalysis >> testsExecution [
	^ testsExecution
]

{ #category : #accessing }
GtRrSharedAccessAnalysis >> testsExecution: anObject [
	testsExecution := anObject
]
