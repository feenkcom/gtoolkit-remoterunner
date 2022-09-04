Class {
	#name : #GtRrAnnouncementQueueSignalsGroup,
	#superclass : #Object,
	#traits : 'TGtGroup + TGtGroupItems',
	#classTraits : 'TGtGroup classTrait + TGtGroupItems classTrait',
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #accessing }
GtRrAnnouncementQueueSignalsGroup >> gtItemsFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Signals';
		priority: 10;
		object: [ self items ];
		view: #gtItemsFor:
]
