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
			#(1 1.5 2) flatCollect: [ :aMemoryMultiplier |
				#(0 0.5 1 1.5 2) collect: [ :aMultiplier |
					GtRrWorkerCountCalculator  new 
						algorithm: (GtRrWorkerCountResourceAlgorithm new
							requiredMemoryModel: (GtRrWorkerCountImageMemoryModel new
								additionalOldSpace: (aMultiplier * imageFileSize)
								imageFileSize: imageFileSize));
						memorySizeMultiplier: aMemoryMultiplier. ]
			] ];
		column: 'Additional Old Space' text: [ :calculator | 
			calculator algorithm requiredMemoryModel additionalOldSpace asInteger humanReadableSISizeString ];
		column: 'Required Memory' text: [ :calculator | 
			calculator algorithm requiredMemoryModel requiredMemory asInteger humanReadableSISizeString ];
		column: 'Multiplier' text: [ :calculator | 
			calculator memorySizeMultiplier ];
		column: 'Available Memory' text: [ :calculator | 
			calculator algorithm availableMemoryModel availableMemory asInteger humanReadableSISizeString ];
		column: 'Multiplied Required Memory' text: [ :calculator | 
			(calculator algorithm requiredMemoryModel requiredMemory * calculator memorySizeMultiplier) asInteger humanReadableSISizeString ];
		
		column: 'Worker count' text:[ :calculator | 
			calculator workerCount ]
]

{ #category : #serialization }
GtRrWorkerCountImageMemoryModel class >> leJsonV4Name [

	^ #gtRrWorkerCountImageMemoryModel
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> additionalOldSpace [

	^ additionalOldSpace ifNil: [ 0 ]
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

{ #category : #ui }
GtRrWorkerCountImageMemoryModel >> calculationAttributes [

	^ { { '- Required Memory (On-Disk Image + Additional)'. ''. self. }.
		{ '- - Image Size'. self onDiskSize humanReadableIsqByteSize. self. }.
		{ '- - Additional Old Space'. self additionalOldSpace humanReadableIsqByteSize. self. }.
		{ '- - Total Required Memory'. self requiredMemory humanReadableIsqByteSize. self. }.
		}		
]

{ #category : #initialize }
GtRrWorkerCountImageMemoryModel >> initialize [

	super initialize.
	self additionalOldSpace: Smalltalk imageFile size.
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> onDiskSize [

	^ Smalltalk imageFile size
]

{ #category : #accessing }
GtRrWorkerCountImageMemoryModel >> requiredMemory [

	^ self onDiskSize + self additionalOldSpace
]
