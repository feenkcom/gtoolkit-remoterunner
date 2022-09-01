Class {
	#name : #GtRrWorkersExamplesReport,
	#superclass : #Object,
	#instVars : [
		'workers'
	],
	#category : #'RemoteRunner-Worker'
}

{ #category : #'instance - creation' }
GtRrWorkersExamplesReport class >> forJob: aJob [
	| workers |
	workers := (aJob tasks groupedBy: [ :aTask |
		aTask workerId ])  associations collect: [ :assoc |
			GtRrWorkerExamplesReport new
				tasks: assoc value ;
				workerAttributes:  assoc value first workerAttributes;
				yourself ].
	^ self new 
		workers: workers
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> gtViewWorkersFor: aView [
	<gtView>
	
	^ aView columnedList 
		title: 'Workers';
		items: [ self workers ];
		column: 'Id' text: [ :aWorker | aWorker workerId ];
		column: 'Tasks' text: [ :aWorker | aWorker numberOfTasks ];
		column: 'Checks' text: [ :aWorker | aWorker numberOfExamples ]
]

{ #category : #printing }
GtRrWorkersExamplesReport >> printOn: aStream [
	super printOn: aStream.
	
	aStream parenthesize: [
		aStream 
			print: self workers size;
			<< ' workers' ]
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workers [

	^ workers
]

{ #category : #accessing }
GtRrWorkersExamplesReport >> workers: anObject [

	workers := anObject
]
