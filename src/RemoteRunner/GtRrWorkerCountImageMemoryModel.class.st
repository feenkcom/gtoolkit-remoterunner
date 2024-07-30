Class {
	#name : #GtRrWorkerCountImageMemoryModel,
	#superclass : #GtRrWorkerCountRequiredMemoryModel,
	#instVars : [
		'additionalOldSpace'
	],
	#category : #'RemoteRunner-WorkerCount'
}

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel class >> gtViewAlgorithmsFor: aView [
	<gtView>
	<gtClassView>
	
	^ aView columnedList 
		title: 'Worker Count Computations';
		priority: 31;
		items: [ 
			| imageFileSize |
			imageFileSize := Smalltalk imageFile size.
			#(0.5 1 1.5 2) flatCollect: [ :aMemoryMultiplier |
				#(0 0.5 1 1.5 2) collect: [ :aMultiplier |
					GtRrWorkerCountCalculator  new 
						algorithm: (GtRrWorkerCountResourceAlgorithm new
							requiredMemoryModel: (GtRrWorkerCountImageMemoryModel new
								additionalOldSpace: (aMultiplier * imageFileSize)
								imageFileSize: imageFileSize));
						memorySizeMultiplier: aMemoryMultiplier. ]
			] ];
		column: 'Additional Old Space' text: [ :calculator | 
			calculator algorithm requiredMemoryModel additionalOldSpace truncated humanReadableSISizeString ];
		column: 'Required Memory' text: [ :calculator | 
			calculator algorithm requiredMemoryModel requiredMemory truncated humanReadableSISizeString ];
		column: 'Memory Size Multiplier' text: [ :calculator | 
			calculator memorySizeMultiplier ];
		column: 'Available Memory' text: [ :calculator | 
			calculator algorithm availableMemoryModel availableMemory truncated humanReadableSISizeString ];
		column: 'Multiplied Required Memory' text: [ :calculator | 
			(calculator algorithm requiredMemoryModel requiredMemory + (calculator algorithm requiredMemoryModel requiredMemory * calculator memorySizeMultiplier) ) truncated humanReadableSISizeString ];
		
		column: 'Worker count' text:[ :calculator | 
			calculator workerCount ]
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace [
	^ additionalOldSpace
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace: anInteger [

	additionalOldSpace := anInteger.
	requiredMemory := Smalltalk imageFile size + additionalOldSpace.
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace: anInteger imageFileSize: anotherInteger [

	additionalOldSpace := anInteger.
	requiredMemory := anotherInteger + additionalOldSpace.
]

{ #category : #initialize }
GtRrWorkerCountImageMemoryModel >> initialize [

	super initialize.
	self additionalOldSpace: Smalltalk imageFile size.
]
