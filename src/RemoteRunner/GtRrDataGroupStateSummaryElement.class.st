Class {
	#name : #GtRrDataGroupStateSummaryElement,
	#superclass : #GtRrDataGroupStateElement,
	#category : #'RemoteRunner-UI'
}

{ #category : #accessing }
GtRrDataGroupStateSummaryElement >> initializeContent [
	self removeChildren.
	self
		addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: self state itemCount asString;
				background: self state color;
				border: self state border;
				hFitContent;
				vExact: 18;
				padding: (BlInsets all: 2);
				layout: BlLinearLayout horizontal alignCenter;
				geometry: (BlRoundedRectangleGeometry cornerRadius: 4))
]
