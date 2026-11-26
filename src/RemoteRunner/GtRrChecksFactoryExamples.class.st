Class {
	#name : #GtRrChecksFactoryExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrChecksFactoryExamples >> factoryWithExplicitExamples [
	<gtExample>
	<return: #GtRrChecksFactory>
	| factory |
	factory := GtRrChecksFactory new.
	factory addExampleTestNames: 
			{#GtRrTaskExamples -> #sunitTask.
			#GtRrTaskExamples -> #compoundTask}.
	factory addExampleTestNames: 
			{#GtRrTaskExamples -> #taskTimeout.
			#GtRrChecksFactoryExamples -> #factoryWithExplicitExamples}.
	self assert: factory tasks size equals: 2.
	^factory
]

{ #category : #examples }
GtRrChecksFactoryExamples >> rejectAllExampleClassesLeavesNoTasks [
	<gtExample>
	<return: #GtRrChecksFactory>
	| factory |
	factory := self factoryWithExplicitExamples.
	factory rejectExampleClasses: 
			{GtRrTaskExamples.
			GtRrChecksFactoryExamples}.
	self assert: factory tasks isEmpty.
	^factory
]

{ #category : #examples }
GtRrChecksFactoryExamples >> rejectExampleClassesDropsEmptyTasks [
	<gtExample>
	<return: #GtRrChecksFactory>
	| factory |
	factory := self factoryWithExplicitExamples.
	factory rejectExampleClasses: {GtRrTaskExamples}.
	self assert: factory tasks size equals: 1.
	self assert: factory tasks first checkNames
		equals: {#GtRrChecksFactoryExamples -> #factoryWithExplicitExamples}.
	^factory
]

{ #category : #examples }
GtRrChecksFactoryExamples >> rejectExampleMethodsDropsEmptyTasks [
	<gtExample>
	<return: #GtRrChecksFactory>
	| factory |
	factory := self factoryWithExplicitExamples.
	factory rejectExampleMethods: 
			{GtRrTaskExamples >> #sunitTask.
			GtRrTaskExamples >> #compoundTask.
			GtRrTaskExamples >> #taskTimeout}.
	self assert: factory tasks size equals: 1.
	self assert: factory tasks first checkNames
		equals: {#GtRrChecksFactoryExamples -> #factoryWithExplicitExamples}.
	^factory
]
