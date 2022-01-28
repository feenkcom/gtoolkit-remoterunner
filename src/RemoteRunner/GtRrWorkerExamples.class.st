Class {
	#name : #GtRrWorkerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrWorkerExamples >> commandLineWithAttributes [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine attributes |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' 
		'--serverSocketAddress' '7084'
		'--attribute' 'attr1' 'v1'
		'--attribute' 'attr2' 'v2').

	self assert: (commandLine at: #log) value equals: false.
	self assert: ((commandLine at: #serverSocketAddress) at: #address) value equals: '7084'.
	attributes := commandLine occurrencesOf: #attribute collect:
		[ :attr | { (attr at: #key) value. (attr at: #value) value. } ].
	self assert: attributes asArray equals:
		#(('attr1' 'v1') ('attr2' 'v2')).

	^ commandLine
]

{ #category : #examples }
GtRrWorkerExamples >> commandLineWithoutAttributes [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' '--log' '--serverSocketAddress' '7084').

	self assert: (commandLine at: #log) value equals: true.
	self assert: ((commandLine at: #serverSocketAddress) at: #address) value equals: '7084'.

	^ commandLine
]
