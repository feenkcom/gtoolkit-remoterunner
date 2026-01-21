"
nil
"
Class {
	#name : #GtRrImageSyncExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : 'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrImageSyncExamples >> entriesFromStartTo [
	"Demonstrate retrieving all a subset of entries"
	<gtExample>
	<noTest>
	| changesSync entries enumerator start |

	enumerator := GtEpLogEnumerator fromFile: GtEpLogEnumeratorExamples testDataRoot / 'testClass01' / 'Pharo10-SNAPSHOT-64bit-fec28a6.em8gtmjvf6qouoyjm5tk4q4dm.ombu'.
	self 
		assert: enumerator latestEntriesCount = 1
		description: [ 'Expected latestEntriesCount = 1, got: ', enumerator latestEntriesCount asString ].
	start := (enumerator priorEntriesFromHead reversed at: 2) tagAt: #self.
	changesSync := GtRrChangesSync new.
	changesSync 
		epLog: enumerator latestLog;
		sessionHistory: { start }.
	
	entries := (changesSync encodedChangesFrom: start) entries collect: #content.
	self assert: decodedEntries size equals: 4.
	self 
		assert: (decodedEntries collect: #methodAffectedSelector) asArray
		equals: #(method1 method2 method3 method4).
]
