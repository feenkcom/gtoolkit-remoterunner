"
GtRrCheckSchedulingClassTimes holds the execution times or error details for a single class.
"
Class {
	#name : #GtRrCheckSchedulingClassTimes,
	#superclass : #Object,
	#instVars : [
		'times',
		'className'
	],
	#category : 'RemoteRunner-CheckScheduling'
}

{ #category : #'instance creation' }
GtRrCheckSchedulingClassTimes class >> className: aSymbol [

	^ self new className: aSymbol
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes class >> leJsonV4Name [

	^ #lwGtTestSchedulingClassTimes
]

{ #category : #'instance creation' }
GtRrCheckSchedulingClassTimes class >> testClassName: aSymbol [

	^ self new testClassName: aSymbol
]

{ #category : #api }
GtRrCheckSchedulingClassTimes >> atSelector: aSymbol add: duration endTime: aDateAndTime [
	"Add the supplied to time the exponential moving average for the specified selector"
	| selector |

	selector := aSymbol asSymbol.
	((GtRrCheckSchedulingTimes classWithName: className) canUnderstand: selector) ifFalse: [ ^ self ].

	self assert: [ duration class == Duration ]
		description: 'The supplied time must be a Duration'.

	(times at: selector ifAbsentPut: [ GtRrCheckSchedulingCheckTimes selector: selector ])
		add: duration endTime: aDateAndTime.

]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> atSelector: selectorSymbol add: duration errorDetails: aGtRrErrorDetails endTime: aDateAndTime [
	"Add the supplied error details for the specified selector"
	| selector |

	selector := selectorSymbol asSymbol.
	((GtRrCheckSchedulingTimes classWithName: className) canUnderstand: selector) ifFalse: [ ^ self ].

	(times at: selectorSymbol ifAbsentPut: [ GtRrCheckSchedulingCheckTimes selector: selectorSymbol ])
		add: duration errorDetails: aGtRrErrorDetails endTime: aDateAndTime.

]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> atSelector: aSymbol ifAbsent: absentBlock [

	^ times
		at: aSymbol asSymbol
		ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> atSelector: aSymbol ifPresent: presentBlock ifAbsent: absentBlock [

	^ times
		at: aSymbol asSymbol
		ifPresent: presentBlock
		ifAbsent: absentBlock
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> className [

	^ className
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> className: anObject [

	className := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> gtTimesFor: aView [
	<gtView>

	times ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Selector';
		priority: 10;
		object: [ times ];
		view: #gtItemsFor:;
		actionUpdateButton 
]

{ #category : #initialization }
GtRrCheckSchedulingClassTimes >> initialize [

	super initialize.
	times := Dictionary new.
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> printOn: aStream [

	className ifNil: [ ^ super printOn: aStream ].
	aStream
		print: className;
		<< ': ';
		print: self totalAverageTime
]

{ #category : #'private - accessing' }
GtRrCheckSchedulingClassTimes >> times [

	^ times
]

{ #category : #'private - accessing' }
GtRrCheckSchedulingClassTimes >> times: anObject [

	times := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingClassTimes >> totalAverageTime [
	| strategy |

	times ifEmpty: [ ^ Duration zero ].
	strategy := GtRrCheckSchedulingTimeMovingAverageStrategy new.
	^ (times collect: [ :each | strategy timeFor: each ]) sum.
]
