Class {
	#name : #GtDtsManagerExamples,
	#superclass : #Object,
	#category : #'RemoteRunner-DistributedTesting'
}

{ #category : #'as yet unclassified' }
GtDtsManagerExamples >> dummyExample [
	<gtExample>
	| stream  stack |

	stream := Stdio stdout asNewLineStream.
	stack := thisContext stack.
	1 to: stack size do: [ :s | (stack at: s) printOn: stream. stream lf. ]
]
