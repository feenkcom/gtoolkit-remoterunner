"
GtRrStartCompletedSignalGenerator creates three classes representing an operation with start and completed signals.
"
Class {
	#name : #GtRrStartCompletedSignalGenerator,
	#superclass : #Object,
	#instVars : [
		'prefix',
		'attributes',
		'superclass',
		'packageName'
	],
	#category : 'RemoteRunner-Signals'
}

{ #category : #private }
GtRrStartCompletedSignalGenerator >> abstractClass [
	^self class environment at: self abstractClassName asSymbol
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> abstractClassDefinition [

	^ String streamContents: [ :stream |
		stream
			<< superclass name;
			<< ' subclass: #';
			<< self abstractClassName;
			cr; tab;
			<< 'instanceVariableNames: '''.
		attributes
			do: [ :attribute | stream << attribute ]
			separatedBy: [ stream space ].
		stream
			<< '''';
			cr; tab;
			<< 'classVariableNames: ''''';
			cr; tab;
			<< 'package: ';
			print: packageName ]
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> abstractClassName [

	^ prefix, 'Signal'
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> abstractInitializeMethodSource [
	| offset |

	offset := self allAttributes size - attributes size + 2.
	^ String streamContents: [ :stream |
		stream
			<< 'initializeFromTimestamp: aDateAndTime andData: aCollection';
			cr; cr; tab.
		superclass = BeaconSignal
			ifTrue: [ stream 
				<< 'timestamp := aDateAndTime.';
				cr; tab;
				<< 'processId := aCollection second.' ]
			ifFalse: [ stream << 'super initializeFromTimestamp: aDateAndTime andData: aCollection.' ].
		stream cr; tab.
		attributes doWithIndex: [ :attribute :index |
			stream
				<< attribute;
				<< ' := aCollection at: ';
				print: index + offset;
				<< '.';
				cr; tab ] ].
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> abstractPrintMethodSource [

	^ String streamContents: [ :stream |
		stream
			<< 'printOneLineContentsOn: aStream';
			cr; cr; tab.
		superclass = BeaconSignal
			ifTrue: [ stream 
				stream 
					<< 'aStream';
					cr; tab; tab;
					<< '<< ''| ';
					<< self abstractClassName;
					<< ' | '';';
					cr; tab; tab;
					<< '<< self processId.' ]
			ifFalse: [ stream << 'super printOneLineContentsOn: aStream.' ].
		stream 
			cr; tab;
			<< 'aStream';
			cr; tab; tab.
		attributes ifNotEmpty:
			[ stream << '<< '' | '';'; cr; tab; tab ].
		attributes 
			do: [ :attribute |
				stream
					<< '<< ';
					<< attribute;
					<< ' asString' ]
			separatedBy:
				[ stream
					nextPut: $;;
					cr; tab; tab;
					<< '<< '' | '';';
				cr; tab; tab ] ].
]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> addAttributeAccessor: aString to: aClass [

	aClass
		compile: (String streamContents: [ :stream |
			stream
				<< aString;
				cr; cr; tab;
				<< '^ ';
				<< aString ])
		classified: 'accessing'.
	aClass
		compile: (String streamContents: [ :stream |
			stream
				<< aString;
				<< ': anObject';
				cr; cr; tab;
				<< aString;
				<< ' := anObject' ])
		classified: 'accessing'.

]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> addAttributeAccessors [
	attributes
		do: [:each | self addAttributeAccessor: each to: self abstractClass]
]

{ #category : #actions }
GtRrStartCompletedSignalGenerator >> addCompletedMethods [

	self completedClass
		compile: 'isEndSignalType
	^ true'
		classified: 'testing'
]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> addInitializer [

	attributes ifEmpty: [ ^ self ].
	self abstractClass
		compile: self abstractInitializeMethodSource
		classified: 'initialization'
]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> addPrinter [

	attributes ifEmpty: [ ^ self ].
	self abstractClass 
		compile: self abstractPrintMethodSource
		classified: 'printing'
]

{ #category : #actions }
GtRrStartCompletedSignalGenerator >> addSignalTypeLabel [
	| source |

	source := String streamContents: [ :stream |
		stream
			<< 'signalTypeLabel';
			cr; cr; tab;
			<< '^ ';
			print: self abstractClassName ].
	self abstractClass
		compile: source
		classified: 'accessing'
]

{ #category : #actions }
GtRrStartCompletedSignalGenerator >> addStartingMethods [

	self startingClass
		compile: 'isStartSignalType
	^ true'
		classified: 'testing'
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> allAttributes [
	| allClasses allAttributes beaconSignalIndex |
	
	allClasses := self abstractClass withAllSuperclasses.
	beaconSignalIndex := allClasses indexOf: BeaconSignal.
	self assert: beaconSignalIndex > 1.
	allClasses := allClasses copyFrom: 1 to: beaconSignalIndex - 1.
	allAttributes := OrderedCollection new.
	allClasses do: [ :cls |
		allAttributes addAll: cls instVarNames ].
	^ allAttributes reversed
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> attributes [
	^ attributes
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> attributes: anObject [
	attributes := anObject
]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> completedClass [

	^self class environment at: self completedClassName asSymbol
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> completedClassDefinition [

	^ String streamContents: [ :stream |
		stream
			<< self abstractClassName;
			<< ' subclass: #';
			<< self completedClassName;
			cr; tab;
			<< 'instanceVariableNames: ''''';
			cr; tab;
			<< 'classVariableNames: ''''';
			cr; tab;
			<< 'package: ';
			print: packageName ]
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> completedClassName [

	^ prefix, 'CompletedSignal'
]

{ #category : #actions }
GtRrStartCompletedSignalGenerator >> generateSignals [

	self assert: (self class environment includesKey: self abstractClassName asSymbol) not.
	self assert: (self class environment includesKey: self startingClassName asSymbol) not.
	self assert: (self class environment includesKey: self completedClassName asSymbol) not.
	self class evaluate: self abstractClassDefinition.
	self addAttributeAccessors.
	self addSignalTypeLabel.
	self addPrinter.
	self addInitializer.
	self class evaluate: self startingClassDefinition.
	self addStartingMethods.
	self class evaluate: self completedClassDefinition.
	self addCompletedMethods.
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> packageName [
	^ packageName
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> packageName: anObject [
	packageName := anObject
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> prefix [
	^ prefix
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> prefix: anObject [
	prefix := anObject
]

{ #category : #private }
GtRrStartCompletedSignalGenerator >> startingClass [
	^self class environment at: self startingClassName asSymbol
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> startingClassDefinition [

	^ String streamContents: [ :stream |
		stream
			<< self abstractClassName;
			<< ' subclass: #';
			<< self startingClassName;
			cr; tab;
			<< 'instanceVariableNames: ''''';
			cr; tab;
			<< 'classVariableNames: ''''';
			cr; tab;
			<< 'package: ';
			print: packageName ]
]

{ #category : #'private - accessing' }
GtRrStartCompletedSignalGenerator >> startingClassName [

	^ prefix, 'StartingSignal'
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> superclass [
	^ superclass
]

{ #category : #accessing }
GtRrStartCompletedSignalGenerator >> superclass: aClass [
	superclass := aClass
]
