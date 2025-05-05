Class {
	#name : #GtRrEpiceaExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrEpiceaExamples >> classCompactChange [
	<gtExample>
	<return: #GtRrEpiceaExamples>
	| oldClass newClass classModification compactEvent |
	oldClass := self class asEpiceaRingDefinition instanceSide.
	newClass := self class asEpiceaRingDefinition instanceSide.
	self assert: newClass instanceVariables isEmpty.
	newClass addInstanceVariable: (RGInstanceVariableDefinition named: #fred).
	classModification := EpClassModification oldClass: oldClass newClass: newClass.
	compactEvent := classModification asGtRrCompactChange.
	self assert: compactEvent class equals: EpClassAddition.
	self assert: compactEvent behaviorAffected equals: newClass.
	self
		assert: compactEvent behaviorAffected instanceVariables
		equals: newClass instanceVariables
]

{ #category : #examples }
GtRrEpiceaExamples >> methodCompactChange [
	<gtExample>
	<return: #GtRrEpiceaExamples>
	| oldMethod newMethod methodModification compactEvent |
	oldMethod := (self class >> #methodCompactChange) asEpiceaRingDefinition.
	newMethod := (self class >> #methodCompactChange) asEpiceaRingDefinition.
	newMethod sourceCode: newMethod sourceCode , '"x"'.
	methodModification := EpMethodModification
			oldMethod: oldMethod
			newMethod: newMethod.
	compactEvent := methodModification asGtRrCompactChange.
	self assert: compactEvent class equals: EpMethodAddition.
	self assert: compactEvent methodAffected equals: newMethod.
	self
		assert: compactEvent methodAffected sourceCode
		equals: newMethod sourceCode.
	self assert: (compactEvent methodAffected sourceCode endsWith: '"x"')
]
