Class {
	#name : #PlpoGtRrTasksJob,
	#superclass : #PlpoGtRrJob,
	#instVars : [
		'tasks'
	],
	#category : #'RemoteRunner-Jobs'
}

{ #category : #accessing }
PlpoGtRrTasksJob class >> remoteClassName [

	^ #GtRrTasksJob
]

{ #category : #ui }
PlpoGtRrTasksJob >> gtViewTestsActionFor: anAction [
	<gtAction>

	self hasTests ifFalse: [ ^ anAction noAction ].

	^ anAction button
		tooltip: 'View Test Results';
		icon: BrGlamorousVectorIcons signal;
		action: [ :button | button phlow spawnObject:
			(GtRrExamplesView new job: self getSerialized) ].
]

{ #category : #testing }
PlpoGtRrTasksJob >> hasTests [

	^ self proxyPerform: #hasTests
]

{ #category : #accessing }
PlpoGtRrTasksJob >> tasks [

	^ self newCommandFactory 
		<< 'tasks asArray';
		sendAndWait.
]
