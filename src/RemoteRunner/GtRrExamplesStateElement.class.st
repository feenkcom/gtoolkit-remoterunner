Class {
	#name : #GtRrExamplesStateElement,
	#superclass : #GtRrStateElement,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrExamplesStateElement >> registerOnClick [
	self
		when: BlClickEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			GtInspectorTool
				openWrappedOn: (GtSearchFixedMethodsFilter new methods: elements)
				title: name
				from: self ]
]
