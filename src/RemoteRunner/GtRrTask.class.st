Class {
	#name : #GtRrTask,
	#superclass : #TKTTask,
	#instVars : [
		'id',
		'constraint',
		'timeout',
		'execution'
	],
	#category : #'RemoteRunner-Runner'
}

{ #category : #jsonV3 }
GtRrTask class >> leJsonV4AttributeMapping [

	^ OrderedCollection new
		  add: #id -> #id;
		  add: #constraint -> #constraint;
		  add: #timeout -> #timeout;
		  yourself
]

{ #category : #accessing }
GtRrTask class >> leJsonV4Name [

	^ #gtRrTask
]

{ #category : #accessing }
GtRrTask >> constraint [

	^ constraint
]

{ #category : #accessing }
GtRrTask >> constraint: anObject [

	constraint := anObject
]

{ #category : #accessing }
GtRrTask >> execution [

	^ execution
]

{ #category : #accessing }
GtRrTask >> execution: anObject [

	execution := anObject
]

{ #category : #schedulling }
GtRrTask >> futureExecutionFor: aRunner [

	"Makes it terminateable"

	^ execution := BlTktFutureExecution new
		               runner: aRunner;
		               task: self;
		               yourself
]

{ #category : #ui }
GtRrTask >> gtSummaryFor: aView [

	<gtView>
	self flag: 'FIXME remove'.
	^ aView columnedList
		  title: 'Summary';
		  priority: 10;
		  items: [ self summaryAttributes ];
		  column: #Attribute text: [ :item | item key ];
		  column: #Value text: [ :item | item value ];
		  send: [ :item | item value ];
		  actionUpdateButton
]

{ #category : #accessing }
GtRrTask >> id [

	^ id
]

{ #category : #accessing }
GtRrTask >> id: aString [

	"needed for deserialization"

	id := aString
]

{ #category : #accessing }
GtRrTask >> initialize [

	super initialize.
	id := UUID new asString.
	constraint := GtRrTrueConstraint instance
]

{ #category : #printing }
GtRrTask >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: ' '.
	timeout printOn: aStream.
	aStream nextPutAll: ' '.
	constraint printOn: aStream
]

{ #category : #schedulling }
GtRrTask >> taskExecutionFor: aRunner [

	"Makes it terminateable"

	^ execution := BlTktCommandTaskExecution new
		               runner: aRunner;
		               task: self;
		               yourself
]

{ #category : #accessing }
GtRrTask >> timeout [

	^ timeout
]

{ #category : #accessing }
GtRrTask >> timeout: aDuration [

	timeout := aDuration
]
