Class {
	#name : #PlpoGtRrChecksJob,
	#superclass : #PlpoGtRrTasksJob,
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrChecksJob class >> remoteClassName [

	^ #GtRrChecksJob
]

{ #category : #testing }
PlpoGtRrChecksJob >> isChecksJob [

	^ true
]
