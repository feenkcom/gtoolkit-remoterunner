"
GtRrCheckSchedulingCheckTimes holds the history for the last 20 runs of the receiver's selector.
"
Class {
	#name : #GtRrCheckSchedulingCheckTimes,
	#superclass : #Object,
	#instVars : [
		'selector',
		'times'
	],
	#category : #'RemoteRunner-CheckScheduling'
}

{ #category : #lejsonv4 }
GtRrCheckSchedulingCheckTimes class >> leJsonV4Name [

	^ #gtRrCheckSchedulingCheckTimes
]

{ #category : #'instance creation' }
GtRrCheckSchedulingCheckTimes class >> selector: aSymbol [

	^ self new selector: aSymbol
]

{ #category : #adding }
GtRrCheckSchedulingCheckTimes >> add: duration endTime: aDateAndTime [

	times size > 20 ifTrue: [ times removeFirst ].
	times add: (GtRrCheckSchedulingSuccessfulCheckTime new
		duration: duration;
		endTime: aDateAndTime).
]

{ #category : #adding }
GtRrCheckSchedulingCheckTimes >> addErrorDetails: aGtRrErrorDetails endTime: aDateAndTime [

	times size > 20 ifTrue: [ times removeFirst ].
	times add: (GtRrCheckSchedulingFailedCheckTime new
		errorDetails: aGtRrErrorDetails;
		endTime: aDateAndTime).
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> gtTimesFor: aView [
	<gtView>

	^ aView columnedList
		title: 'Times';
		priority: 10;
		items: [ times reversed ];
		column: 'Run Time' text: [ :item | item endTime ];
		column: 'Duration' text: [ :item | item gtDisplayString ];
		actionUpdateButton
]

{ #category : #initialization }
GtRrCheckSchedulingCheckTimes >> initialize [

	super initialize.
	times := OrderedCollection new.
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> printOn: aStream [

	times 
		ifEmpty: [ aStream << 'No recorded times' ]
		ifNotEmpty: [ aStream print: (GtRrCheckSchedulingTimeMovingAverageStrategy new
			timeFor: self) ]
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> selector [

	^ selector
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> selector: anObject [

	selector := anObject
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> timeWithStrategy: aTimeStrategy ifAbsent: absentBlock [

	times ifEmpty: [ ^ absentBlock value ].
	^ aTimeStrategy timeFor: self.
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> times [

	^ times
]

{ #category : #accessing }
GtRrCheckSchedulingCheckTimes >> times: anObject [

	times := anObject
]
