Class {
	#name : #GtRrWorkerAppliedChangesGroup,
	#superclass : #GtBeaconLogEventsGroup,
	#category : #'RemoteRunner-Analysis'
}

{ #category : #accessing }
GtRrWorkerAppliedChangesGroup >> count: aBlock [
	| sum |
	sum := 0.
	self do: [ :each | 
		(aBlock value: each) ifTrue: [ sum := sum + 1 ] ].
	^ sum
]

{ #category : #views }
GtRrWorkerAppliedChangesGroup >> gtViewChangesFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Changes';
		priority: 4;
		items: [ self ];
		children: #subEvents;
		column: 'Ombu Reference' text: [:each | each ombuEntryReferenceName ];
		column: 'Timestamp' text: [:each | each timestamp ];
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ]
			width: 125;
		column: 'Event Type' text: [ :anEvent | anEvent eventLabel ]
]

{ #category : #accessing }
GtRrWorkerAppliedChangesGroup >> referencesHash [
	^(SHA256 new hashMessage: (String 
		streamContents: [ :s | 
			self referencesNames asStringOn: s delimiter: '' ])) 
]

{ #category : #accessing }
GtRrWorkerAppliedChangesGroup >> referencesNames [
	^self collect: [ :each | each ombuEntryReferenceName ]
]
