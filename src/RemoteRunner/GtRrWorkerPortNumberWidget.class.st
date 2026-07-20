"
GtRrWorkerPortNumberWidget provides the simple UI for requesting the port number and opening a worker playground.


"
Class {
	#name : #GtRrWorkerPortNumberWidget,
	#superclass : #BrHorizontalPane,
	#instVars : [
		'portInputField',
		'workerConnection',
		'spawnButton'
	],
	#category : 'RemoteRunner-UI'
}

{ #category : #private }
GtRrWorkerPortNumberWidget >> addElements [

	portInputField := self newPortInput.
	self
		addChild: self newPortLabel;
		addChild: portInputField;
		addChild: self newOkButton.
	
]

{ #category : #initialization }
GtRrWorkerPortNumberWidget >> initialize [

	super initialize.
	self addElements.
]

{ #category : #private }
GtRrWorkerPortNumberWidget >> newOkButton [

	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons accept;
		label: 'Open a Worker Playground';
		margin: (BlInsets top: 1);
		action: [ :aButton | 
			(spawnButton ifNil: [ aButton ]) phlow spawnObject: self workerApplication ].

]

{ #category : #private }
GtRrWorkerPortNumberWidget >> newPortInput [
	| editorElement |

	editorElement := BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new glamorousRegularSmallSize + 
						BrGlamorousInputFieldSpacingAptitude new;
		vFitContent;
		hFitContentLimited;
		margin: (BlInsets right: 5);
		constraintsDo: [ :c | c minWidth: 100 ].

	editorElement editor
		when: BrTextEditorModifiedEvent
		do: [ :anEvent | self onPortModifiedEvent: anEvent ].

	^ editorElement
]

{ #category : #private }
GtRrWorkerPortNumberWidget >> newPortLabel [

	^ BrLabel new 
		aptitude: BrGlamorousLabelAptitude;
		margin: (BlInsets top: 3 right: 5);
		text: 'Port:'
]

{ #category : #private }
GtRrWorkerPortNumberWidget >> onPortModifiedEvent: anEvent [
	| portString colour |

	portString := portInputField text asString.
	colour := (portString allSatisfy: #isDigit)
		ifTrue: [ Color black ]
		ifFalse: [ Color red ].
	portInputField text foreground: colour.
]

{ #category : #accessing }
GtRrWorkerPortNumberWidget >> spawnButton [

	^ spawnButton
]

{ #category : #accessing }
GtRrWorkerPortNumberWidget >> spawnButton: anObject [

	spawnButton := anObject
]

{ #category : #private }
GtRrWorkerPortNumberWidget >> workerApplication [

	^ workerConnection pharoLinkServerOnPort: portInputField text asString asNumber
]

{ #category : #accessing }
GtRrWorkerPortNumberWidget >> workerConnection [

	^ workerConnection
]

{ #category : #accessing }
GtRrWorkerPortNumberWidget >> workerConnection: anObject [

	workerConnection := anObject
]
