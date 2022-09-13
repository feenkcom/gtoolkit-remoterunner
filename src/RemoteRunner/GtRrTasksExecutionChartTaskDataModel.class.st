"
{{gtClass:GtRrTasksExecutionChartTaskDataModel}} is an object that captutes the data needed by {{gtClass:name=GtRrTasksExecutionVerticalChartStencil}} about a task. 

It provides the same API as a task, and it is meant to be used polymorphically with tasks when the tasks reside inside different images. Users can serialize the task data and send it back as instances of this class.
"
Class {
	#name : #GtRrTasksExecutionChartTaskDataModel,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'endTime',
		'duration'
	],
	#category : #'RemoteRunner-UI'
}

{ #category : #'instance - creation' }
GtRrTasksExecutionChartTaskDataModel class >> fromDictionary: aDictionary [
	^ self new 
		startTime: (aDictionary at: 'startTime');
		endTime: (aDictionary at: 'endTime')
]

{ #category : #'instance - creation' }
GtRrTasksExecutionChartTaskDataModel class >> fromTask: aTask [
	^ self new 
		startTime: aTask startTime;
		endTime: aTask endTime
]

{ #category : #converting }
GtRrTasksExecutionChartTaskDataModel >> asDictionary [ 
	^ Dictionary new 
		at: 'startTime' put: self startTime;
		at: 'endTime' put: self endTime;
		yourself
]

{ #category : #accessing }
GtRrTasksExecutionChartTaskDataModel >> duration [
	^ duration ifNil: [
		duration := self endTime - startTime ]
]

{ #category : #accessing }
GtRrTasksExecutionChartTaskDataModel >> endTime [

	^ endTime
]

{ #category : #accessing }
GtRrTasksExecutionChartTaskDataModel >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
GtRrTasksExecutionChartTaskDataModel >> startTime [

	^ startTime
]

{ #category : #accessing }
GtRrTasksExecutionChartTaskDataModel >> startTime: anObject [

	startTime := anObject
]
