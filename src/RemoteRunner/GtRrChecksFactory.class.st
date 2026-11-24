Class {
	#name : #GtRrChecksFactory,
	#superclass : #GtRrTaskFactory,
	#instVars : [
		'ignoreNoTest',
		'inImageOnly',
		'retryStrategy',
		'schedulingTimes'
	],
	#category : #'RemoteRunner-Tasks'
}

{ #category : #adding }
GtRrChecksFactory >> addExampleClass: aClass [
	| task |
	
	(aClass isAbstract or: [ aClass isTrait ]) ifTrue: [ ^ self ].

	(aClass gtExamplesAllContained isNotEmpty and: [ aClass isTrait not ]) ifTrue:
		[ task := GtRrClassExampleTask exampleClassName: aClass name.
		ignoreNoTest ifTrue: [ task setIgnoreNoTest ].
		self addTask: task ].
]

{ #category : #adding }
GtRrChecksFactory >> addExampleClassNames: aCollectionOfClassNames [
	| cls task |

	aCollectionOfClassNames do: [ :className |
		cls := self classWithName: className.
		cls gtExamples ifNotEmpty:
			[ task := GtRrClassExampleTask exampleClassName: className.
			ignoreNoTest ifTrue: [ task setIgnoreNoTest ].
			self addTask: task ] ].
]

{ #category : #adding }
GtRrChecksFactory >> addExampleClasses: aCollectionOfClasses [

	aCollectionOfClasses do: [ :cls |
		cls isMeta ifFalse: 
			[ self addExampleClass: cls ] ].
]

{ #category : #adding }
GtRrChecksFactory >> addExamplePackages: aCollectionOfPackages [

	aCollectionOfPackages do: [ :package |
		self addExampleClasses: package classes ]
]

{ #category : #adding }
GtRrChecksFactory >> addExampleTestNames: aCollection [
	"Add the supplied collection of:
		#ClassName -> #selector"

	self addTask: (GtRrExplicitExampleTask exampleNames: aCollection)
]

{ #category : #adding }
GtRrChecksFactory >> addSUnitClass: aClass [
	| task |

	((aClass inheritsFrom: TestCase) and: [ aClass isAbstract not ]) ifFalse: [ ^ self ].

	task := GtRrClassSUnitTask sunitClassName: aClass name.
	self addTask: task.
]

{ #category : #adding }
GtRrChecksFactory >> addSUnitClassNames: aCollectionOfClassNames [

	aCollectionOfClassNames do: [ :className |
		self addSUnitClass: (self classWithName: className) ].
]

{ #category : #adding }
GtRrChecksFactory >> addSUnitClasses: aCollectionOfClasses [

	aCollectionOfClasses do: [ :cls |
		self addSUnitClass: cls ].
]

{ #category : #adding }
GtRrChecksFactory >> addSUnitPackages: aCollectionOfPackages [

	aCollectionOfPackages do: [ :package |
		self addSUnitClasses: package classes ]
]

{ #category : #adding }
GtRrChecksFactory >> addSUnitTestNames: aCollection [
	"Add the supplied collection of:
		#ClassName -> #selector"

	self addTask: (GtRrExplicitSUnitTask sunitTestNames: aCollection)
]

{ #category : #adding }
GtRrChecksFactory >> addTask: aTask [
	tasks add: aTask
]

{ #category : #adding }
GtRrChecksFactory >> addTaskFirst: aTask [
	tasks addFirst: aTask
]

{ #category : #adding }
GtRrChecksFactory >> addTasks: aCollectionOfTasks [
	tasks addAll: aCollectionOfTasks
]

{ #category : #adding }
GtRrChecksFactory >> addTasksFirst: aCollectionOfTasks [
	tasks addAllFirst: aCollectionOfTasks
]

{ #category : #initialization }
GtRrChecksFactory >> clearInImage [
	"Set the flag to indicate that the job may be run in any worker"

	inImageOnly := nil.
]

{ #category : #accessing }
GtRrChecksFactory >> groupTasksByTime [
	tasks := OrderedCollection
			withAll: (GtRrCheckScheduler new
					schedulingTimes: self schedulingTimes;
					allocateTasks: tasks)
]

{ #category : #initialization }
GtRrChecksFactory >> initialize [

	super initialize.
	ignoreNoTest := false.
]

{ #category : #accessing }
GtRrChecksFactory >> job [

	^ GtRrChecksJob new tasks: self tasks.
]

{ #category : #adding }
GtRrChecksFactory >> rejectExampleClasses: aCollection [
	| classNames newTasks |
	classNames := aCollection collect: #name as: Set.
	newTasks := OrderedCollection new.
	tasks do: 
			[:task |
			| newTask |
			newTask := task asExplicitTask.
			newTask checkNames: (newTask checkNames
						reject: [:assoc | classNames includes: assoc key]).
			newTask checkNames isEmpty ifFalse: [newTasks add: newTask]].
	tasks := newTasks
]

{ #category : #adding }
GtRrChecksFactory >> rejectExampleMethods: aCollection [
	| checkNames newTasks |
	checkNames := aCollection
				collect: [:method | method methodClass name -> method selector]
				as: Set.
	newTasks := OrderedCollection new.
	tasks do: 
			[:task |
			| newTask |
			newTask := task asExplicitTask.
			newTask checkNames: (newTask checkNames
						reject: [:assoc | checkNames includes: assoc]).
			newTask checkNames isEmpty ifFalse: [newTasks add: newTask]].
	tasks := newTasks
]

{ #category : #accessing }
GtRrChecksFactory >> retryStrategy [
	^ retryStrategy
]

{ #category : #accessing }
GtRrChecksFactory >> retryStrategy: anObject [
	retryStrategy := anObject
]

{ #category : #accessing }
GtRrChecksFactory >> schedulingTimes [

	^ schedulingTimes ifNil:
		[ schedulingTimes := GtRrCheckSchedulingTimes default ]
]

{ #category : #accessing }
GtRrChecksFactory >> schedulingTimes: aGtRrCheckSchedulingTimes [

	schedulingTimes := aGtRrCheckSchedulingTimes
]

{ #category : #initialization }
GtRrChecksFactory >> setIgnoreNoTest [ 

	ignoreNoTest := true.
]

{ #category : #initialization }
GtRrChecksFactory >> setInImage [
	"Set the flag to indicate that the job should be run in image only"

	inImageOnly := true.
]

{ #category : #initialization }
GtRrChecksFactory >> setNotInImage [
	"Set the flag to indicate that the job should be run in remote workers only"

	inImageOnly := false.
]

{ #category : #accessing }
GtRrChecksFactory >> tasks [
	| allTasks |
	allTasks := super tasks.
	allTasks do: 
			[:task |
			task taskTimeout: taskTimeout.
			ignoreNoTest ifTrue: [task setIgnoreNoTest].
			inImageOnly
				ifNotNil: 
					[task constraint: (inImageOnly
								ifTrue: [GtRrInImageConstraint default]
								ifFalse: [GtRrInImageConstraint default not])].
			retryStrategy ifNotNil: [task retryStrategy: retryStrategy copy]].
	^allTasks
]
