Class {
	#name : #GtRrExampleResultWithTasksGroup,
	#superclass : #Object,
	#traits : 'TGtGroupItems + TGtGroup',
	#classTraits : 'TGtGroupItems classTrait + TGtGroup classTrait',
	#category : #'RemoteRunner-Reports'
}

{ #category : #'accessing - grouping' }
GtRrExampleResultWithTasksGroup >> groupedByMachine [
	^ self items groupedBy: [ :each | each task workerIpAddress ]
]

{ #category : #'accessing - grouping' }
GtRrExampleResultWithTasksGroup >> groupedByWorker [
	^ self items groupedBy: [ :each | each task workerId ]
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTasksGroup >> gtItemsFor: aView [
	<gtView>

	^ aView list
		title: 'Examples';
		priority: 10;
		items: [ self ]
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTasksGroup >> gtViewItemsByMachinesFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'By Machine';
		priority: 15;
		items: [ self groupedByMachine associations
			 sorted: [ :assoc | assoc value size ] descending ];
		column: 'Machine Ip' text: [ :assoc | assoc key ];
		column: 'Examples Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTasksGroup >> gtViewItemsByWorkerFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'By Worker';
		priority: 20;
		items: [ self groupedByWorker associations
			 sorted: [ :assoc | assoc value size ] descending ];
		column: 'Worker Id' text: [ :assoc | assoc key ];
		column: 'Examples Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]
