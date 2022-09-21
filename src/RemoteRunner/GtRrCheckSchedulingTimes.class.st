"
GtTestSchedulingTimes holds a history of the time taken to run each example / test.  This is then used by the scheduler for grouping tests in to tasks.
"
Class {
	#name : #GtRrCheckSchedulingTimes,
	#superclass : #Object,
	#traits : 'TGtUniqueInstance',
	#classTraits : 'TGtUniqueInstance classTrait',
	#instVars : [
		'times',
		'accessMutex',
		'timeStrategy',
		'remoteRunner',
		'unknownDuration'
	],
	#category : #'RemoteRunner-TaskScheduling'
}

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> leJsonV4AttributeMapping [ 

	^ { 
		#times -> #times.
		#unknownDuration -> #unknownDuration.
		#timeStrategy -> #timeStrategy. }
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> leJsonV4Name [

	^ #gtRrTestSchedulingTimes
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> load [

	^ self loadFromFile: 'LwGtPersistentTimes.json'.
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> loadDefaultInstance [

	self setUniqueInstance: (self loadFromFile: 'LwGtPersistentTimes.json').
	^ uniqueInstance
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> loadFromFile: aFileReference [

	^ aFileReference asFileReference readStreamDo: [ :stream |
		LeJsonV4 uniqueInstance deserialize: stream ]
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> setUniqueInstance: anLwGtPersistentTimes [

	uniqueInstance := anLwGtPersistentTimes
]

{ #category : #accessing }
GtRrCheckSchedulingTimes class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new remoteRunner: GtRemoteRunner default]
]

{ #category : #api }
GtRrCheckSchedulingTimes >> atClassName: classNameSymbol [

	^ self critical: 
		[ times at: classNameSymbol ]
]

{ #category : #api }
GtRrCheckSchedulingTimes >> atClassName: classNameSymbol selector: selectorSymbol [ 

	^ self critical: 
		[ (times at: classNameSymbol) atSelector: selectorSymbol ]
]

{ #category : #api }
GtRrCheckSchedulingTimes >> atClassName: classNameSymbol selector: selectorSymbol add: duration endTime: aDateAndTime [
	| className |

	className := classNameSymbol asSymbol.
	self critical:
		[ (times at: className ifAbsentPut: [ GtRrCheckSchedulingClassTimes className: className ]) 
			atSelector: selectorSymbol add: duration endTime: aDateAndTime ].
]

{ #category : #api }
GtRrCheckSchedulingTimes >> atClassName: classNameSymbol selector: selectorSymbol addErrorDetails: aGtRrErrorDetails endTime: aDateAndTime [
	| className |

	className := classNameSymbol asSymbol.
	self critical:
		[ (times at: className ifAbsentPut: [ GtRrCheckSchedulingClassTimes className: className ]) 
			atSelector: selectorSymbol addErrorDetails: aGtRrErrorDetails endTime: aDateAndTime ].
]

{ #category : #'mutual exclusion' }
GtRrCheckSchedulingTimes >> critical: aBlock [

	^ accessMutex critical: aBlock.
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> gtClassesFor: aView [
	<gtView>

	times ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Classes';
		priority: 10;
		object: [ times ];
		view: #gtItemsFor:;
		actionUpdateButton 
]

{ #category : #initialization }
GtRrCheckSchedulingTimes >> initialize [

	super initialize.
	times := Dictionary new.
	accessMutex := Monitor new.
	unknownDuration := GtRrUnknownDurationValue new.
	timeStrategy := GtRrTestSchedulingTimeMovingAverageStrategy new.
]

{ #category : #'private - events' }
GtRrCheckSchedulingTimes >> onJobFinished: aGtRrJobAnnouncement [

	aGtRrJobAnnouncement job unsubscribe: self
]

{ #category : #'private - events' }
GtRrCheckSchedulingTimes >> onJobStarted: aGtRrJobStartedAnnouncement [
	| job |

	job := aGtRrJobStartedAnnouncement job.
	job
		when: GtRrJobCompletedAnnouncement, GtRrJobCancelledAnnouncement, GtRrJobTerminatedAnnouncement 
		send: #onJobFinished:
		to: self.
	job
		when: GtRrTaskCompletedAnnouncement, GtRrTaskFailedAnnouncement
		send: #onTaskFinished:
		to: self.

]

{ #category : #'private - events' }
GtRrCheckSchedulingTimes >> onTaskFinished: aGtRrTaskAnnouncement [
	"Process the completed task.
	Gt examples aren't yet handled."

	aGtRrTaskAnnouncement task result do: [ :aPharoLinkTestCaseEndAnnouncement |
		aPharoLinkTestCaseEndAnnouncement isSuccess
			ifTrue: [ self
				atClassName: aPharoLinkTestCaseEndAnnouncement testCaseClassName 
				selector: aPharoLinkTestCaseEndAnnouncement testCaseSelector 
				add: aPharoLinkTestCaseEndAnnouncement duration
				endTime: aPharoLinkTestCaseEndAnnouncement testCaseEndTimestamp ]
			ifFalse: [ self
				atClassName: aPharoLinkTestCaseEndAnnouncement testCaseClassName 
				selector: aPharoLinkTestCaseEndAnnouncement testCaseSelector 
				addErrorDetails: (GtRrErrorDetails new
					errorMessage: aPharoLinkTestCaseEndAnnouncement exceptionMessageText;
					trace: aPharoLinkTestCaseEndAnnouncement exceptionTrace)
				endTime: aPharoLinkTestCaseEndAnnouncement testCaseEndTimestamp ] ]
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> remoteRunner [

	^ remoteRunner
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> remoteRunner: aGtRemoteRunner [

	remoteRunner ifNotNil:
		[ remoteRunner unsubscribe: self ].
	remoteRunner := aGtRemoteRunner.
	self subscribeToRemoteRunner: aGtRemoteRunner.
]

{ #category : #persistence }
GtRrCheckSchedulingTimes >> save [
	"Save the receiver to the default file"

	self saveToFile: self class name asString, '.json'.
]

{ #category : #persistence }
GtRrCheckSchedulingTimes >> saveToFile: aFileReference [
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

{ #category : #private }
GtRrCheckSchedulingTimes >> subscribeToRemoteRunner: aGtRemoteRunner [ 

	aGtRemoteRunner
		when: GtRrJobStartedAnnouncement 
		send: #onJobStarted:
		to: self.

]

{ #category : #api }
GtRrCheckSchedulingTimes >> timeForClass: aClass selector: selectorSymbol [ 

	^ self timeForClassName: aClass name selector: selectorSymbol.
]

{ #category : #api }
GtRrCheckSchedulingTimes >> timeForClassName: classNameSymbol selector: selectorSymbol [ 

	^ self 
		timeForClassName: classNameSymbol
		selector: selectorSymbol
		ifAbsent: [ (unknownDuration timeForClassName: classNameSymbol selector: selectorSymbol) ].
]

{ #category : #api }
GtRrCheckSchedulingTimes >> timeForClassName: classNameSymbol selector: selectorSymbol ifAbsent: absentBlock [

	^ self critical: 
		[ times at: classNameSymbol
			ifPresent: [ :classTimes | 
				classTimes 
					atSelector: selectorSymbol
					ifPresent: [ :selectorTimes | selectorTimes 
						timeWithStrategy: timeStrategy 
						ifAbsent: absentBlock ]
					ifAbsent: absentBlock ]
			ifAbsent: absentBlock ]
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> timeStrategy [

	^ timeStrategy
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> timeStrategy: anObject [

	timeStrategy := anObject
]

{ #category : #'private - accessing' }
GtRrCheckSchedulingTimes >> times [

	^ times
]

{ #category : #'private - accessing' }
GtRrCheckSchedulingTimes >> times: anObject [

	times := anObject
]

{ #category : #api }
GtRrCheckSchedulingTimes >> timesForClass: aClass [

	^ self timesForClassName: aClass name
]

{ #category : #api }
GtRrCheckSchedulingTimes >> timesForClassName: aSymbol [
	| className |

	className := aSymbol asSymbol.
	^ self critical:
		[ times at: className ifAbsentPut: 
			[ LwGtPersistentClassTimes testClassName: className ] ].
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> unknownDuration [

	^ unknownDuration
]

{ #category : #accessing }
GtRrCheckSchedulingTimes >> unknownDuration: anObject [

	unknownDuration := anObject
]

{ #category : #updating }
GtRrCheckSchedulingTimes >> updateFromJob: aGtRrJob [
	"Update the receiver's times from the supplied GtRrJob.
	NOTE: this will disappear as it will get the information from task completion announcements."

	aGtRrJob schedulingInformation do: [ :anArray |
		self 
			atClassName: anArray first
			selector: anArray second
			add: anArray third ].
]
