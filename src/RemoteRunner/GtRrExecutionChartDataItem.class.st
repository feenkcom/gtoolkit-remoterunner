"
{{gtClass:GtRrExecutionChartDataItem}} is an object that captutes the data needed by {{gtClass:name=GtRrTasksExecutionHorizontalChartStencil}} about a task. 

It provides the same API as a task, and it is meant to be used polymorphically with tasks when the tasks reside inside different images. Users can serialize the task data and send it back as instances of this class.
"
Class {
	#name : #GtRrExecutionChartDataItem,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'endTime',
		'duration',
		'label'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromDictionary: aDictionary [
	^ self new 
		startTime: (aDictionary at: 'startTime');
		endTime: (aDictionary at: 'endTime');
		label: (aDictionary at: 'label' ifAbsent: [ nil ])
]

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromMachine: aMachine [
	^ self new 
		startTime: aMachine tasksFirstHandoveTime;
		endTime: aMachine tasksLastResultReceivedTime;
		label:  aMachine description
]

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromTask: aTask [
	^ self new 
		startTime: aTask handoverTime;
		endTime: aTask resultReceivedTime;
		label:  aTask description
]

{ #category : #'instance - creation' }
GtRrExecutionChartDataItem class >> fromWorker: aWorker [
	^ self new 
		startTime: aWorker tasksFirstHandoveTime;
		endTime: aWorker tasksLastResultReceivedTime;
		label:  aWorker description
]

{ #category : #converting }
GtRrExecutionChartDataItem >> asDictionary [ 
	^ Dictionary new 
		at: 'startTime' put: self startTime;
		at: 'endTime' put: self endTime;
		at: 'label' put: self label;
		yourself
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> duration [
	^ duration ifNil: [
		duration := self endTime - startTime ]
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> endTime [ 
	^ endTime
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> label [

	^ label
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> label: anObject [

	label := anObject
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrExecutionChartDataItem >> startTime: anObject [

	startTime := anObject
]
