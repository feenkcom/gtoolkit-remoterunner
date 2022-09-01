"
{{gtClass:GtRrTasksExecutionChartTaskDataModel}} is an object that captutes the data needed by {{gtClass:name=GtRrTasksExecutionVerticalChartStencil}} about a task. 

It provides the same API as a task, and it is meant to be used polymorphically with tasks when the tasks reside inside different images. Users can serialize the task data and send it back as instances of this class.
"
Class {
	#name : #GtRrTasksExecutionChartTaskDataModel,
	#superclass : #Object,
	#category : #'RemoteRunner-Tasks'
}
