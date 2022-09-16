Class {
	#name : #GtRrTestSchedulingClassTimes,
	#superclass : #Object,
	#instVars : [
		'times',
		'testClassName'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrTestSchedulingClassTimes class >> leJsonV4Name [

	^ #lwGtTestSchedulingClassTimes
]

{ #category : #'instance creation' }
GtRrTestSchedulingClassTimes class >> testClassName: aSymbol [

	^ self new testClassName: aSymbol
]

{ #category : #api }
GtRrTestSchedulingClassTimes >> atSelector: aSymbol add: duration [
	"Add the supplied to time the exponential moving average for the specified selector"
	| previousTime emaWeight selectorSymbol |

	self assert: [ duration class == Duration ]
		description: 'The supplied time must be a Duration'.

	selectorSymbol := aSymbol asSymbol.
	previousTime := times at: selectorSymbol ifAbsent: [ duration ].
	emaWeight := LwGtPersistentTimes emaWeight.
	times at: selectorSymbol put: 
		((duration * emaWeight) + ((1 - emaWeight) * previousTime)).
]

{ #category : #accessing }
GtRrTestSchedulingClassTimes >> gtTimesFor: aView [
	<gtView>

	times ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Test Times';
		priority: 10;
		object: [ times ];
		view: #gtItemsFor:
]

{ #category : #initialization }
GtRrTestSchedulingClassTimes >> initialize [

	super initialize.
	times := Dictionary new.
]

{ #category : #accessing }
GtRrTestSchedulingClassTimes >> testClassName [

	^ testClassName
]

{ #category : #accessing }
GtRrTestSchedulingClassTimes >> testClassName: aSymbol [

	testClassName := aSymbol asSymbol
]

{ #category : #api }
GtRrTestSchedulingClassTimes >> timeForSelector: selectorSymbol [
	"Answer the number of milliseconds the specified test is expected to take.
	If no local time is stored, use the VW time from GemStone."

	^ times
		at: selectorSymbol asSymbol
		ifAbsent: [ CompositeRun 
			persistentTimeForClass: testClassName 
			selector: selectorSymbol ]
			
]

{ #category : #api }
GtRrTestSchedulingClassTimes >> timeForSelector: selectorSymbol ifAbsent: absentBlock [
	"Answer the number of milliseconds the specified test is expected to take.
	If no local time is stored, use the VW time from GemStone."

	^ times
		at: selectorSymbol asSymbol
		ifAbsent: [ CompositeRun 
			persistentTimeForClass: testClassName asClass
			selector: selectorSymbol
			ifAbsent: absentBlock ]
			
]

{ #category : #'private - accessing' }
GtRrTestSchedulingClassTimes >> times [

	^ times
]

{ #category : #'private - accessing' }
GtRrTestSchedulingClassTimes >> times: anObject [

	times := anObject
]
