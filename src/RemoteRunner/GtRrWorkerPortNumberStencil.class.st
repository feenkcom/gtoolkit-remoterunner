"
GtRrWorkerPortNumberStencil generates the drop down button to request the port number and open a worker playground.
"
Class {
	#name : #GtRrWorkerPortNumberStencil,
	#superclass : #BrStencil,
	#instVars : [
		'tooltip',
		'extent',
		'workerConnection'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'api - instantiation' }
GtRrWorkerPortNumberStencil >> create [
	"Create the new element"
	| aButton |
	"Specify the button to be used when the dropdown is hidden"
	aButton := BrButton new.
	aButton
		icon: BrGlamorousVectorIcons playground;
		label: self tooltip;
		aptitude: BrGlamorousButtonWithIconAptitude;
		addAptitude: ((BrGlamorousWithDropdownAptitude
			handle: [
				BrButton new
					icon: BrGlamorousVectorIcons playground;
					label: self tooltip;
					aptitude: 	BrGlamorousButtonWithIconAptitude 
						- BrGlamorousButtonWithLabelTooltipAptitude
						- BrGlamorousButtonExteriorAptitude ]
			content: [ | element |
				element := GtRrWorkerPortNumberWidget new.
				element
					workerConnection: workerConnection;
					exact: self extent;
					padding: (BlInsets all: 20) ])).
	^ aButton
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> extent [

	^ extent
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> extent: anObject [

	extent := anObject
]

{ #category : #initialization }
GtRrWorkerPortNumberStencil >> initialize [
	super initialize.
	tooltip := 'Open Worker Playground'.
	extent := 230 @ 70
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> tooltip [

	^ tooltip
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> tooltip: anObject [

	tooltip := anObject
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> workerConnection [

	^ workerConnection
]

{ #category : #accessing }
GtRrWorkerPortNumberStencil >> workerConnection: anObject [

	workerConnection := anObject
]
