Class {
	#name : #GtRrAnnouncementQueueEventsGroup,
	#superclass : #GtBeaconLogEventsGroup,
	#category : #'RemoteRunner-Logging-Events'
}

{ #category : #'gt - extensions' }
GtRrAnnouncementQueueEventsGroup >> gtItemsFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self ];
		children: #subEvents;
		column: 'Event Type' text: [ :anEvent | anEvent class eventLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' 
			text: [ :anEvent | anEvent duration ];
		column: 'Announcements' 
			text: [ :anEvent | anEvent numberOfAnnouncements ]
]
