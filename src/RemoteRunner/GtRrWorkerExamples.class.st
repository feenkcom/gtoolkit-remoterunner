Class {
	#name : #GtRrWorkerExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'RemoteRunner-Examples'
}

{ #category : #examples }
GtRrWorkerExamples >> commandLine [
	"Demonstrate parsing the Remote Runner Worker command line"
	<gtExample>
	| commandLine |

	commandLine := GtRrWorker commandLineCommand match:
		#('remoteRunnerWorker' '--log' '--serverSocketAddress' '7084').

	self assert: (commandLine at: #log) value equals: true.
	self assert: ((commandLine at: #serverSocketAddress) at: #address) value equals: '7084'.

	^ commandLine
]
