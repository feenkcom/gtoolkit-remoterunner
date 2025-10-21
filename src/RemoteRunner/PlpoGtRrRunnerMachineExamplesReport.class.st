Class {
	#name : #PlpoGtRrRunnerMachineExamplesReport,
	#superclass : #PharoLinkProxyObject,
	#traits : 'TGtRrRunnerMachineExamplesReportViews',
	#classTraits : 'TGtRrRunnerMachineExamplesReportViews classTrait',
	#category : #'RemoteRunner-Reports'
}

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport class >> remoteClassName [
	^ #GtRrRunnerMachineExamplesReport
]

{ #category : #accessing }
PlpoGtRrRunnerMachineExamplesReport >> workersReport [
	^ self proxyPerform: #workersReport
]
