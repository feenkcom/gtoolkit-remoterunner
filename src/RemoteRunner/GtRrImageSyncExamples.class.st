"
nil
"
Class {
	#name : #GtRrImageSyncExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrImageSyncExamples >> entriesFromStartTo [
	"Demonstrate retrieving all a subset of entries"
	<gtExample>
	| imageSync entries enumerator start |

	enumerator := GtEpLogEnumerator fromFile: GtEpLogEnumeratorExamples testDataRoot / 'testClass01' / 'Pharo10-SNAPSHOT-64bit-fec28a6.em8gtmjvf6qouoyjm5tk4q4dm.ombu'.
	start := (enumerator priorEntriesFromHead reversed at: 2) tagAt: #self.
	imageSync := GtRrImageSync new.
	imageSync 
		epLog: enumerator latestLog;
		sessionHistory: { start }.
	
	entries := imageSync encodedChangesFrom: start.
	self assert: entries size equals: 4.
	entries := entries collect: [ :each |
		LanguageLinkUtils base64Decode: each readStream ].
	self 
		assert: (entries collect: #methodAffectedSelector) asArray
		equals: #(method1 method2 method3 method4).
]
