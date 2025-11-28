Class {
	#name : #GtRrExecutionChartDataExamples,
	#superclass : #Object,
	#category : 'RemoteRunner-Examples'
}

{ #category : #accessing }
GtRrExecutionChartDataExamples >> executionChartDataItemExample [
	<gtExample>
	<return: #GtRrExecutionChartDataItem>
	| startTime dataItem |
	startTime := DateAndTime now.

	dataItem := GtRrExecutionChartDataItem new
			identifier: 'task1';
			label: 'Task1';
			startTime: startTime;
			endTime: startTime + 1 minute.

	self assert: dataItem duration equals: 1 minute.

	^ dataItem
]

{ #category : #accessing }
GtRrExecutionChartDataExamples >> executionChartDataItemSerializationExample [
	<gtExample>
	<return: #GtRrExecutionChartDataItem>
	| initialItem deserializedItem |
	initialItem := self executionChartDataItemExample.

	deserializedItem := LeJsonV4 uniqueInstance
			deserialize: (LeJsonV4 uniqueInstance serialize: initialItem) readStream.

	self assert: initialItem ~~ deserializedItem.
	self assert: initialItem identifier = deserializedItem identifier.

	^ initialItem
]

{ #category : #accessing }
GtRrExecutionChartDataExamples >> executionChartDataItemsGroupExample [
	<gtExample>
	<return: #GtRrExecutionChartDataItemsGroup>
	| startTime currentTime durations dataGroup |
	startTime := DateAndTime now.
	durations := #(100 89 76 65 43 23 24 45 23) collect: #seconds.

	dataGroup := GtRrExecutionChartDataItemsGroup new
			identifier: 'group1';
			label: 'Group 1'.

	currentTime := startTime.
	durations
		withIndexDo: [ :aDuration :anIndex | 
			dataGroup
				add: (GtRrExecutionChartDataItem new
						identifier: 'task' , anIndex asString;
						label: 'Task' , anIndex asString;
						startTime: currentTime;
						endTime: currentTime + aDuration).
			currentTime := currentTime + aDuration ].

	self assert: dataGroup size equals: durations size.

	^ dataGroup
]
