Class {
	#name : #GtRrExampleResultWithTasksGroup,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : 'RemoteRunner-Reports'
}

{ #category : #'accessing - grouping' }
GtRrExampleResultWithTasksGroup >> groupedByMachine [
	^ self groupedBy: [ :each | each task workerMachineId ]
]

{ #category : #'accessing - grouping' }
GtRrExampleResultWithTasksGroup >> groupedByWorker [
	^ self groupedBy: [ :each | each task workerId ]
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
GtRrExampleResultWithTasksGroup >> gtViewItemsByMachineRegionFor: aView [
	<gtView>
	^ aView columnedList
		title: 'By machine region';
		priority: 20;
		items: [ (self groupedBy: [ :each | each task workerMachineRegion ]) associations
				sorted: [ :assoc | assoc value size ] descending ];
		column: 'Region' text: [ :assoc | assoc key ];
		column: 'Checks Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTasksGroup >> gtViewItemsByMachinesFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'By machine';
		priority: 15;
		items: [ self groupedByMachine associations
			 sorted: [ :assoc | assoc value size ] descending ];
		column: 'Machine Id' text: [ :assoc | assoc key ];
		column: 'Machine Type' text: [ :assoc | 
			assoc value first workerMachineType ];
		column: 'Checks Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]

{ #category : #'gt - extensions' }
GtRrExampleResultWithTasksGroup >> gtViewItemsByWorkerFor: aView [
	<gtView>

	^ aView columnedList 
		title: 'By worker';
		priority: 20;
		items: [ self groupedByWorker associations
			 sorted: [ :assoc | assoc value size ] descending ];
		column: 'Worker Id' text: [ :assoc | assoc key ];
		column: 'Checks Count' text: [ :assoc | assoc value size ];
		send: [ :assoc | assoc value ]
]
