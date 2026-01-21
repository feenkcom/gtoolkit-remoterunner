Class {
	#name : #GtRrFailingExampleResultWithTasksGroup,
	#superclass : #GtRrExampleResultWithTasksGroup,
	#category : 'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrFailingExampleResultWithTasksGroup >> gtErroredExamplesByErrorFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'By error message';
		priority: 11;
		items: [ (self  
			groupedBy: [ :each | each exceptionMessageText ]) associations 
				sort: [ :a :b | a value size > b value size ] ];
		column: 'Error Message' text: [ :assoc | assoc key ];
		column: 'Errors Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]
