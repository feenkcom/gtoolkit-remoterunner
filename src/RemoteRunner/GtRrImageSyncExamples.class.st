Class {
	#name : #GtRrImageSyncExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #'as yet unclassified' }
GtRrImageSyncExamples >> imageSync [
	"Answer a GtRrImageSync instance populated with session history"

	^ GtRrImageSync new
		sessionHistory: ((1 to: 10) collect: [ :i | 'Session', i printString ]);
		yourself.
]

{ #category : #examples }
GtRrImageSyncExamples >> recentSessionsFromFirst [
	"Demonstrate getting missing sessions when the first one is the most recent common session"
	<gtExample>
	<noTest>
	| imageSync missingSessions |

	imageSync := self imageSync.
	missingSessions := imageSync sessionReferencesFrom: #('Session1').
	self assert: missingSessions 
		equals: imageSync sessionHistory allButFirst.
]

{ #category : #examples }
GtRrImageSyncExamples >> recentSessionsFromLast [
	"Demonstrate getting missing sessions when the last one is the most recent common session"
	<gtExample>
	<noTest>
	| imageSync missingSessions |

	imageSync := self imageSync.
	missingSessions := imageSync sessionReferencesFrom: #('Session10').
	self assert: missingSessions isEmpty.
	^ imageSync.
]

{ #category : #examples }
GtRrImageSyncExamples >> recentSessionsNoCommon [
	"Demonstrate getting missing sessions when the last one is the most recent common session"
	<gtExample>
	<noTest>
	| imageSync missingSessions |

	imageSync := self imageSync.
	missingSessions := imageSync sessionReferencesFrom: #('Session0').
	self assert: missingSessions isNil.
	^ imageSync.
]
