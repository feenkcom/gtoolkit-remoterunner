Trait {
	#name : #TGtRrTaskVisitor,
	#category : #'RemoteRunner-Tasks'
}

{ #category : #visiting }
TGtRrTaskVisitor >> visitClassExampleTask: aGtRrTask [

	self visitExampleTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitClassSUnitTask: aGtRrTask [

	self visitSUnitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitCodeSyncTask: aGtRrTask [

	self visitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitCompoundTask: aGtRrTask [

	aGtRrTask tasks do: [ :task |
		task acceptVisitor: self ]
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitExampleTask: aGtRrTask [

	self visitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitExampleValueTask: aGtRrTask [

	self visitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitExplicitExampleTask: aGtRrTask [

	self visitExampleTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitExplicitSUnitTask: aGtRrTask [

	self visitSUnitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitNode: aNode [ 

	^ aNode acceptVisitor: self
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitPackageExampleTask: aGtRrTask [

	self visitExampleTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitPackageSUnitTask: aGtRrTask [

	self visitSUnitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitScriptTask: aGtRrTask [

	self visitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitSUnitTask: aGtRrTask [

	self visitTask: aGtRrTask
]

{ #category : #visiting }
TGtRrTaskVisitor >> visitTask: aGtRrTask [
]
