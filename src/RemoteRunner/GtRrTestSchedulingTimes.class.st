"
GtTestSchedulingTimes holds a history of the time taken to run each example / test.  This is then used by the scheduler for grouping tests in to tasks.
"
Class {
	#name : #GtRrTestSchedulingTimes,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'times',
		'accessMutex',
		'unknownDurationValue',
		'timeStrategy'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #'private - accessing' }
GtRrTestSchedulingTimes class >> emaWeight [
	"Answer the weight given to the new value in the exponential moving average"

	^ 0.2
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> leJsonV4AttributeMapping [ 

	^ { 
		#times -> #times. }
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> leJsonV4Name [

	^ #lwGtPersistentTimes
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> load [

	^ self loadFromFile: 'LwGtPersistentTimes.json'.
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> loadDefaultInstance [

	self setUniqueInstance: (self loadFromFile: 'LwGtPersistentTimes.json').
	^ uniqueInstance
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> loadFromFile: aFileReference [

	^ aFileReference asFileReference readStreamDo: [ :stream |
		LeJsonV4 uniqueInstance deserialize: stream ]
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> setUniqueInstance: anLwGtPersistentTimes [

	uniqueInstance := anLwGtPersistentTimes
]

{ #category : #accessing }
GtRrTestSchedulingTimes class >> updateFromJob: aGtRrJob [
	"Update the default instance, if it already exists"

	self hasUniqueInstance ifFalse: [ ^ self ].
	self uniqueInstance updateFromJob: aGtRrJob.
]

{ #category : #api }
GtRrTestSchedulingTimes >> atClassName: classNameSymbol [

	^ self critical: 
		[ times at: classNameSymbol ]
]

{ #category : #api }
GtRrTestSchedulingTimes >> atClassName: classNameSymbol selector: selectorSymbol [ 

	^ self critical: 
		[ (times at: classNameSymbol) atSelector: selectorSymbol ]
]

{ #category : #api }
GtRrTestSchedulingTimes >> atClassName: classNameSymbol selector: selectorSymbol add: timeInMilliseconds [

	self critical:
		[ (times at: classNameSymbol) 
			atSelector: selectorSymbol add: timeInMilliseconds ].
]

{ #category : #'mutual exclusion' }
GtRrTestSchedulingTimes >> critical: aBlock [

	^ accessMutex critical: aBlock.
]

{ #category : #accessing }
GtRrTestSchedulingTimes >> gtClassesFor: aView [
	<gtView>

	times ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Classes';
		priority: 10;
		object: [ times ];
		view: #gtItemsFor:
]

{ #category : #initialization }
GtRrTestSchedulingTimes >> initialize [

	super initialize.
	times := Dictionary new.
	accessMutex := Monitor new.
	unknownDurationValue := GtRrUnknownDurationValue new.
	timeStrategy := GtRrTestSchedulingTimeMovingAverageStrategy new.
]

{ #category : #persistence }
GtRrTestSchedulingTimes >> save [
	"Save the receiver to the default file"

	self saveToFile: 'LwGtPersistentTimes.json'.
]

{ #category : #persistence }
GtRrTestSchedulingTimes >> saveToFile: aFileReference [
	"Save the receiver to the specified file"
	| fileReference bakReference |

	fileReference := aFileReference asFileReference.
	bakReference := fileReference withExtension: 'bak'.

	bakReference ensureDelete.
	fileReference exists ifTrue:
		[ fileReference copy renameTo: bakReference basename ].

	fileReference writeStreamDo: [ :stream |
		stream << (LeJsonV4 uniqueInstance serialize: self) ]
]

{ #category : #api }
GtRrTestSchedulingTimes >> timeForClass: aClass selector: selectorSymbol [ 

	^ self critical: 
		[ ((times at: aClass name) atSelector: selectorSymbol)
			timeWithStrategy: timeStrategy ifAbsent: unknownDurationValue ].
]

{ #category : #api }
GtRrTestSchedulingTimes >> timeForClassName: classNameSymbol selector: selectorSymbol [ 

	^ self critical: 
		[ times at: classNameSymbol
			ifPresent: [ :classTimes | (classTimes atSelector: selectorSymbol)
				timeWithStrategy: timeStrategy ifAbsent: unknownDurationValue ]
			ifAbsent: unknownDurationValue ]
]

{ #category : #api }
GtRrTestSchedulingTimes >> timeForClassName: classNameSymbol selector: selectorSymbol ifAbsent: absentValue [

	^ self critical: 
		[ ((times at: classNameSymbol) atSelector: selectorSymbol)
			timeWithStrategy: timeStrategy ifAbsent: absentValue ].
]

{ #category : #accessing }
GtRrTestSchedulingTimes >> timeStrategy [

	^ timeStrategy
]

{ #category : #accessing }
GtRrTestSchedulingTimes >> timeStrategy: anObject [

	timeStrategy := anObject
]

{ #category : #'private - accessing' }
GtRrTestSchedulingTimes >> times [

	^ times
]

{ #category : #'private - accessing' }
GtRrTestSchedulingTimes >> times: anObject [

	times := anObject
]

{ #category : #api }
GtRrTestSchedulingTimes >> timesForClass: aClass [

	^ self timesForClassName: aClass name
]

{ #category : #api }
GtRrTestSchedulingTimes >> timesForClassName: aSymbol [
	| className |

	className := aSymbol asSymbol.
	^ self critical:
		[ times at: className ifAbsentPut: 
			[ LwGtPersistentClassTimes testClassName: className ] ].
]

{ #category : #accessing }
GtRrTestSchedulingTimes >> unknownDurationValue [

	^ unknownDurationValue
]

{ #category : #accessing }
GtRrTestSchedulingTimes >> unknownDurationValue: anObject [

	unknownDurationValue := anObject
]

{ #category : #updating }
GtRrTestSchedulingTimes >> updateFromJob: aGtRrJob [
	"Update the receiver's times from the supplied GtRrJob"

	aGtRrJob schedulingInformation do: [ :anArray |
		self 
			atClassName: anArray first
			selector: anArray second
			add: anArray third ].
]
