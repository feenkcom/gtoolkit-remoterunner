"
GtWorkerCountCalculator subclasses determine the number of workers to be started by {{gtClass:GtRrManagerStartupAndShutdown}} using various strategies.
"
Class {
	#name : #GtRrWorkerCountCalculator,
	#superclass : #Object,
	#category : #'RemoteRunner-Runner'
}

{ #category : #accessing }
GtRrWorkerCountCalculator >> workerCount [
	"Answer the number of workers to start"
	
	^ self subclassResponsibility 
]
