Class {
	#name : #GtRrExampleResultWithTaskAndLogs,
	#superclass : #Object,
	#instVars : [
		'result',
		'logs'
	],
	#category : 'RemoteRunner-Reports'
}

{ #category : #accessing }
GtRrExampleResultWithTaskAndLogs >> logs [
	^ logs
]

{ #category : #accessing }
GtRrExampleResultWithTaskAndLogs >> logs: anObject [
	logs := anObject
]

{ #category : #accessing }
GtRrExampleResultWithTaskAndLogs >> result [
	^ result
]

{ #category : #accessing }
GtRrExampleResultWithTaskAndLogs >> result: anObject [
	result := anObject
]
